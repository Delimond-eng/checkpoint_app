import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import '/constants/styles.dart';
import '/global/controllers.dart';
import '/global/store.dart';
import '/kernel/services/api.dart';
import '/kernel/services/http_manager.dart';
import '/kernel/services/image_service.dart';
import '/modals/recognition_face_modal.dart';
import '/pages/mobile_qr_scanner_011.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../kernel/models/user.dart';
import '../modals/supervisor_form_modal.dart';
import '../widgets/submit_button.dart' show SubmitButton;
import '../widgets/user_status.dart';

class SupervisorAgent extends StatefulWidget {
  const SupervisorAgent({super.key});

  @override
  State<SupervisorAgent> createState() => _SupervisorAgentState();
}

class _SupervisorAgentState extends State<SupervisorAgent> {
  final TextEditingController _generalCommentController = TextEditingController();

  @override
  void dispose() {
    _generalCommentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      body: Obx(() {
        final agents = authController.stationAgents;
        
        return Column(
          children: [
            // Fixed Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0B0B0F), Color(0xFF16161E)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                      const UserStatus(name: ""),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "inspection".tr.toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryMaterialColor, fontFamily: 'Ubuntu', letterSpacing: 2),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tagsController.scannedSite.value.name?.toUpperCase() ?? "station".tr.toUpperCase(),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Staatliches'),
                        ),
                      ),
                      if (authController.pendingSupervision.value == null)
                        TextButton.icon(
                          onPressed: () {
                            authController.stationAgents.clear();
                            tagsController.isScanningModalOpen.value = false;
                            Get.back();
                          },
                          icon: const Icon(Icons.refresh_rounded, color: Colors.redAccent, size: 18),
                          label: Text("ANNULER LE SCAN".tr, style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Ubuntu')),
                          style: TextButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.1)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    authController.pendingSupervision.value != null ? "Ronde de supervision en cours" : "Veuillez démarrer la ronde pour noter les agents.",
                    style: TextStyle(color: authController.pendingSupervision.value != null ? Colors.greenAccent : Colors.white38, fontSize: 12, fontFamily: 'Ubuntu'),
                  ),
                ],
              ),
            ),

