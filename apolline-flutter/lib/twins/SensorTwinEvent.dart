enum SensorTwinEvent {
  history_data,
  live_data,

  sensor_connected,
  sensor_disconnected
}

typedef void SensorTwinEventCallback (data);