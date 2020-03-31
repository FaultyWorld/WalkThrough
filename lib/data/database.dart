import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:walkthrough/model/ServerObject.dart';

class DatabaseProvider{

  DatabaseProvider._();

  static final DatabaseProvider db = DatabaseProvider._();
  static Database _database;

  Future<Database> get database async{
    if(_database != null){
      return _database;
    }

    _database = await initDb();
    return _database;
  }

  initDb() async{

    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'walkthrough.db');

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute('CREATE TABLE Server ('
              'id INTEGER PRIMARY KEY,'
              'uuid TEXT,'
              'title TEXT,'
              'remote TEXT,'
              'port INTEGER,'
              'password TEXT'
              ')');
        }
    );
  }

  insert(ServerObject server) async{
    print('Saving servers...');

    var db = await database;

    var table = await db.rawQuery('SELECT MAX(id)+1 as id FROM Server');
    var id = table.first['id'];

    var raw = db.rawInsert(
        'INSERT Into Server (id, uuid, title, remote, port, password) VALUES (?,?,?,?,?,?)',
        [id, server.uuid, server.title, server.remoteAddress, server.remotePort, server.remotePassword]
    );

    print('Servers saved.');
    return raw;
  }

  Future<List<ServerObject>> getAll() async {
    print('Getting servers...');

    var db = await database;
    var query = await db.query('Server');

    List<ServerObject> servers = query.isNotEmpty ?
        query.map((t) => ServerObject.fromMap(t)).toList() : [ ];

    print('Servers in database: ${servers.length}');
    return servers;
  }

  Future<void> delete(int id) async {
    var db = await database;
     await db.rawDelete('DELETE FROM Server WHERE id = ?', [id]);
  }
}