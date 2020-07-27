import 'package:flutter/material.dart';
import 'package:styloderento/loginscreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget build (BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      title: 'Material App',
      home: Scaffold(
        body: Container(
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/splash.jpg'
                    ),
                    fit: BoxFit.cover,
                  )
                )
              ),
              ProgressIndicator(),
            ]
          )
        )
      )
    );
  }
}

class ProgressIndicator extends StatefulWidget{
  ProgressIndicatorState createState() => new ProgressIndicatorState();
}

class ProgressIndicatorState extends State<ProgressIndicator> 
  with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 2000), vsync: this);
      animation = Tween(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        setState((){
          if (animation.value > 0.99) {
            Navigator.push(context,
              MaterialPageRoute(
                builder: (BuildContext context) => LoginScreen()
              )
            );
          }
        });
      });
      controller.repeat();
  }

  void dispose() {
    controller.stop();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return new Align(
      alignment: Alignment(0,0.4),
      child: Container(        
        child: CircularProgressIndicator(
          value: animation.value,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
          )
        )
    );
  }
}