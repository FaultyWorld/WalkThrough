import 'dart:async';

import 'package:walkthrough/data/database.dart';
import 'package:walkthrough/model/ServerObject.dart';

class ServerManager {

  final DatabaseProvider dbProvider;

  ServerManager({ this.dbProvider});

  Future<void> addNewServer(ServerObject server) async {
    return dbProvider.insert(server);
  }

  Future<List<ServerObject>> loadAllServers() async {
    return dbProvider.getAll();
  }

  Future<void> deleteTask(ServerObject server) async {
    return dbProvider.delete(server.sortID);
  }
}
