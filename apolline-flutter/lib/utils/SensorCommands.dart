abstract class SensorCommands {
  /// gets captor name.
  static List<int> get captorName {
    return "a".codeUnits;
  }

  /// reads the sensor's SD card.
  static List<int> get readingSD {
    return "b".codeUnits;
  }

  /// Enables live data transmission mode.
  static List<int> get enableLiveData {
    return "c".codeUnits;
  }

  /// Disables live data transmission mode.
  static List<int> get disableLiveData {
    return "d".codeUnits;
  }

  /// Deletes all data of sensor SD card.
  static List<int> get deleteSDData {
    return "e".codeUnits;
  }

  /// Refreshes internal clock with GPS.
  static List<int> get refreshGPS {
    return "f".codeUnits;
  }

  /// Enables live data transmission to serial link.
  static List<int> get enableLiveDataPC {
    return "g".codeUnits;
  }

  /// Disables live data transmission to serial link.
  static List<int> get disableLiveDataPC {
    return "h".codeUnits;
  }

  /// Synchronises internal clock.
  ///
  /// You should add the data frame with this format :
  /// `hour;minute;second;day;month;year`
  ///
  /// example :
  ///  ```dart
  ///   Sensor.write(List.from(SensorCommands.synchroniseInternalClock)..addAll("13;45;18;23;02;2022".codeUnits));
  ///  ```
  static List<int> get synchroniseInternalClock {
    return "i".codeUnits;
  }

  /// Reads all file names stored in sensor SD card.
  static List<int> get readingFilesName {
    return "m".codeUnits;
  }

  /// Reads all file names stored in sensor SD card from serial link.
  static List<int> get readingFilesNamePC {
    return "l".codeUnits;
  }

  /// Reads one file name content.
  ///
  /// You should add the name of the file.
  /// example :
  /// ```dart
  ///   Sensor.write(List.from(SensorCommands.readingOneFile)..addAll("22_02_23.CSV".codeUnits));
  /// ```
  static List<int> get readingOneFile {
    return "o".codeUnits;
  }

  /// Reads one file name content from serial link.
  ///
  /// You should add the name of the file.
  static List<int> get readingOneFilePC {
    return "n".codeUnits;
  }
}