import 'package:apollineflutter/services/user_configuration_service.dart';
import 'package:apollineflutter/utils/pm_filter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class PMCard extends StatefulWidget {
  final UserConfigurationService ucS;
  final PMFilter indicator;
  final List<TextInputFormatter> formatters =
    [TextInputFormatter.withFunction((oldValue, newValue) => newValue.text.length > 3 ? oldValue : newValue)];
  PMCard({@required this.ucS, @required this.indicator});

  @override
  State<StatefulWidget> createState() => _PMCardState();
}


class _PMCardState extends State<PMCard> {
  int warningThresholdValue = 0;
  int dangerThresholdValue = 0;
  bool isWarningValueCorrect = true;
  bool isDangerValueCorrect = true;

  @override
  void initState() {
    List<int> initialThresholdsValues = widget.ucS.userConf.getThresholds(widget.indicator);
    warningThresholdValue = initialThresholdsValues[0];
    dangerThresholdValue = initialThresholdsValues[1];
    isWarningValueCorrect = warningThresholdValue < dangerThresholdValue;
    isDangerValueCorrect = warningThresholdValue < dangerThresholdValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Card(
        margin: EdgeInsets.only(bottom: 20),
        color: !isWarningValueCorrect || !isDangerValueCorrect ? Color.fromRGBO(255, 227, 227, 1.0) : null,
        child: Wrap(
          children: [
            Container(
                padding: EdgeInsets.only(left: 15, top: 10, bottom: 20),
                child: Text(widget.indicator.getLabelKey().tr(), style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ))
            ),
            ListTile(
              title: Text("Warning threshold"),
              subtitle: isWarningValueCorrect ? null : Text("Warning threshold value must be inferior than danger threshold."),
              trailing: Container(
                width: 80,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: widget.formatters,
                  onChanged: (value) {
                    if (value.isEmpty) return;
                    setState(() {
                      isWarningValueCorrect = int.parse(value) < dangerThresholdValue;
                      isDangerValueCorrect = int.parse(value) < dangerThresholdValue;
                    });
                  },
                  initialValue: warningThresholdValue.toString(),
                  onFieldSubmitted: (value) {
                    if (value.isEmpty) return;
                    setState(() {
                      warningThresholdValue = int.parse(value);
                    });
                    widget.ucS.userConf.updatePMThreshold(widget.indicator, 0, int.parse(value));
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
              contentPadding: !isWarningValueCorrect || !isDangerValueCorrect ? EdgeInsets.only(left: 16, right: 16, bottom: 16) : null,
              subtitle: isDangerValueCorrect ? null : Text("Danger threshold value must be superior to warning threshold."),
              trailing: Container(
                width: 80,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: widget.formatters,
                  onChanged: (value) {
                    if (value.isEmpty) return;
                    setState(() {
                      isDangerValueCorrect = int.parse(value) > warningThresholdValue;
                      isWarningValueCorrect = int.parse(value) > warningThresholdValue;
                    });
                  },
                  initialValue: dangerThresholdValue.toString(),
                  onFieldSubmitted: (value) {
                    if (value.isEmpty) return;
                    setState(() {
                      dangerThresholdValue = int.parse(value);
                    });
                    widget.ucS.userConf.updatePMThreshold(widget.indicator, 1, int.parse(value));
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
}