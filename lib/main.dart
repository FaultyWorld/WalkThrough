import 'package:flutter/material.dart';
import 'package:walkthrough/pages/about_page.dart';
import 'package:walkthrough/pages/home_page/home_page.dart';
import 'package:walkthrough/data/database.dart';
import 'package:walkthrough/data/server_manager.dart';
import 'package:walkthrough/pages/home_page/home_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyDelegate extends BlocDelegate{
  @override
  void onTransition(Transition transition) {
    print(transition);
  }
}

void main() {
  BlocSupervisor().delegate = MyDelegate();

  DatabaseProvider dbProvider = DatabaseProvider.db;
  ServerManager serverManager = ServerManager(dbProvider: dbProvider);
  HomeBloc homeBloc = HomeBloc(serverManager: serverManager);

  runApp(new MyApp(
    homeBloc: homeBloc,
  ));
}

class MyApp extends StatefulWidget {
  final HomeBloc homeBloc;
  const MyApp({Key key, this.homeBloc}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void dispose() {
    widget.homeBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return BlocProvider<HomeBloc>(
      bloc: widget.homeBloc,
      child: MaterialApp(
        home: HomePage(homeBloc: widget.homeBloc,),
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) => HomePage(homeBloc: widget.homeBloc,),
          '/about': (BuildContext context) => AboutPage()
        },
      ),
    );
  }
}