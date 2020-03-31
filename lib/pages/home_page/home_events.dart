import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:walkthrough/model/ServerObject.dart';

abstract class HomeEvent extends Equatable{
  HomeEvent([List tmp = const []]): super(tmp);
}

class LoadServersEvent extends HomeEvent{
  @override
  String toString() => 'LoadServersEvent';
}

class SaveServerEvent extends HomeEvent{
  final ServerObject server;
  SaveServerEvent({ @required this.server}): super([server]);

  @override
  String toString() => 'SaveServerEvent';
}

class DeleteServerEvent extends HomeEvent{
  final ServerObject server;
  DeleteServerEvent({ @required this.server}): super([server]);

  @override
  String toString() => 'DeleteServerEvent';
}