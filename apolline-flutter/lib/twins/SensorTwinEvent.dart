enum SensorTwinEvent {
  history_data,
  live_data,
  sensor_disconnected
}

typedef void SensorTwinEventCallback (String data);