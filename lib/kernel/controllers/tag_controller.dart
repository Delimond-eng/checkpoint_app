import 'dart:async';
import 'dart:io';

import '/global/store.dart';
import '/global/controllers.dart';
import '/kernel/models/area.dart';
import '/kernel/models/user.dart';
import '/kernel/models/planning.dart';
import '/kernel/services/http_manager.dart';
import '/kernel/services/local_db_service.dart';
import '/kernel/services/alarm_service.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class TagsController extends GetxController {
  static TagsController instance = Get.find();

  var scannedArea = Area().obs;
  var scannedSite = Site().obs;
  var isQrcodeScanned = false.obs;
  var patrolId = 0.obs;
  var isOfflinePatrolActive = false.obs; // Flag pour la patrouille offline
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

  StreamSubscription<List<Map<String, dynamic>>>? _patrolStreamSubscription;
  Timer? _dataRefreshTimer;

  // Getter intelligent pour savoir si une patrouille est en cours (online ou offline)
  bool get hasActivePatrol => patrolId.value != 0 || isOfflinePatrolActive.value;

  @override
  void onInit() {
    super.onInit();
    // Restaurer l'état offline si besoin
    isOfflinePatrolActive.value = localStorage.read("is_offline_patrol") ?? false;
  }

  @override
  void onReady() {
    super.onReady();
    _startPatrolStream();
    _loadLocalData();

    ever(authController.userSession, (user) {
      if (user != null && user.id != null) {
        fetchAnnouncesAndPlannings();
      }
    });

    _startDataRefreshTimer();
  }

  @override
  void onClose() {
    _patrolStreamSubscription?.cancel();
    _dataRefreshTimer?.cancel();
    super.onClose();
  }

  void _startPatrolStream() {
    const Duration interval = Duration(seconds: 30);
    _patrolStreamSubscription = Stream.periodic(interval).asyncMap((_) async {
      try {
        var connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) return <Map<String, dynamic>>[];

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
          if (result != ConnectivityResult.none) {
             // On ne réinitialise que si on n'a pas de patrouille offline en cours
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
          // Si on récupère un ID réel, on peut potentiellement couper le flag offline
          if (isOfflinePatrolActive.value) {
            isOfflinePatrolActive.value = false;
            localStorage.write("is_offline_patrol", false);
          }
        }
      }
    });
  }

  void _startDataRefreshTimer() {
    _dataRefreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      fetchAnnouncesAndPlannings();
    });
  }

  Future<void> _loadLocalData() async {
    final localPlannings = await LocalDbService.instance.getLocalPlannings();
    if (localPlannings.isNotEmpty) {
      plannings.assignAll(localPlannings);
      pendingPlanningCount.value = localPlannings.length;
      _updateNextPlanning(localPlannings);
      await AlarmService.instance.scheduleAlarms(localPlannings);
    }
  }

  Future<void> fetchAnnouncesAndPlannings() async {
    if (authController.userSession.value == null || authController.userSession.value?.id == null) return;
    
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      await _loadLocalData();
      return;
    }

    try {
      final announces = await HttpManager.getAllAnnounces();
      announceCount.value = announces.length;
      
      final remotePlannings = await HttpManager.getAllPlannings();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final validPlannings = remotePlannings.where((p) {
        try {
          DateTime pDate = p.date!.contains('/') 
              ? DateFormat('dd/MM/yyyy').parse(p.date!)
              : DateTime.parse(p.date!);
          return !pDate.isBefore(today);
        } catch (_) {
          return true;
        }
      }).toList();
      
      await LocalDbService.instance.savePlannings(validPlannings);
      plannings.assignAll(validPlannings);
      pendingPlanningCount.value = validPlannings.length;
      _updateNextPlanning(validPlannings);
      await AlarmService.instance.scheduleAlarms(validPlannings);
      
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
