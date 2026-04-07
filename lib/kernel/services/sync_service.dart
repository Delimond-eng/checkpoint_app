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
    // 1. Verrouillage IMMEDIAT pour éviter les doubles exécutions
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.isEmpty || connectivityResult.every((r) => r == ConnectivityResult.none)) {
        _isSyncing = false;
        return;
      }

      tagsController.isLoading.value = true;
      final manager = HttpManager();

      while (true) {
        final pendingActions = await LocalDbService.instance.getPendingActions();
        if (pendingActions.isEmpty) break;

        var action = Map<String, dynamic>.from(pendingActions.first);
        final dynamic response = await manager.syncLocalAction(action);
        
        // Erreur réseau : on arrête et on libère le verrou pour la prochaine tentative
        if (response == null) break; 

        // Gestion des réponses serveur (succès ou erreur logique)
        if (response is Map) {
          var resMap = response as Map<String, dynamic>;
          
          if (resMap.containsKey('errors')) {
            // Supprimer pour ne pas bloquer la file si c'est une erreur définitive
            await LocalDbService.instance.deletePendingAction(action['id']);
            continue;
          }

          // Linking des IDs de patrouille
          String? realPatrolId;
          if (resMap['result'] != null && resMap['result'] is Map) {
            realPatrolId = (resMap['result']['patrol_id'] ?? resMap['result']['id'])?.toString();
          } else {
            realPatrolId = (resMap['patrol_id'] ?? resMap['id'] ?? resMap['result'])?.toString();
          }

          final localSid = action['local_session_id'];
          if (realPatrolId != null && localSid != null && localSid.isNotEmpty) {
            await LocalDbService.instance.updatePendingActionsId(localSid, realPatrolId);
          }
        }
        
        await LocalDbService.instance.deletePendingAction(action['id']);
        await Future.delayed(const Duration(milliseconds: 200)); // Délai augmenté pour la stabilité
      }
    } catch (e) {
      // Erreur
    } finally {
      _isSyncing = false;
      tagsController.isLoading.value = false;
      tagsController.refreshPending();
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
