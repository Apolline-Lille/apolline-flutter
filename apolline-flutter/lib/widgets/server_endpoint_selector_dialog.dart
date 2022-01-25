import 'package:apollineflutter/models/server_model.dart';
import 'package:apollineflutter/services/sqflite_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ServerEndpointSelectorDialog extends StatefulWidget {

  ServerEndpointSelectorDialog({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ServerEndpointSelectorDialogViewState();
  }

}

class ServerEndpointSelectorDialogViewState extends State<ServerEndpointSelectorDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController apiURLController = TextEditingController();
  TextEditingController pingURLController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController dbController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Select endpoint dialog") // Todo translate
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: apiURLController,
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return "Please enter some text";
                  }
                  return null;
                },
                decoration: InputDecoration(
                    label: Text("URL :"),
                    border: OutlineInputBorder()
                ),
              ),
              TextFormField(
                controller: pingURLController,
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return "Please enter some text";
                  }
                  return null;
                },
                decoration: InputDecoration(
                    label: Text("ping url :"),
                    border: OutlineInputBorder()
                ),
              ),
              TextFormField(
                controller: usernameController,
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return "Please enter some text";
                  }
                  return null;
                },
                decoration: InputDecoration(
                    label: Text("username :"),
                    border: OutlineInputBorder()
                ),
              ),
              TextFormField(
                controller: passwordController,
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return "Please enter some text";
                  }
                  return null;
                },
                decoration: InputDecoration(
                    label: Text("password :"),
                    border: OutlineInputBorder()
                ),
              ),
              TextFormField(
                controller: dbController,
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return "Please enter some text";
                  }
                  return null;
                },
                decoration: InputDecoration(
                    label: Text("db name :"),
                    border: OutlineInputBorder()
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    if(_formKey.currentState.validate()) {
                      ServerModel serverEndpoint = ServerModel(apiURLController.text, pingURLController.text, usernameController.text, passwordController.text, dbController.text);
                      SqfLiteService().addServerEndpoint(serverEndpoint);
                      Navigator.pop(context);
                    }
                  },
                  child: Text("submit"))
            ],
          ),
        )
    );
  }

}