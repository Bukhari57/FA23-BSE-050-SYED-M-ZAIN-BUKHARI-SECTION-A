import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:final_project/data/local/offline_user_dao.dart';
import 'package:final_project/services/auth_service.dart';
import 'package:final_project/services/connectivity_service.dart';
import 'package:final_project/sync/sync_manager.dart';

class SyncService {
  final ConnectivityService _connectivityService = ConnectivityService();
  final OfflineUserDao _offlineUserDao = OfflineUserDao();
  final AuthService _authService = AuthService();
  final SyncManager _syncManager = SyncManager();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  Timer? _timer;

  void start() {
    _connectivitySubscription = _connectivityService.onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        _syncOfflineUsers();
        _syncProducts();
        _syncSales();
      }
    });

    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _syncProducts();
      _syncSales();
    });
  }

  void stop() {
    _connectivitySubscription.cancel();
    _timer?.cancel();
  }

  Future<void> _syncOfflineUsers() async {
    final offlineUsers = await _offlineUserDao.getOfflineUsers();
    for (var userData in offlineUsers) {
      try {
        final user = await _authService.signup(
          userData['name'],
          userData['email'],
          userData['password'],
        );
        if (user != null) {
          await _offlineUserDao.deleteUser(userData['id']);
        }
      } catch (e) {
        // In a real app, you would log this error to a remote logging service
      }
    }
  }

  Future<void> _syncProducts() async {
    await _syncManager.syncProducts();
  }

  Future<void> _syncSales() async {
    await _syncManager.syncSales();
  }
}
