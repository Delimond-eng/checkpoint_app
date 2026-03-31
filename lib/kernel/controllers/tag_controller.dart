import 'dart:async';
import 'dart:io';

import '/global/store.dart';
import '/global/controllers.dart';
import '/kernel/models/area.dart';
import '/kernel/models/user.dart';
import '/kernel/models/planning.dart';
import '/kernel/models/announce.dart';
import '/kernel/services/http_manager.dart';
import '/kernel/services/local_db_service.dart';
import '/kernel/services/alarm_service.dart';
import '/kernel/services/sync_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class TagsController extends GetxController with WidgetsBindingObserver {
  static TagsController instance = Get.find();

  var scannedArea = Area().obs;
  var scannedSite = Site().obs;
  var isQrcodeScanned = false.obs;
  var patrolId = 0.obs;
  var isOfflinePatrolActive = false.obs;
  var isLoading = false.obs;
  var isScanningModalOpen = false.obs;
  var mediaFile = Rx<File?>(null);
  var face = Rx<XFile?>(null);
  var faceResult = "".obs;
  var isFlashOn = false.obs;
  var cameraIndex = 1.obs;
  var planningId = "".obs;
  
  var announceCount = 0.obs;
  var pendingPlanningCount = 0.obs;
  var nextPlanning = Rxn<Planning>();
  
  var plannings = <Planning>[].obs;
  var announces = <Announce>[].obs;

  StreamSubscription<List<Map<String, dynamic>>>? _patrolStreamSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool get hasActivePatrol => patrolId.value != 0 || isOfflinePatrolActive.value;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    isOfflinePatrolActive.value = localStorage.read("is_offline_patrol") ?? false;
  }

  @override
  void onReady() async {
    super.onReady();
    _startPatrolStream();
    await _loadLocalData();

    fetchAnnouncesAndPlannings();

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        fetchAnnouncesAndPlannings();
        SyncService.instance.syncPendingActions();
      }
    });

    ever(authController.userSession, (user) {
      if (user != null && user.id != null) {
        fetchAnnouncesAndPlannings();
      }
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _patrolStreamSubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchAnnouncesAndPlannings();
      SyncService.instance.syncPendingActions();
    }
  }

  void _startPatrolStream() {
    const Duration interval = Duration(seconds: 45);
    _patrolStreamSubscription = Stream.periodic(interval).asyncMap((_) async {
      try {
        var connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.isEmpty || connectivityResult.every((r) => r == ConnectivityResult.none)) return <Map<String, dynamic>>[];

        if (authController.userSession.value != null && authController.userSession.value?.id != null) {
          return await HttpManager().checkPending();
        }
        return <Map<String, dynamic>>[];
      } catch (e) {
        return <Map<String, dynamic>>[];
      }
    }).listen((pendingPatrols) {
      if (pendingPatrols.isEmpty) {
        Connectivity().checkConnectivity().then((result) {
          if (result.any((r) => r != ConnectivityResult.none)) {
             if (!isOfflinePatrolActive.value) {
                localStorage.remove("patrol_id");
                patrolId.value = 0;
             }
          }
        });
      } else {
        final first = pendingPatrols.first;
        final newId = first["id"] ?? 0;
        if (patrolId.value != newId) {
          patrolId.value = newId;
          localStorage.write("patrol_id", newId);
          if (isOfflinePatrolActive.value) {
            isOfflinePatrolActive.value = false;
            localStorage.write("is_offline_patrol", false);
          }
        }
      }
    });
  }

  Future<void> _loadLocalData() async {
    final localPlannings = await LocalDbService.instance.getLocalPlannings();
    final localAnnounces = await LocalDbService.instance.getLocalAnnounces();
    
    announces.assignAll(localAnnounces);
    announceCount.value = localAnnounces.length;
    
    if (localPlannings.isNotEmpty) {
      plannings.assignAll(_sortPlannings(localPlannings));
      pendingPlanningCount.value = localPlannings.length;
      _updateNextPlanning(localPlannings);
      await AlarmService.instance.scheduleAlarms(localPlannings);
    }
  }

  List<Planning> _sortPlannings(List<Planning> list) {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final todaySlashStr = DateFormat('dd/MM/yyyy').format(now);

    list.sort((a, b) {
      bool aIsPast = false;
      if ((a.date == todayStr || a.date == todaySlashStr) && a.endTime != null) {
        try {
          final parts = a.endTime!.split(':');
          final end = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
          aIsPast = now.isAfter(end);
        } catch (_) {}
      }

      bool bIsPast = false;
      if ((b.date == todayStr || b.date == todaySlashStr) && b.endTime != null) {
        try {
          final parts = b.endTime!.split(':');
          final end = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
          bIsPast = now.isAfter(end);
        } catch (_) {}
      }

      if (!aIsPast && bIsPast) return -1;
      if (aIsPast && !bIsPast) return 1;

      try {
        DateTime dateA = a.date!.contains('/') ? DateFormat('dd/MM/yyyy').parse(a.date!) : DateTime.parse(a.date!);
        DateTime dateB = b.date!.contains('/') ? DateFormat('dd/MM/yyyy').parse(b.date!) : DateTime.parse(b.date!);
        int dateComp = dateA.compareTo(dateB);
        if (dateComp != 0) return dateComp;
        return a.startTime!.compareTo(b.startTime!);
      } catch (_) {
        return 0;
      }
    });
    return list;
  }

  Future<void> fetchAnnouncesAndPlannings() async {
    if (authController.userSession.value == null || authController.userSession.value?.id == null) return;
    
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.isEmpty || connectivityResult.every((r) => r == ConnectivityResult.none)) {
      await _loadLocalData();
      return;
    }

    try {
      // 1. Récupérer les IDs des plannings déjà en cours localement (non encore synchronisés)
      final pendingActions = await LocalDbService.instance.getPendingActions();
      final locallyConsumedIds = pendingActions
          .map((a) => a['schedule_id']?.toString())
          .where((id) => id != null && id.isNotEmpty)
          .toSet();

      // 2. Récupérer les annonces
      final remoteAnnounces = await HttpManager.getAllAnnounces();
      await LocalDbService.instance.saveAnnounces(remoteAnnounces);
      
      // 3. Récupérer les plannings du serveur
      final remotePlannings = await HttpManager.getAllPlannings();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // 4. Filtrer : Exclure ceux déjà consommés en local ET ceux passés avant aujourd'hui
      final filteredPlannings = remotePlannings.where((p) {
        // Ignorer si déjà entamé en offline
        if (locallyConsumedIds.contains(p.id.toString())) return false;
        
        try {
          DateTime pDate = p.date!.contains('/') 
              ? DateFormat('dd/MM/yyyy').parse(p.date!)
              : DateTime.parse(p.date!);
          return !pDate.isBefore(today);
        } catch (_) {
          return true;
        }
      }).toList();
      
      // 5. Sauvegarder et recharger
      await LocalDbService.instance.savePlannings(filteredPlannings);
      await _loadLocalData();
      
    } catch (e) {
      await _loadLocalData();
    }
  }

  Future<void> removePlanningLocally(int id) async {
    await LocalDbService.instance.deletePlanning(id);
    plannings.removeWhere((p) => p.id == id);
    pendingPlanningCount.value = plannings.length;
    _updateNextPlanning(plannings);
  }

  void _updateNextPlanning(List<Planning> planningsList) {
    if (planningsList.isEmpty) {
      nextPlanning.value = null;
      return;
    }

    try {
      final now = DateTime.now();
      final list = List<Planning>.from(planningsList);
      
      list.sort((a, b) {
        DateTime dateA = a.date!.contains('/') ? DateFormat('dd/MM/yyyy').parse(a.date!) : DateTime.parse(a.date!);
        DateTime dateB = b.date!.contains('/') ? DateFormat('dd/MM/yyyy').parse(b.date!) : DateTime.parse(b.date!);
        int dateComp = dateA.compareTo(dateB);
        if (dateComp != 0) return dateComp;
        return a.startTime!.compareTo(b.startTime!);
      });

      nextPlanning.value = list.firstWhere((p) {
        DateTime pDate = p.date!.contains('/') ? DateFormat('dd/MM/yyyy').parse(p.date!) : DateTime.parse(p.date!);
        DateTime start = DateTime(pDate.year, pDate.month, pDate.day, 
            int.parse(p.startTime!.split(':')[0]), 
            int.parse(p.startTime!.split(':')[1]));
        return start.isAfter(now);
      }, orElse: () => list.first);
    } catch (e) {
      nextPlanning.value = planningsList.isNotEmpty ? planningsList.first : null;
    }
  }

  void refreshPending() {
    var patrolIdLocal = localStorage.read("patrol_id");
    patrolId.value = patrolIdLocal ?? 0;
    isOfflinePatrolActive.value = localStorage.read("is_offline_patrol") ?? false;
  }
}
