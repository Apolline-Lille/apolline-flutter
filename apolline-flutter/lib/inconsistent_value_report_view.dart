import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class InconsistentValueReportView extends StatefulWidget {
  const InconsistentValueReportView({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return InconsistentValueReportViewState();
  }

}

class InconsistentValueReportViewState extends State<InconsistentValueReportView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("inconsistentReport.title".tr()),
      ),
      body: _buildForm(),
    );
  }

  Form _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Text("inconsistentReport.message".tr()),
          TextFormField(
            validator: (value) {
              if(value == null || value.isEmpty) {
                return "inconsistentReport.form.error".tr();
              }
              return null;
            },
          ),
          ElevatedButton(
              onPressed: () {
                if(_formKey.currentState.validate()) {
                  SnackBar snackBar = SnackBar(content: Text("inconsistentReport.form.valid".tr()));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  //TODO send data to db
                  Future.delayed(Duration(seconds: 0), () => Navigator.of(context).pop());
                }
              },
              child: Text("inconsistentReport.form.button".tr()),
          )
        ],
      ),
    );
  }

}