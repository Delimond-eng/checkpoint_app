import 'dart:async';
import 'dart:io';

import '/global/store.dart';
import '/global/controllers.dart';
import '/kernel/models/area.dart';
import '/kernel/models/user.dart';
import '/kernel/models/planning.dart';
import '/kernel/services/http_manager.dart';
import '/kernel/services/local_db_service.dart';
import '/kernel/services/alarm_service.dart'; // Import ajouté
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class TagsController extends GetxController {
  static TagsController instance = Get.find();

  var scannedArea = Area().obs;
  var scannedSite = Site().obs;
  var isQrcodeScanned = false.obs;
  var patrolId = 0.obs;
  var isLoading = false.obs;
  var isScanningModalOpen = false.obs;
  var mediaFile = Rx<File?>(null);
  var face = Rx<XFile?>(null);
  var faceResult = "".obs;
  var isFlashOn = false.obs;
  var cameraIndex = 1.obs;
  var planningId = "".obs;
  
  // Observables pour les badges et le dashboard
  var announceCount = 0.obs;
  var pendingPlanningCount = 0.obs;
  var nextPlanning = Rxn<Planning>();

  StreamSubscription<List<Map<String, dynamic>>>? _patrolStreamSubscription;
  Timer? _dataRefreshTimer;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _startPatrolStream();
    
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
        if (authController.userSession.value != null && authController.userSession.value?.id != null) {
          return await HttpManager().checkPending();
        }
        return <Map<String, dynamic>>[];
      } catch (e) {
        return <Map<String, dynamic>>[];
      }
    }).listen((pendingPatrols) {
      if (pendingPatrols.isEmpty) {
        localStorage.remove("patrol_id");
        patrolId.value = 0;
      } else {
        final first = pendingPatrols.first;
        final newId = first["id"] ?? 0;
        if (patrolId.value != newId) {
          patrolId.value = newId;
          localStorage.write("patrol_id", newId);
        }
      }
    });
  }

  void _startDataRefreshTimer() {
    _dataRefreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      fetchAnnouncesAndPlannings();
    });
    fetchAnnouncesAndPlannings();
  }

  Future<void> fetchAnnouncesAndPlannings() async {
    if (authController.userSession.value == null || authController.userSession.value?.id == null) return;
    
    try {
      final announces = await HttpManager.getAllAnnounces();
      announceCount.value = announces.length;
      
      final plannings = await HttpManager.getAllPlannings();
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final validPlannings = plannings.where((p) {
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
      pendingPlanningCount.value = validPlannings.length;
      
      _updateNextPlanning(validPlannings);

      // Programmer les alarmes pour les plannings valides
      await AlarmService.instance.scheduleAlarms(validPlannings);
      
    } catch (e) {
      final localPlannings = await LocalDbService.instance.getLocalPlannings();
      pendingPlanningCount.value = localPlannings.length;
      _updateNextPlanning(localPlannings);
      
      // Programmer les alarmes même en mode local
      await AlarmService.instance.scheduleAlarms(localPlannings);
    }
  }

  void _updateNextPlanning(List<Planning> plannings) {
    if (plannings.isEmpty) {
      nextPlanning.value = null;
      return;
    }

    try {
      final now = DateTime.now();
      
      // Trier par date et heure de début
      plannings.sort((a, b) {
        DateTime dateA = a.date!.contains('/') ? DateFormat('dd/MM/yyyy').parse(a.date!) : DateTime.parse(a.date!);
        DateTime dateB = b.date!.contains('/') ? DateFormat('dd/MM/yyyy').parse(b.date!) : DateTime.parse(b.date!);
        
        int dateComp = dateA.compareTo(dateB);
        if (dateComp != 0) return dateComp;
        
        return a.startTime!.compareTo(b.startTime!);
      });

      // Trouver le prochain planning futur
      nextPlanning.value = plannings.firstWhere((p) {
        DateTime pDate = p.date!.contains('/') ? DateFormat('dd/MM/yyyy').parse(p.date!) : DateTime.parse(p.date!);
        DateTime start = DateTime(pDate.year, pDate.month, pDate.day, 
            int.parse(p.startTime!.split(':')[0]), 
            int.parse(p.startTime!.split(':')[1]));
        return start.isAfter(now);
      }, orElse: () => plannings.first);
    } catch (e) {
      nextPlanning.value = plannings.isNotEmpty ? plannings.first : null;
    }
  }

  void refreshPending() {
    var patrolIdLocal = localStorage.read("patrol_id");
    patrolId.value = patrolIdLocal ?? 0;
  }
}
