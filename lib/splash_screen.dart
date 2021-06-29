import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socketio/tela1.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        accentColor: Colors.blueAccent,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      title: 'Splash',
      home: SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<SplashPage> {
  double _width = 0;
  bool _livallVisible = false;
  bool _livall2Visible = false;

  @override
  void initState() {
    startTime();
    livallVisibleTime();

    super.initState();
  }

  startTime() async {
    Timer timer = Timer(Duration(seconds: 2), () {
      setState(() {
        _width = 165;
      });
    });
  }

  livallVisibleTime() async {
    Timer timer = Timer(Duration(milliseconds: 500), () {
      setState(() {
        _livallVisible = true;
      });
    });
  }

  navigateTime() async {
    Timer timer = Timer(Duration(seconds: 2), () {
      setState(() {
        _width = 165;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.black38,
        child: Padding(
          padding: const EdgeInsets.all(
            16,
          ),
          child: Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AnimatedOpacity(
                    opacity: _livallVisible ? 1 : 0,
                    duration: Duration(milliseconds: 500),
                    onEnd: () {
                      setState(() {
                        _livall2Visible = true;
                      });
                    },
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 150,
                        ),
                        child: Text(
                          'LIVALL',
                          style: GoogleFonts.daysOne(
                            textStyle: TextStyle(
                              color: Colors.red,
                              fontSize: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    width: _width,
                    height: 2,
                    duration: Duration(seconds: 1),
                    color: Colors.red,
                    onEnd: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                  ),
                  AnimatedOpacity(
                    opacity: _livall2Visible ? 1 : 0,
                    duration: Duration(milliseconds: 500),
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 10,
                        ),
                        child: Text(
                          'Redefine Your Safety',
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
