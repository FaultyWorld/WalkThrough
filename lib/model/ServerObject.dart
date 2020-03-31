import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'package:walkthrough/model/ColorChoice.dart';

enum ServerCardSettings { delete }

class ServerObject {
  ServerObject(String title, String remoteAddress, int remotePort,
      String remotePassword) {
    this.title = title;
    ColorChoice choice =
        ColorChoices.choices[Random().nextInt(ColorChoices.choices.length)];
    this.color = choice.primary;
    this.gradient = LinearGradient(
        colors: choice.gradient,
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter);
    this.uuid = Uuid().v1();
    this.remoteAddress = remoteAddress;
    this.remotePort = remotePort;
    this.remotePassword = remotePassword;
  }

  ServerObject.import(int sortID, String uuidS, String title,
      String remoteAddress, int remotePort, String remotePassword) {
    this.sortID = sortID;
    this.title = title;
    ColorChoice choice =
        ColorChoices.choices[Random().nextInt(ColorChoices.choices.length)];
    this.color = choice.primary;
    this.gradient = LinearGradient(
        colors: choice.gradient,
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter);
    this.uuid = uuidS;
    this.remoteAddress = remoteAddress;
    this.remotePort = remotePort;
    this.remotePassword = remotePassword;
  }

  factory ServerObject.fromMap(Map<String, dynamic> json) =>
      ServerObject.import(json['id'], json['uuid'], json['title'],
          json['remote'], json['port'], json['password']);

  String uuid;
  int sortID;
  String title;
  String remoteAddress;
  int remotePort;
  String remotePassword;
  Color color;
  LinearGradient gradient;
}
