enum DeviceConnectionStatus {
  CONNECTED,
  DISCONNECTED,
  UNABLE_TO_CONNECT
}

class DeviceConnectionStatusHelper {
  static DeviceConnectionStatus fromConnectionStatus (bool status) {
    return status
        ? DeviceConnectionStatus.CONNECTED
        : DeviceConnectionStatus.DISCONNECTED;
  }
}