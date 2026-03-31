import 'dart:async';
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

    try {
      final manager = HttpManager();

      while (true) {
        final pendingActions = await LocalDbService.instance.getPendingActions();
        if (pendingActions.isEmpty) break;

        var action = Map<String, dynamic>.from(pendingActions.first);
        final dynamic response = await manager.syncLocalAction(action);
        
        if (response is Map<String, dynamic>) {
          // LOGIQUE INTELLIGENTE D'ID : 
          // Si c'est un PatrolScan, l'ID de la patrouille est dans 'patrol_id'.
          // Si c'est une Patrol (creation), c'est dans 'id'.
          String? realPatrolId;
          if (response.containsKey('patrol_id')) {
            realPatrolId = response['patrol_id'].toString();
          } else if (response.containsKey('id')) {
            realPatrolId = response['id'].toString();
          }

          final localSid = action['local_session_id'];
          
          if (realPatrolId != null && localSid != null && localSid != "") {
            // Met à jour les autres actions de la même session locale avec l'ID réel du serveur
            await LocalDbService.instance.updatePendingActionsId(localSid, realPatrolId);
          }
          
          await LocalDbService.instance.deletePendingAction(action['id']);
        } 
        else if (response == "success") {
          await LocalDbService.instance.deletePendingAction(action['id']);
        } 
        else {
          // Échec : on arrête pour maintenir l'ordre chronologique
          break;
        }
      }
    } catch (e) {
      // Erreur silencieuse
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
