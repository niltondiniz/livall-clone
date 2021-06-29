import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:device_info/device_info.dart';
import 'package:intl/intl.dart';
import 'dart:io' show File, Platform;
import 'dart:io' as io;

import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(Comunicacao());
}

class Comunicacao extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _respostaServidor = '';
  IO.Socket _socket;

  FlutterAudioRecorder _recorder;
  Recording _recording;
  Timer _t;
  IconData _buttonIcon = Icons.do_not_disturb_on;
  String _alert;
  String _uploadedFileURL = "";
  io.Directory appDocDirectory;

  void _opt() async {
    switch (_recording.status) {
      case RecordingStatus.Initialized:
        {
          await _startRecording();
          break;
        }
      case RecordingStatus.Recording:
        {
          await _stopRecording();
          await _emiteEventoAudioGravado();
          await _prepare();
          break;
        }
      /*case RecordingStatus.Stopped:
        {
          await _prepare();
          break;
        }*/

      default:
        break;
    }

    // 刷新按钮
    setState(() {
      _buttonIcon = _playerIcon(_recording.status);
    });
  }

  Future _init() async {
    String customPath = '/flutter_audio_recorder_';

    if (io.Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDocDirectory = await getExternalStorageDirectory();
    }

    // can add extension like ".mp4" ".wav" ".m4a" ".aac"
    customPath = appDocDirectory.path +
        customPath +
        DateTime.now().millisecondsSinceEpoch.toString();

    // .wav <---> AudioFormat.WAV
    // .mp4 .m4a .aac <---> AudioFormat.AAC
    // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.

    _recorder = FlutterAudioRecorder(customPath,
        audioFormat: AudioFormat.WAV, sampleRate: 22050);
    await _recorder.initialized;
  }

  Future _prepare() async {
    var hasPermission = await FlutterAudioRecorder.hasPermissions;
    if (hasPermission) {
      await _init();
      var result = await _recorder.current();
      setState(() {
        _recording = result;
        _buttonIcon = _playerIcon(_recording.status);
        _alert = "";
      });
    } else {
      setState(() {
        _alert = "Permission Required.";
      });
    }
  }

  Future _startRecording() async {
    await _recorder.start();
    var current = await _recorder.current();
    setState(() {
      _recording = current;
    });

    _t = Timer.periodic(Duration(milliseconds: 10), (Timer t) async {
      var current = await _recorder.current();
      setState(() {
        _recording = current;
        _t = t;
      });
    });
  }

  Future _stopRecording() async {
    var result = await _recorder.stop();
    _t.cancel();

    setState(() {
      _recording = result;
    });
  }

  Future<String> _getDeviceName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.model}'); // e.g. "Moto G (4)"
      return androidInfo.model;
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.utsname.machine}');
      return iosInfo.utsname.machine;
    }
  }

  Future<void> _getSocket() async {
    _socket.on('downTo', (data) {
      print(data);
      setState(() {
        String hora = DateFormat('dd-MM-yyyy – hh:mm').format(DateTime.now());
        _respostaServidor = " $hora - ${data['dadoenviado']}";
      });
    });
    print('Registrou o evento downTo no servidor');

    _getSocketAudio();
  }

  Future<void> _getSocketAudio() async {
    _socket.on('audio-stream', (data) {
      
      Uint8List base64File = base64Decode(data);
      File('${appDocDirectory.path}/test.wav').writeAsBytesSync(base64File);

      AudioPlayer player = AudioPlayer();
      player.play('${appDocDirectory.path}/test.wav', isLocal: true);
    });
  }

  Future<void> _emiteEvento() async {
    var deviceName = await _getDeviceName();
    _socket.emit('evento', deviceName);
  }

  Future<void> _emiteEventoAudio() async {
    var deviceName = await _getDeviceName();
    _socket.emit('audio', deviceName);
  }

  Future<void> _emiteEventoAudioGravado() async {
    
    Uint8List data;
    String myPath = _recording.path;

    String pathAudio = _recording.path;
    var audio = File(pathAudio);
    List<int> audioBytes = audio.readAsBytesSync();

    String base64File = base64Encode(audioBytes);
    _socket.emit('audio', [base64File]);

  }

  Future<Uint8List> _readFileByte(String filePath) async {
    Uri myUri = Uri.parse(filePath);
    File audioFile = new File.fromUri(myUri);
    Uint8List bytes;
    await audioFile.readAsBytes().then((value) {
      bytes = Uint8List.fromList(value);
      print('reading of bytes is completed');
    }).catchError((onError) {
      print('Exception Error while reading audio from path:' +
          onError.toString());
    });
    return bytes;
  }

  Future<void> _writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  IconData _playerIcon(RecordingStatus status) {
    switch (status) {
      case RecordingStatus.Initialized:
        {
          return Icons.fiber_manual_record;
        }
      case RecordingStatus.Recording:
        {
          return Icons.stop;
        }
      case RecordingStatus.Stopped:
        {
          return Icons.fiber_manual_record;
        }
      default:
        return Icons.do_not_disturb_on;
    }
  }

  void _play() {
    AudioPlayer player = AudioPlayer();
    player.play(_recording.path, isLocal: true);
    //uploadFile(File(_recording.path));

    print("Play");
    //_playFromUrl(_uploadedFileURL);
  }

  @override
  void initState() {
    super.initState();

    _socket = IO.io("http://192.168.0.103:8000", <String, dynamic>{
      'transports': ['websocket'],
    });

    _socket.on('connect', (_) {
      print('Connected');
    });

    _socket.on("disconnect", (_) => print('Disconnected'));

    _getSocket();

    Future.microtask(() {
      _prepare();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Pressione para gravar, solte para enviar',
                style: TextStyle(fontSize: 30),
              ),
              Text(
                '$_respostaServidor',
                style: Theme.of(context).textTheme.headline4,
              ),
              /*RaisedButton(
                child: Text("Rock & Roll"),
                onPressed: _emiteEvento,
                color: Colors.red,
                textColor: Colors.yellow,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                splashColor: Colors.grey,
              ),
              RaisedButton(
                child: Text("audio"),
                onPressed: _emiteEventoAudio,
                color: Colors.red,
                textColor: Colors.yellow,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                splashColor: Colors.grey,
              ),
              RaisedButton(
                onPressed: _opt,
                child: _buttonIcon,
                color: Colors.red,
                textColor: Colors.yellow,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                splashColor: Colors.grey,
              ),
              RaisedButton(
                child: Text("Play"),
                onPressed: _recording?.status == RecordingStatus.Stopped
                    ? _play
                    : null,
                color: Colors.red,
                textColor: Colors.yellow,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                splashColor: Colors.grey,
              ),
              RaisedButton(
                child: Text("Enviar"),
                onPressed: _emiteEventoAudioGravado,
                color: Colors.red,
                textColor: Colors.yellow,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                splashColor: Colors.grey,
              ),*/
              Container(
                child: GestureDetector(
                  child: Container(
                    child: Icon(_buttonIcon, size: 160),
                  ),
                  onLongPress: () {
                    _opt();
                    print('Pressionou');
                  },
                  onLongPressUp: _opt,
                ),
                color: Colors.red,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getSocket,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
