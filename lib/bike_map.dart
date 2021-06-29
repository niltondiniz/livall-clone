import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socketio/widgetUtils/widget_utils.dart';
import 'dart:async';
import 'package:vibration/vibration.dart';

//imports da parte de comunicacao
import 'dart:convert';
import 'dart:typed_data';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:device_info/device_info.dart';
import 'package:intl/intl.dart';
import 'dart:io' show File, Platform;
import 'dart:io' as io;
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class BikeMapPage extends StatefulWidget {
  @override
  _BikeMapState createState() => _BikeMapState();
}

class _BikeMapState extends State<BikeMapPage> {
  Completer<GoogleMapController> _controller = Completer();
  final Map<String, Marker> _markers = {};
  int _indiceMapa = 0;
  double _tamanhoMicrofone = 50;
  String _textPPT = 'Pressione pra falar';
  Color _colorPPT = Colors.blue;
  Color _corButtonPPT = Color.fromRGBO(3, 157, 252, 0.5);
  Icon _iconPPT =
      Icon(Icons.mic, size: 50, color: Color.fromRGBO(255, 255, 255, 0.8));
  double _heightPPT = 150;
  Icon _iconHidePPT = Icon(Icons.keyboard_arrow_down);
  bool _visiblePPTButton = true;

  //==========Variaveis da parte de comunicacao=============================
  String _respostaServidor = '';
  IO.Socket _socket;
  FlutterAudioRecorder _recorder;
  Recording _recording;
  Timer _t;
  IconData _buttonIcon = Icons.do_not_disturb_on;
  String _alert;
  String _uploadedFileURL = "";
  io.Directory appDocDirectory;

  //==========================Variaveis da parte de geolocalização============
  Geolocator geolocator = Geolocator();
  LocationOptions locationOptions =
      LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  static final CameraPosition _minhaCasa = CameraPosition(
      target: LatLng(-22.1119007, -43.1844011),
      tilt: 0,
      zoom: 19.151926040649414);

