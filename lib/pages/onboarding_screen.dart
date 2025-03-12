import 'package:DermaShielder/pages/intro_screens/page_1.dart';
import 'package:DermaShielder/pages/intro_screens/page_2.dart';
import 'package:DermaShielder/pages/intro_screens/page_3.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {

  // controller to keep track of current page
  PageController _controller = PageController();

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            children: [
              IntroPage1(),
              IntroPage2(),
              IntroPage3()
            ],
          ),
          Container(
              alignment: Alignment(0,0.75),
              child: Row(
                children: [
                  //skip
                  GestureDetector(
                      onTap: () {
                        _controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                      },
                      child: Text("Skip"),
                  ),
                  SmoothPageIndicator(controller: _controller, count: 3),
                  //next or done
                  (_controller.page == 2) ? Text("Done") : Text("Skip")
                ],
              )
          )
        ],
      )
    );
  }
}
