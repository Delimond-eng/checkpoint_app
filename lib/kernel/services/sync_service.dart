import 'dart:async';
import '/global/controllers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '/kernel/services/http_manager.dart';
import '/kernel/services/local_db_service.dart';

class SyncService {
  static final SyncService instance = SyncService._init();
  SyncService._init();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  void start() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        syncPendingActions();
      }
    });
  }

  Future<void> syncPendingActions() async {
    if (_isSyncing) return;
    
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.isEmpty || connectivityResult.every((r) => r == ConnectivityResult.none)) return;

    _isSyncing = true;
    tagsController.isLoading.value = true; // Activer le loading global

    try {
      final manager = HttpManager();

      while (true) {
        final pendingActions = await LocalDbService.instance.getPendingActions();
        if (pendingActions.isEmpty) break;

        var action = Map<String, dynamic>.from(pendingActions.first);
        final dynamic response = await manager.syncLocalAction(action);
        
        if (response is Map<String, dynamic>) {
          String? realPatrolId;
          if (response.containsKey('patrol_id')) {
            realPatrolId = response['patrol_id'].toString();
          } else if (response.containsKey('id')) {
            realPatrolId = response['id'].toString();
          }

          final localSid = action['local_session_id'];
          if (realPatrolId != null && localSid != null && localSid != "") {
            await LocalDbService.instance.updatePendingActionsId(localSid, realPatrolId);
          }
          await LocalDbService.instance.deletePendingAction(action['id']);
        } 
        else if (response == "success") {
          await LocalDbService.instance.deletePendingAction(action['id']);
        } 
        else {
          break;
        }
      }
    } catch (e) {
      // Erreur silencieuse
    } finally {
      _isSyncing = false;
      tagsController.isLoading.value = false; // Désactiver le loading global
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
