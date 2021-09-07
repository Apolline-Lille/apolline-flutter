import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsPanel extends StatefulWidget {
  final EdgeInsets padding = EdgeInsets.symmetric(horizontal: 20, vertical: 10);
  @override
  State<StatefulWidget> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: Wrap(
        children: [
          Card(
            child: Wrap(
              children: [
                Text("PM1"),
                ListTile(
                  title: Text("Warning threshold"),
                  trailing: Container(
                    width: 80,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      expands: false,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "15",
                        suffixIcon: Text("µm/m³")
                      ),
                    ),
                  ),
                )
              ],
            )
          )
        ],
      ),
    );
  }
}