            // White Sheet Section
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
                ),
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
                  child: agents.isEmpty 
                    ? _buildEmptyState()
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(25, 30, 25, 20),
                        children: [
                          ...agents.map((agent) => SupervisorAgentTile(
                            data: agent,
                            isActive: authController.pendingSupervision.value != null,
                          )),
                          
                          if (authController.pendingSupervision.value != null) ...[
                            const SizedBox(height: 30),
                            Text(
                              "OBSERVATION GÉNÉRALE (OPTIONNEL)".tr,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2, fontFamily: 'Ubuntu'),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                              ),
                              padding: const EdgeInsets.all( 15),
                              child: TextField(
                                controller: _generalCommentController,
                                maxLines: 3,
                                style: const TextStyle(fontFamily: 'Ubuntu', fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: "Remarques sur l'état général de la station...",
                                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                                ),
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 40),

                          authController.pendingSupervision.value != null
                            ? SubmitButton(
                                label: "CLÔTURER LA RONDE".tr,
                                color: Colors.green,
                                loading: tagsController.isLoading.value,
                                onPressed: () => showRecognitionModal(context, key: "supervize-out", onValidate: closeSupervision),
                              )
                            : SubmitButton(
                                label: "start_supervision".tr.toUpperCase(),
                                color: primaryMaterialColor,
                                loading: tagsController.isLoading.value,
                                onPressed: () => showRecognitionModal(context, key: "supervize-in", onValidate: supervizeStart),
                              ),
                          const SizedBox(height: 30),
                        ],
                      ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_rounded, size: 80, color: Colors.grey.shade200),
            const SizedBox(height: 20),
            const Text(
              "Aucun agent détecté sur cette station. Veuillez scanner à nouveau le QR code.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontFamily: 'Ubuntu', fontSize: 14),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                authController.stationAgents.clear();
                tagsController.isScanningModalOpen.value = false;
                Get.back();
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MobileQrScannerPage011()));
              },
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: Text("RESCANNER".tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF8F9FA),
                foregroundColor: Colors.black87,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> supervizeStart() async {
    var manager = HttpManager();
    tagsController.isLoading.value = true;
    final value = await manager.startSupervison();
    tagsController.isLoading.value = false;
    if (value is String) {
      EasyLoading.showError(value);
    } else {
      authController.refreshSupervision();
      EasyLoading.showSuccess("Ronde de supervision démarrée !");
    }
  }

  Future<void> closeSupervision() async {
    int supervisionId = authController.pendingSupervision.value!.id!;
    File originalPhoto = File(tagsController.face.value!.path);
    File photoFin = await ImageService.compressForUpload(originalPhoto);
    
    final url = Uri.parse('${Api.baseUrl}/supervision.close');
    const apiKey = "16jA/0l6TBmFoPk64MnrmLzVp2MRL2Do0yD5N6K4e54=";
    var supervisedAgents = authController.supervisedDatas;

    tagsController.isLoading.value = true;
    var request = http.MultipartRequest('POST', url)
      ..headers.addAll({'Accept': 'application/json', 'X-API-KEY': apiKey})
      ..fields['supervision_id'] = supervisionId.toString()
      ..fields['comment'] = _generalCommentController.text;

    if (photoFin.existsSync()) {
      request.files.add(await http.MultipartFile.fromPath('photo', photoFin.path));
    }

    for (int i = 0; i < supervisedAgents.length; i++) {
      final agentData = supervisedAgents[i];
      if (agentData['photo'] == null || agentData['photo'] is! File) continue;

      request.fields['agents[$i][agent_id]'] = agentData['agent_id'].toString();
      request.fields['agents[$i][comment]'] = agentData['comment'] ?? "";
      
      File agentPhoto = await ImageService.compressForUpload(agentData['photo'] as File);
      request.files.add(await http.MultipartFile.fromPath('agents[$i][photo]', agentPhoto.path));

      final notes = (agentData['notes'] as List<dynamic>).map((e) => Map<String, dynamic>.from(e)).toList();
      for (int j = 0; j < notes.length; j++) {
        final note = notes[j];
        request.fields['agents[$i][notes][$j][control_element_id]'] = note['control_element_id'].toString();
        request.fields['agents[$i][notes][$j][note]'] = note['note'].toString();
        request.fields['agents[$i][notes][$j][comment]'] = ""; 
      }
    }

    try {
      var response = await request.send();
      final res = await http.Response.fromStream(response);
      tagsController.isLoading.value = false;
      if (res.statusCode == 200) {
        var result = jsonDecode(res.body);
        if (result.containsKey("errors")) {
          EasyLoading.showInfo(result["errors"].toString());
        } else {
          EasyLoading.showSuccess(result["message"] ?? "success".tr);
          localStorage.remove("supervision");
          authController.refreshSupervision();
          Get.back();
        }
      } else {
        EasyLoading.showInfo("error".tr);
      }
    } catch (e) {
      tagsController.isLoading.value = false;
      EasyLoading.showError("error".tr);
    }
  }
}

class SupervisorAgentTile extends StatelessWidget {
  final User data;
  final bool isActive;
  const SupervisorAgentTile({super.key, required this.data, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    final isChecked = authController.supervisedAgent.contains(data.id);

    return Obx(()=>Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF8F9FA) : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isChecked ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: isActive ? () {
                authController.selectedAgentId.value = data.id!;
                _startSupervisionForAgent(data.id!);
                showSupervisorFormModal(context);
              } : null,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: isChecked ? Colors.green : Colors.grey.shade300, width: 2),
                      ),
                      child: ClipOval(
                        child: data.photo != null
                            ? CachedNetworkImage(
                          imageUrl: data.photo!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Image.asset("assets/images/profil-2.png"),
                        )
                            : Image.asset("assets/images/profil-2.png"),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.fullname?.toUpperCase() ?? "agent".tr.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isActive ? const Color(0xFF16161E) : Colors.grey,
                              fontFamily: 'Ubuntu',
                            ),
                          ),
                          Text(
                            data.matricule ?? "",
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontFamily: 'Ubuntu'),
                          ),
                        ],
                      ),
                    ),
                    if (isChecked) ...[
                      // Delete button to cancel rating for this agent
                      IconButton(
                        onPressed: () => _cancelRating(data.id!),
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                        tooltip: "ANNULER LA COTATION".tr,
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                      )
                    ]
                    else if (isActive)
                      const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  void _startSupervisionForAgent(int agentId) {
    var exists = authController.supervisedDatas.any((item) => item['agent_id'] == agentId);
    if (!exists) {
      authController.supervisedDatas.add({'agent_id': agentId, 'comment': '', 'photo': null, 'notes': []});
    }
  }

  void _cancelRating(int agentId) {
    authController.supervisedAgent.remove(agentId);
    authController.supervisedDatas.removeWhere((element) => element['agent_id'] == agentId);
    authController.supervisedDatas.refresh();
    EasyLoading.showToast("Cotation annulée pour cet agent");
  }
}
