enum DeviceConnectionStatus {
  CONNECTED,
  DISCONNECTED,
  INCOMPATIBLE,
  UNABLE_TO_CONNECT,
}

class DeviceConnectionStatusHelper {
  static DeviceConnectionStatus fromConnectionStatus (bool status) {
    return status
        ? DeviceConnectionStatus.CONNECTED
        : DeviceConnectionStatus.DISCONNECTED;
  }
}