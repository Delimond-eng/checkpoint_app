import 'dart:io';
import 'dart:ui';

import '/constants/styles.dart';
import '/global/controllers.dart';
import '/kernel/models/supervision_element.dart';
import '/modals/photo_capture_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../widgets/submit_button.dart';

Future<void> showSupervisorFormModal(BuildContext context) async {
  int agentId = authController.selectedAgentId.value;
  var existingData = authController.supervisedDatas.firstWhereOrNull((item) => item['agent_id'] == agentId);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
          ),
          child: Column(
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              const Text(
                "COTATION AGENT",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Staatliches', letterSpacing: 1.5, color: Color(0xFF16161E)),
              ),
              const SizedBox(height: 5),
              Text("Évaluez les critères de performance de l'agent.".tr, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontFamily: 'Ubuntu')),
              const SizedBox(height: 25),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      StatefulBuilder(
                        builder: (context, setter) {
                          File? photo = authController.supervisedDatas.firstWhereOrNull((e) => e['agent_id'] == agentId)?['photo'];
                          return GestureDetector(
                            onTap: () {
                              showPhotoCaptureModal(context, onValidate: (file) {
                                setter(() => photo = file);
                                authController.updateAgentPhoto(agentId, file);
                              });
                            },
                            child: Stack(
                              children: [
                                Container(
                                  height: 120, width: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFF8F9FA),
                                    border: Border.all(color: primaryMaterialColor.withOpacity(0.2), width: 3),
                                    image: photo != null ? DecorationImage(image: FileImage(photo), fit: BoxFit.cover) : null,
                                  ),
                                  child: photo == null ? const Icon(Icons.add_a_photo_rounded, color: primaryMaterialColor, size: 35) : null,
                                ),
                                Positioned(
                                  bottom: 0, right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(color: primaryMaterialColor, shape: BoxShape.circle),
                                    child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),

                      ...authController.supervisorElements.map((e) {
                        var existingNote = existingData?['notes']?.firstWhere((n) => n['control_element_id'] == e.id, orElse: () => null);
                        return ElementCard(
                          data: e,
                          initialNote: existingNote?['note'],
                          onNoteSelected: (noteLabel) {
                            if (existingData != null) {
                              existingData['notes']?.removeWhere((n) => n['control_element_id'] == e.id);
                              existingData['notes']?.add({
                                'control_element_id': e.id, 
                                'note': noteLabel, 
                                'comment': null 
                              });
                            }
                          },
                        );
                      }).toList(),

                      const SizedBox(height: 35),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: SubmitButton(
                          label: "save_enrollment".tr,
                          color: primaryMaterialColor,
                          onPressed: () {
                            if (existingData == null) {
                              Get.back();
                              return;
                            }
                            var notes = existingData['notes'] as List;
                            bool allCriteriaRated = authController.supervisorElements.isNotEmpty && 
                            authController.supervisorElements.every((e) =>
                              notes.any((n) => n['control_element_id'] == e.id && n['note'] != null)
                            );
                            
                            if (allCriteriaRated) {
                              if (!authController.supervisedAgent.contains(agentId)) {
                                authController.supervisedAgent.add(agentId);
                              }
                              EasyLoading.showSuccess("Agent évalué");
                            } else {
                              authController.supervisedAgent.remove(agentId);
                            }
                            authController.supervisedDatas.refresh();
                            Get.back();
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class ElementCard extends StatefulWidget {
  final SupElement data;
  final String? initialNote;
  final Function(String) onNoteSelected;
  const ElementCard({super.key, required this.data, this.initialNote, required this.onNoteSelected});

  @override
  State<ElementCard> createState() => _ElementCardState();
}

class _ElementCardState extends State<ElementCard> {
  String? selectedNote;

  @override
  void initState() {
    super.initState();
    selectedNote = widget.initialNote;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.data.libelle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF16161E), fontFamily: 'Ubuntu')),
          const SizedBox(height: 4),
          Text(widget.data.description, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontFamily: 'Ubuntu')),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGradeBtn("B", "GOOD", Colors.green, selectedNote == "B"),
              _buildGradeBtn("P", "FAIR", Colors.orange, selectedNote == "P"),
              _buildGradeBtn("M", "POOR", Colors.red, selectedNote == "M"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGradeBtn(String code, String label, Color color, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() => selectedNote = code);
        widget.onNoteSelected(code);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: isActive ? color : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? color : color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(code, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.white : color, fontSize: 16, fontFamily: 'Staatliches')),
            //Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.white70 : color.withOpacity(0.5), fontSize: 8, fontFamily: 'Ubuntu')),
          ],
        ),
      ),
    );
  }
}
