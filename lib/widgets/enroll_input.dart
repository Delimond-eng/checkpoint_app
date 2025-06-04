import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:flutter/material.dart';

class EnrollInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isActive;
  const EnrollInput(
      {super.key, required this.controller, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isActive ? Colors.green.shade300 : Colors.grey.shade300,
        ),
      ),
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: "Matricule de l'agent",
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          )
        ],
      ).paddingHorizontal(8.0),
    );
  }
}
