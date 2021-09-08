import 'package:apollineflutter/services/user_configuration_service.dart';
import 'package:apollineflutter/utils/pm_filter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsPanel extends StatefulWidget {
  final EdgeInsets padding = EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 10);
  final List<TextInputFormatter> formatters =
    [TextInputFormatter.withFunction((oldValue, newValue) => newValue.text.length > 3 ? oldValue : newValue)];
  final UserConfigurationService ucS;

  SettingsPanel({@required this.ucS});

  @override
  State<StatefulWidget> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  Widget _buildPMCard (PMFilter indicator) {
    List<int> initialThresholdsValues = widget.ucS.userConf.getThresholds(indicator);

    return Card(
      margin: EdgeInsets.only(bottom: 20),
      child: Wrap(
        children: [
          Container(
              padding: EdgeInsets.only(left: 15, top: 10, bottom: 20),
              child: Text(indicator.getLabelKey().tr(), style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold
              ))
          ),
          ListTile(
            title: Text("Warning threshold"),
            trailing: Container(
              width: 80,
              child: TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: widget.formatters,
                initialValue: initialThresholdsValues[0].toString(),
                onFieldSubmitted: (value) {
                  widget.ucS.userConf.updatePMThreshold(indicator, 0, int.parse(value));
                  widget.ucS.update();
                },
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
              child: TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: widget.formatters,
                initialValue: initialThresholdsValues[1].toString(),
                onFieldSubmitted: (value) {
                  widget.ucS.userConf.updatePMThreshold(indicator, 1, int.parse(value));
                  widget.ucS.update();
                },
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
      child: ListView(
        children: _buildAllPMCards(),
        padding: widget.padding
      ),
    );
  }
}