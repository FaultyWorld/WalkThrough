import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:walkthrough/model/ServerObject.dart';
import 'package:walkthrough/model/ColorChoice.dart';
import 'dart:math';

class AboutPage extends StatefulWidget {
  AboutPage({Key key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
  ScrollController scrollController;
  Color backgroundColor;
  LinearGradient backgroundGradient;
  Tween<Color> colorTween;
  int currentPage = 0;
  Color constBackColor;

  @override
  void initState() {
    super.initState();
    ColorChoice tempChoice =
        ColorChoices.choices[Random().nextInt(ColorChoices.choices.length)];
    Color tempColor = tempChoice.primary;
    LinearGradient tempGradient = LinearGradient(
        colors: tempChoice.gradient,
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter);
    colorTween = ColorTween(begin: tempColor, end: tempColor);
    backgroundColor = tempColor;
    backgroundGradient = tempGradient;
  }

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(gradient: backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: Text("About"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {},
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 20),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'Walk Through',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25)),
                      TextSpan(
                          text:
                              ' is a proxy client using Trojan protocol. This program is modified based on Igniter and is open source under the GPL v3 license agreement.\n'),
                      TextSpan(text: '\nAuthor:'),
                      TextSpan(text: ' FaultyWorld\n'),
                      TextSpan(
                          text: '\nOpen Source Licenses:\n',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22)),
                      TextSpan(text: 'trojan-gfw/igniter GPLv3\n'),
                      TextSpan(text: 'Dreamacro/clash GPLv3\n'),
                      TextSpan(text: 'eycorsican/go-tun2socks MIT\n'),
                    ],
                  ),
                )),
            Spacer(),
            Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Center(
                  child: Text(
                    "Vision: 0.1.0",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
