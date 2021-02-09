// Authors BARRY Issagha, GDISSA Ramy

//DateSynchromodel contient les dates
class DateSynchromodel {
  int date;

  /* Values received, parsed through a comma-separated string */
  List<String> values = [];

  ///
  ///constructor of senorModel.
  DateSynchromodel({this.date}) {}

  // Format Json of sensorModel
  Map<String, dynamic> toJSON() {
    var json = Map<String, dynamic>();
    json["dateSynchro"] = this.date;
    return json;
  }

  // ignore: non_constant_identifier_names
  // create object from Json
  DateSynchromodel.fromJson(Map<String, dynamic> json) : this(date: json['date']);
}
