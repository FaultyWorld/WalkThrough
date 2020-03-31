import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:walkthrough/model/ServerObject.dart';

class NewServerPage extends StatefulWidget {
  @override
  _NewServerPageState createState() => _NewServerPageState();
}

class _NewServerPageState extends State<NewServerPage> {
  TextEditingController _titleController;
  TextEditingController _remoteController;
  TextEditingController _portController;
  TextEditingController _passwordController;
  final GlobalKey<FormState> _titleFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _remoteFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _portFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();

  static const int _maxTitleLength = 30;

 void _saveTaskAndClose() {
    String title = _titleController.text;
    String remote = _remoteController.text;
    String port = _portController.text;
    String password = _passwordController.text;

    if (_titleFormKey.currentState.validate() != false && _remoteFormKey.currentState.validate() != false && _portFormKey.currentState.validate() != false && _passwordFormKey.currentState.validate() != false) {
      var server = new ServerObject(
        title,
        remote,
        int.parse(port),
        password
      );

      Navigator.of(context).pop(server);
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: '');
    _remoteController = TextEditingController(text: '');
    _portController = TextEditingController(text: '');
    _passwordController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _remoteController.dispose();
    _portController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      color: Colors.white,
      margin: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Form(
                  key: _titleFormKey,
                  child: new TextFormField(
                    maxLength: _maxTitleLength,
                    maxLengthEnforced: true,
                    controller: _titleController,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                    validator: (String val) {
                      if (val.trim().isEmpty) return 'Title is required.';
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Title',
                        counterText: _maxTitleLength.toString(),
                        filled: true,
                        hasFloatingPlaceholder: false,
                        fillColor: Colors.white),
                  ),
                ),
                Form(
                  key: _remoteFormKey,
                  child: new TextFormField(
                    maxLengthEnforced: true,
                    controller: _remoteController,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                    validator: (String val) {
                      if (val.trim().isEmpty) return 'Remote address is required.';
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: 'Remote Address',
                        filled: true,
                        hasFloatingPlaceholder: false,
                        fillColor: Colors.white),
                  ),
                ),
                Form(
                  key: _portFormKey,
                  child: new TextFormField(
                    maxLengthEnforced: true,
                    controller: _portController,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                    validator: (String val) {
                      if (val.trim().isEmpty) return 'Port is required.';
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: 'Port',
                        filled: true,
                        hasFloatingPlaceholder: false,
                        fillColor: Colors.white),
                      inputFormatters: [
                        WhitelistingTextInputFormatter(RegExp("[0-9]")),
                      ],
                  ),
                ),
                Form(
                  key: _passwordFormKey,
                  child: new TextFormField(
                    maxLengthEnforced: true,
                    controller: _passwordController,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                    validator: (String val) {
                      if (val.trim().isEmpty) return 'Password is required.';
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: 'Password',
                        filled: true,
                        hasFloatingPlaceholder: false,
                        fillColor: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: _saveTaskAndClose,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 50,
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'Save'.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}