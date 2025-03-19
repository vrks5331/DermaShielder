import 'package:DermaShielder/pages/home_page.dart';
import 'package:DermaShielder/pages/intro_screens/page_1.dart';
import 'package:DermaShielder/pages/intro_screens/page_2.dart';
import 'package:DermaShielder/pages/intro_screens/page_3.dart';
import 'package:DermaShielder/pages/login_page.dart';
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

  // keep track of if we are on the last page or not
  bool onLastPage = false;

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: [
              IntroPage1(),
              IntroPage2(),
              IntroPage3()
            ],
          ),
          Container(
              alignment: Alignment(0,0.75),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //skip
                  GestureDetector(
                      onTap: () {
                        _controller.jumpToPage(2);
                      },
                      child: Text("Skip"),
                  ),
                  SmoothPageIndicator(controller: _controller, count: 3),
                  //next or done
                  onLastPage ?
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) {
                              return LoginPage();
                            })
                        );
                      },
                    child: Text("Done")
                  ): GestureDetector(
                      onTap: () {
                        _controller.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeIn
                        );
                      },
                      child: Text("Next")
                  )
                ]
              )
          )
        ],
      )
    );
  }
}
