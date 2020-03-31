import 'package:equatable/equatable.dart';

import 'package:meta/meta.dart';
import 'package:walkthrough/model/ServerObject.dart';

class HomeState extends Equatable{
  HomeState([List tmp = const []]): super(tmp);
}

class HomeStateLoading extends HomeState{
  @override
  String toString() => 'HomeStateLoading';
}

class HomeStateLoaded extends HomeState{
  final List<ServerObject> servers;
  HomeStateLoaded({ @required this.servers}): super(servers);

  @override
  String toString() => 'HomeStateLoaded';
}