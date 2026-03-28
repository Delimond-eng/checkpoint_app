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
    _isSyncing = true;

    try {
      final pendingActions = await LocalDbService.instance.getPendingActions();
      if (pendingActions.isEmpty) {
        _isSyncing = false;
        return;
      }

      final manager = HttpManager();

      for (var action in pendingActions) {
        // dynamic est utilisé ici car syncLocalAction peut renvoyer une Map ou une String
        final dynamic response = await manager.syncLocalAction(action);
        
        // On vérifie si la réponse est une Map pour accéder aux clés
        if (response is Map<String, dynamic>) {
          if (response.containsKey('id')) {
            final realId = response['id'].toString();
            final localSid = action['local_session_id'];
            
            if (localSid != null && localSid != "") {
              await LocalDbService.instance.updatePendingActionsId(localSid, realId);
            }
            
            await LocalDbService.instance.deletePendingAction(action['id']);
          }
        } 
        // Si c'est un succès simple (chaîne "success")
        else if (response == "success") {
          await LocalDbService.instance.deletePendingAction(action['id']);
        } 
        else {
          // Échec de synchro (chaîne "error" ou autre), on arrête pour préserver l'ordre
          break;
        }
      }
    } catch (e) {
      // Log error
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
