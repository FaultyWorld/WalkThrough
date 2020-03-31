import 'dart:async';

import 'package:meta/meta.dart';
import 'package:walkthrough/data/server_manager.dart';
import 'package:bloc/bloc.dart';
import 'package:walkthrough/pages/home_page/home_events.dart';
import 'package:walkthrough/pages/home_page/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState>{
  final ServerManager serverManager;

  HomeBloc({ @required this.serverManager});

  @override
  HomeState get initialState => HomeStateLoading();

  @override
  Stream<HomeState> mapEventToState(
      HomeState currentState, HomeEvent event) async*{

    if(event is LoadServersEvent){
      yield HomeStateLoading();

      final data = await serverManager.loadAllServers();
      yield HomeStateLoaded(servers: data);
    }

    if(event is SaveServerEvent){
      yield HomeStateLoading();
      await serverManager.addNewServer(event.server);

      dispatch(LoadServersEvent());
    }

    if(event is DeleteServerEvent) {
      await serverManager.deleteTask(event.server);
    }

  }
}