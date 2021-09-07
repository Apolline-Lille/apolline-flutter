import 'package:apollineflutter/utils/pm_filter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsPanel extends StatefulWidget {
  final EdgeInsets padding = EdgeInsets.symmetric(horizontal: 20, vertical: 10);
  final List<TextInputFormatter> formatters =
    [TextInputFormatter.withFunction((oldValue, newValue) => newValue.text.length > 3 ? oldValue : newValue)];

  @override
  State<StatefulWidget> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  Widget _buildPMCard (PMFilter indicator) {
    return Card(
        child: Wrap(
          children: [
            Container(
                padding: EdgeInsets.only(left: 15, top: 10, bottom: 20),
                child: Text(indicator.getLabel().tr(), style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ))
            ),
            ListTile(
              title: Text("Warning threshold"),
              trailing: Container(
                width: 80,
                child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: widget.formatters,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "15",
                      suffixIcon: Text("µm/m³")
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text("Danger threshold"),
              trailing: Container(
                width: 80,
                child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: widget.formatters,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "30",
                      suffixIcon: Text("µm/m³")
                  ),
                ),
              ),
            )
          ],
        )
    );
  }

  List<Widget> _buildAllPMCards () {
    return PMFilter.values.map((value) => _buildPMCard(value)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: ListView(
        children: _buildAllPMCards(),
      ),
    );
  }
}