import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? socket;

  void connect({
    required String baseUrl,
    required int driverId,
    required Function(List<dynamic>) onSyncRides,
    Function()? onNewRide,
    Function()? onEmptyRide,
  }) {
    if (socket != null && socket!.connected) {
      print("⚠️ Socket already connected");
      return;
    }

    socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setPath('/socket.io/')
          .setTransports(['websocket']) // 🔥 CHANGE HERE
          .setTimeout(20000)
          .disableAutoConnect()
          .build(),
    );

    // 🔹 listeners FIRST
    socket!.onConnect((_) {
      print("✅ Socket connected");
      socket!.emit("JOIN_DRIVER", driverId);
    });

    socket!.onConnectError((err) {
      print("❌ Connect error: $err");
    });

    socket!.onError((err) {
      print("❌ Socket error: $err");
    });

    socket!.onAny((event, data) {
      print("📡 EVENT: $event | DATA: $data");
    });

    socket!.on("SYNC_RIDES", (rides) {
      print("🔄 SYNC_RIDES: $rides");

      onSyncRides(List<dynamic>.from(rides));

      if (rides != null && rides.isNotEmpty) {
        onNewRide?.call();
      } else {
        onEmptyRide?.call();
      }
    });

    socket!.on("NEW_RIDE", (data) {
      print("🚖 NEW_RIDE: $data");
      onNewRide?.call();
    });

    socket!.on("REMOVE_RIDE", (data) {
      print("🧹 REMOVE_RIDE: $data");
      onEmptyRide?.call();
    });

    // 🔹 NOW connect
    socket!.connect();
  }
  void disconnect() {
    if (socket != null) {
      print("🛑 Disconnecting socket...");
      socket!.disconnect();
      socket!.dispose();
      socket = null;
    }
  }

}
