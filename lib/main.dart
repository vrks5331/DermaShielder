import "./helpers/colorsSys.dart";
import "./helpers/strings.dart";
import "package:flutter/material.dart";
import 'package:flutter/widgets.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),

    )
  );
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    //_PageController = PageController(
        //initialPage: 0
    //);
    super.initState(); // initializes state
  }

  @override   // disposes the state
  void dispose() {
    //_pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right:20, top:20),
            child: Text(
              "Skip",
              style: TextStyle(
                color: ColorSys.gray,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          )

        ],
      )
    );
  }
}
