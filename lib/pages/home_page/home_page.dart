import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walkthrough/model/ServerObject.dart';
import 'package:walkthrough/model/ColorChoice.dart';
import 'package:walkthrough/pages/home_page/home_bloc.dart';
import 'package:walkthrough/pages/home_page/home_events.dart';
import 'package:walkthrough/pages/home_page/home_state.dart';
import 'package:walkthrough/pages/new_server_page.dart';
import 'package:walkthrough/pages/bottom_sheet.dart';
import 'dart:math';

List<ServerObject> servers = [];

class HomePage extends StatefulWidget {
  final HomeBloc homeBloc;
  const HomePage({@required this.homeBloc}) : assert(homeBloc != null);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  HomeBloc get _homeBloc => widget.homeBloc;

  ScrollController scrollController;
  Color backgroundColor;
  LinearGradient backgroundGradient;
  Tween<Color> colorTween;
  int currentPage = 0;
  Color constBackColor;

  void _openBottomSheet() async {
    final newServer = await showCustomModalBottomSheet<ServerObject>(
        context: context,
        builder: (context) {
          return GestureDetector(
            onTap: () {},
            child: Container(
              color: Color(0xFF737373),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: NewServerPage(),
              ),
            ),
          );
        });

    if (newServer != null) {
      _homeBloc.dispatch(SaveServerEvent(server: newServer));
    }
  }

  @override
  void initState() {
    _homeBloc.dispatch(LoadServersEvent());
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
    scrollController = ScrollController();
    scrollController.addListener(() {
      ScrollPosition position = scrollController.position;
//      ScrollDirection direction = position.userScrollDirection;
      int page = position.pixels ~/ (position.maxScrollExtent / (servers.length.toDouble() - 1));
      double pageDo = (position.pixels / (position.maxScrollExtent / (servers.length.toDouble() - 1)));
      double percent = pageDo - page;
      if (servers.length - 1 < page + 1) {
        return;
      }
      colorTween.begin = servers[page].color;
      colorTween.end = servers[page + 1].color;
      setState(() {
        backgroundColor = colorTween.transform(percent);
        backgroundGradient = servers[page].gradient.lerpTo(servers[page + 1].gradient, percent);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(gradient: backgroundGradient),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: Text("Walk Through"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              Navigator.pushNamed(context, "/about");
            },
          ),
          actions: <Widget>[
            new PopupMenuButton(
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                new PopupMenuItem(
                    value: "Add Server", child: new Text("Add Server")),
                new PopupMenuItem(
                    value: "Test Connection",
                    child: new Text("Test Connection")),
              ],
              onSelected: (String value) {
                setState(() {
                  print(value);
                  if (value == "Add Server") {
                    _openBottomSheet();
                  } else if (value == "Test Connection"){
                    _testConnection(context);
                  }
                });
              },
              icon: Icon(Icons.menu),
            ),
          ],
        ),
        body: Container(
          child: BlocBuilder<HomeEvent, HomeState>(
              bloc: _homeBloc,
              builder: (BuildContext context, state) {
                if (state is HomeStateLoading)
                  return Center(child: CircularProgressIndicator());

                if (state is HomeStateLoaded) {
                  servers = state.servers;

                  if (servers.isEmpty)
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('No Servers',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Text('Add a new server and it\nwill show up here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                              ))
                        ],
                      ),
                    );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Spacer(
                        flex: 2,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Text(
                          "Be wise.",
                          style: TextStyle(color: Colors.white, fontSize: 30.0),
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Text(
                          "Walk Through is a beautiful Trojan client based on Flutter.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Text(
                          "Use it while taking your responsibility.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 20.0,
                        ),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Click one to connect or disconnect.",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Spacer(),
                      Expanded(
                        flex: 20,
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            ServerObject serverObject = servers[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                  left: 10.0, right: 10.0, bottom: 30.0),
                              child: InkWell(
                                onTap: () {
                                  _switchProxy(
                                      context,
                                      serverObject.remoteAddress,
                                      serverObject.remotePort,
                                      serverObject.remotePassword);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black.withAlpha(70),
                                            offset: Offset(3.0, 10.0),
                                            blurRadius: 15.0)
                                      ]),
                                  height: 250.0,
                                  child: Stack(
                                    children: <Widget>[
                                      Hero(
                                        tag: serverObject.uuid + "_background",
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Expanded(
                                              flex: 10,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Stack(
                                                    children: <Widget>[
                                                      Hero(
                                                        tag: serverObject.uuid +
                                                            "_title",
                                                        child: Container(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Text(
                                                              serverObject
                                                                  .title,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      25.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Spacer(),
                                                  Hero(
                                                    tag: serverObject.uuid +
                                                        "_more_vert",
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      type: MaterialType
                                                          .transparency,
                                                      child: PopupMenuButton(
                                                        icon: Icon(
                                                          Icons.more_vert,
                                                          color: Colors.grey,
                                                        ),
                                                        itemBuilder: (context) => <
                                                            PopupMenuEntry<
                                                                ServerCardSettings>>[
                                                          PopupMenuItem(
                                                            child:
                                                                Text("Delete"),
                                                            value:
                                                                ServerCardSettings
                                                                    .delete,
                                                          ),
                                                        ],
                                                        onSelected: (setting) {
                                                          switch (setting) {
                                                            case ServerCardSettings
                                                                .delete:
                                                              print(
                                                                  "delete clicked");
                                                              setState(() {
                                                                _homeBloc.dispatch(DeleteServerEvent(server: serverObject));
                                                                servers.remove(
                                                                    serverObject);
                                                              });
                                                              break;
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Hero(
                                              tag: serverObject.uuid +
                                                  "_remote_address",
                                              child: Material(
                                                  color: Colors.transparent,
                                                  child: Text(
                                                    "Remote: " +
                                                        serverObject
                                                            .remoteAddress,
                                                    style: TextStyle(
                                                        fontSize: 18.0),
                                                    softWrap: false,
                                                    overflow: TextOverflow.fade,
                                                  )),
                                            ),
                                            Hero(
                                              tag: serverObject.uuid +
                                                  "_remote_port",
                                              child: Material(
                                                  color: Colors.transparent,
                                                  child: Text(
                                                    "Port: " +
                                                        serverObject.remotePort
                                                            .toString(),
                                                    style: TextStyle(
                                                        fontSize: 18.0),
                                                    softWrap: false,
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          padding: EdgeInsets.only(left: 12.0, right: 12.0),
                          scrollDirection: Axis.horizontal,
                          physics: _CustomScrollPhysics(),
                          controller: scrollController,
                          itemExtent: _width - 80,
                          itemCount: servers.length,
                        ),
                      ),
                    ],
                  );
                } else {
                  return SizedBox.shrink();
                }
              }),
        ),
      ),
    );
  }

  Future<String> _switchProxy(BuildContext context, String remoteAddress,
      int remotePort, String remotePassword) async {
    try {
      const platform = const MethodChannel('walk_through');
      var serverDetail = [remoteAddress, remotePort, remotePassword];
      final String result =
          await platform.invokeMethod('switchProxy', serverDetail);
      print(result);
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(result), duration: Duration(seconds: 1)));
      return result;
    } on PlatformException catch (e) {
      print('Error: $e.code\nError Message: $e.message');
      return e.toString();
    }
  }

  Future<String> _testConnection(BuildContext context) async {
    try {
      const platform = const MethodChannel('walk_through');
      final String result =
      await platform.invokeMethod('testConnection');
      print(result);
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text(result), duration: Duration(seconds: 2)));
      return result;
    } on PlatformException catch (e) {
      print('Error: $e.code\nError Message: $e.message');
      return e.toString();
    }
  }
}

class _CustomScrollPhysics extends ScrollPhysics {
  _CustomScrollPhysics({
    ScrollPhysics parent,
  }) : super(parent: parent);

  @override
  _CustomScrollPhysics applyTo(ScrollPhysics ancestor) {
    return _CustomScrollPhysics(parent: buildParent(ancestor));
  }

  double _getPage(ScrollPosition position) {
    return position.pixels /
        (position.maxScrollExtent / (servers.length.toDouble() - 1));
    // return position.pixels / position.viewportDimension;
  }

  double _getPixels(ScrollPosition position, double page) {
    // return page * position.viewportDimension;
    return page * (position.maxScrollExtent / (servers.length.toDouble() - 1));
  }

  double _getTargetPixels(
      ScrollPosition position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity)
      page -= 0.5;
    else if (velocity > tolerance.velocity) page += 0.5;
    return _getPixels(position, page.roundToDouble());
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent))
      return super.createBallisticSimulation(position, velocity);
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels)
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    return null;
  }
}