  @override
  Future<void> initState() {
    super.initState();

    _socket = IO.io("http://192.168.0.101:8000", <String, dynamic>{
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

    ultimaLocalizacao();
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              mapType: MapType.normal,
              compassEnabled: true,
              indoorViewEnabled: true,
              rotateGesturesEnabled: true,
              myLocationButtonEnabled: false,
              minMaxZoomPreference: MinMaxZoomPreference(13, 17),
              trafficEnabled: true,
              initialCameraPosition: _minhaCasa,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: _markers.values.toSet(),
            ),
          ),
          BotaoPositioned(
              EdgeInsets.fromLTRB(16, 16, 16, 145),
              FractionalOffset.bottomLeft,
              50,
              50,
              Colors.black26,
              Icon(Icons.volume_up),
              () {}),
          BotaoPositioned(
              EdgeInsets.fromLTRB(16, 16, 16, 80),
              FractionalOffset.bottomLeft,
              50,
              50,
              Colors.black26,
              Icon(Icons.person_add),
              () {}),
          BotaoPositioned(
              const EdgeInsets.all(16),
              FractionalOffset.bottomLeft,
              50,
              50,
              Colors.black26,
              Icon(Icons.gps_fixed),
              () => _getLocation()),
          BotaoPositioned(
              EdgeInsets.fromLTRB(16, 16, 16, 145),
              FractionalOffset.bottomRight,
              50,
              50,
              Colors.black26,
              Icon(Icons.queue_music),
              () {}),
          BotaoPositioned(
              EdgeInsets.fromLTRB(16, 16, 16, 80),
              FractionalOffset.bottomRight,
              50,
              50,
              Colors.black26,
              Icon(Icons.camera_alt),
              () {}),
          BotaoPositioned(
            EdgeInsets.all(16),
            FractionalOffset.bottomRight,
            50,
            50,
            Colors.black26,
            Icon(Icons.close),
            () => _navigatePop(context),
          ),
          Positioned(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: FractionalOffset.topRight,
                child: Container(
                  height: 200,
                  width: 50,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.black26,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      BotaoContato(Icon(Icons.person_pin), Colors.blue),
                      BotaoContato(Icon(Icons.person_pin), Colors.orangeAccent),
                      BotaoContato(Icon(Icons.person_pin), Colors.pinkAccent),
                      BotaoContato(Icon(Icons.person_pin), Colors.brown),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            child: new Align(
              alignment: FractionalOffset.bottomCenter,
              child: AnimatedContainer(
                onEnd: () {
                  if (_heightPPT == 150)
                    setState(() {
                      _visiblePPTButton = true;
                    });
                },
                height: _heightPPT,
                width: MediaQuery.of(context).size.width * 0.3,
                duration: Duration(milliseconds: 100),
                curve: Curves.slowMiddle,
                decoration: BoxDecoration(
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(25),
                    topRight: const Radius.circular(25),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.8],
                    colors: [_colorPPT, Color.fromRGBO(0, 0, 0, 0.2)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.5),
                      blurRadius: 1, // has the effect of softening the shadow
                      spreadRadius: 1, // has the effect of extending the shadow
                      offset: Offset(
                        2, // horizontal, move right 10
                        5, // vertical, move down 10
                      ),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      alignment: Alignment.topCenter,
                      icon: _iconHidePPT,
                      onPressed: () {
                        setState(() {
                          if (_heightPPT == 50) {
                            _heightPPT = 150;
                            _iconHidePPT = Icon(Icons.keyboard_arrow_down);
                          } else {
                            _visiblePPTButton = false;
                            _heightPPT = 50;
                            _iconHidePPT = Icon(Icons.keyboard_arrow_up);
                          }
                        });
                      },
                    ),
                    Visibility(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 0),
                        child: Text(
                          _textPPT,
                          style: TextStyle(
                            fontSize:
                                10 * MediaQuery.of(context).textScaleFactor,
                          ),
                        ),
                      ),
                      visible: _visiblePPTButton,
                    ),
                    Visibility(
                      visible: _visiblePPTButton,
                      child: GestureDetector(
                        onLongPress: () {
                          setState(() {
                            Vibration.vibrate(duration: 100);
                          });
                          _opt();
                        },
                        onLongPressUp: _opt,
                        child: ClipOval(
                          child: Container(
                            height: 50 * MediaQuery.of(context).textScaleFactor,
                            width: 50 * MediaQuery.of(context).textScaleFactor,
                            child: IconPtt(
                              Icons.mic,
                              30 * MediaQuery.of(context).textScaleFactor,
                              Color.fromRGBO(255, 255, 255, 0.8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;

    if (_indiceMapa == 0) {
      controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
      _indiceMapa = 1;
    } else {
      controller.animateCamera(CameraUpdate.newCameraPosition(_minhaCasa));
      _indiceMapa = 0;
    }
  }

  Future<void> _getLocation() async {
    final GoogleMapController controller = await _controller.future;

    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        tilt: 59.440717697143555,
        zoom: 19.151926040649414)));

    setState(() {
      _markers.clear();
      final marker = Marker(
        markerId: MarkerId("curr_loc"),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        infoWindow: InfoWindow(
            title:
                'Sua Localização: \n\n Latitude: ${currentLocation.latitude}, \n\n Longitude: ${currentLocation.longitude}, \n\n Precisão: ${currentLocation.speedAccuracy} '),
      );
      _markers["Current Location"] = marker;
    });
  }

  //===================================================================================
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

    setState(() {
      _estadoComponentesPPT(_recording.status);
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

  Future ultimaLocalizacao() async {
    // You can can also directly ask the permission about its status.

    Position localizacao = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    print(localizacao.latitude);
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

  Future<void> _emiteEventoAudioGravado() async {
    Uint8List data;
    String myPath = _recording.path;

    String pathAudio = _recording.path;
    var audio = File(pathAudio);
    List<int> audioBytes = audio.readAsBytesSync();

    String base64File = base64Encode(audioBytes);
    _socket.emit('audio', [base64File]);
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

  void _estadoComponentesPPT(RecordingStatus status) {
    switch (status) {
      case RecordingStatus.Initialized:
        {
          _colorPPT = Colors.blue;
          _iconPPT = Icon(Icons.mic,
              size: _tamanhoMicrofone,
              color: Color.fromRGBO(255, 255, 255, 0.8));
          _corButtonPPT = Color.fromRGBO(3, 157, 252, 0.5);
          _textPPT = 'Pressione para falar';
          break;
        }
      case RecordingStatus.Recording:
        {
          //Muda a cor do container do botao ppt
          _colorPPT = Colors.red;

          //muda o incone do botao ppt
          _iconPPT = Icon(
            Icons.fiber_manual_record,
            color: Colors.red,
            size: _tamanhoMicrofone,
          );

          //Muda a cor do raisedButton do PPT
          _corButtonPPT = Colors.black38;

          //Muda o texto do container do PPT
          _textPPT = 'Solte para enviar';
          break;
        }
      case RecordingStatus.Stopped:
        {
          _colorPPT = Colors.blue;
          _iconPPT = Icon(Icons.mic,
              size: _tamanhoMicrofone,
              color: Color.fromRGBO(255, 255, 255, 0.8));
          _corButtonPPT = Color.fromRGBO(3, 157, 252, 0.5);
          _textPPT = 'Pressione para falar';
          break;
        }
      case RecordingStatus.Unset:
        // TODO: Handle this case.
        break;
      case RecordingStatus.Paused:
        // TODO: Handle this case.
        break;
    }
  }

  void _play() {
    AudioPlayer player = AudioPlayer();
    player.play(_recording.path, isLocal: true);
    //uploadFile(File(_recording.path));

    print("Play");
    //_playFromUrl(_uploadedFileURL);
  }

  Function _navigatePop(BuildContext _context) {
    Navigator.pop(_context);
  }
}
