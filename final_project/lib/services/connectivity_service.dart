import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    // The device is considered online if the list of results does not contain 'none'.
    return !result.contains(ConnectivityResult.none);
  }
}
