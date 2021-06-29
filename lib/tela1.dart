import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socketio/bike_map.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'LIVALL',
          style: GoogleFonts.daysOne(
            textStyle: TextStyle(
              color: Colors.white,
              fontFamily: 'Basica',
              fontSize: 20 * MediaQuery.of(context).textScaleFactor,
            ),
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            child: Icon(Icons.headset),
            padding: EdgeInsets.only(right: 12),
          ),
        ],
        leading: Padding(
          padding: EdgeInsets.only(left: 12),
          child: IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () {
              print('Click leading');
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 30,
        showUnselectedLabels: true,
        unselectedFontSize: 12,
        selectedFontSize: 12,
        selectedItemColor: Colors.blueAccent,
        onTap: (e) {},
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.directions_bike),
            title: new Text(
              'Cycling',
            ),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.group_work),
            title: new Text(
              'Group',
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rss_feed),
            title: Text(
              'Feed',
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.device_hub),
            title: Text(
              'Device',
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text(
              'Me',
            ),
          ),
        ],
      ),
      body: new Stack(
        children: <Widget>[
          new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("image/fundo.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Container(
                    //Container indice do pedal
                    padding: EdgeInsets.fromLTRB(16, 25, 8, 25),
                    color: Colors.black38,
                    child: Column(
                      children: <Widget>[
                        Row(
                          //Clima/informacoes do pedal
                          children: <Widget>[
                            Icon(
                              Icons.cloud_queue,
                              size: 60,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  //Indice do Pedal
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'Cycling Index',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Icon(Icons.star,
                                          color: Colors.green, size: 12),
                                      Icon(Icons.star,
                                          color: Colors.green, size: 12),
                                      Icon(Icons.star,
                                          color: Colors.green, size: 12),
                                      Icon(Icons.star,
                                          color: Colors.green, size: 12),
                                      Icon(Icons.star,
                                          color: Colors.green, size: 12),
                                    ],
                                  ),
                                ),
                                Padding(
                                  //Temperatura do pedal
                                  padding: const EdgeInsets.only(
                                    left: 20.0,
                                    top: 10,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        '29°C | PM2.5',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '36',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.green,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Container(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    '0.0',
                                    style: GoogleFonts.economica(
                                      textStyle: TextStyle(
                                        fontSize: 70,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.only(left: 20),
                                        child: Text(
                                          'LIVALL cycling',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white60,
                                          ),
                                        )),
                                    Padding(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Text(''),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            'km',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white60,
                                            ),
                                          ),
                                          Text(
                                            '',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white60,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  '00:00:00',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text('0',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        color: Colors.white60, fontSize: 20)),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    'Duration',
                                    style: TextStyle(
                                      color: Colors.white60,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Times',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: Colors.white60,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  GestureDetector(
                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BikeMapPage()),
                      );
                    },
                    child: ClipOval(
                      child: Container(
                        color: Colors.blue,
                        height: 100 * MediaQuery.of(context).textScaleFactor, // height of the button
                        width: 100 * MediaQuery.of(context).textScaleFactor, // width of the button
                        child: Center(
                            child: Text(
                          'Start',
                          style: TextStyle(
                            fontSize: 20 * MediaQuery.of(context).textScaleFactor,
                          ),
                        )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
