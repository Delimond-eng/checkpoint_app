import 'package:flutter/cupertino.dart';

import '/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomField extends StatelessWidget {
  final String hintText;
  final bool? isPassword;
  final String iconPath;
  final TextInputType? inputType;
  final TextEditingController? controller;
  final bool? isDropdown;
  final Function(String? value)? onChangedDrop;
  final List<String>? dropItems;

  const CustomField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    required this.iconPath,
    this.controller,
    this.inputType,
    this.isDropdown = false,
    this.onChangedDrop,
    this.dropItems,
  });

  @override
  Widget build(BuildContext context) {
    var obscurText = true;
    return StatefulBuilder(builder: (context, setter) {
      return Container(
        height: 50.0,
        margin: const EdgeInsets.only(bottom: 10.0),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,
          border: Border.all(
            color: secondaryColor.withOpacity(.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: Row(
            children: [
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: scaffoldColor,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: SvgPicture.asset(
                        iconPath,
                        colorFilter: const ColorFilter.mode(
                          secondaryColor,
                          BlendMode.srcIn,
                        ),
                        width: 18.0,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                ],
              ),
              Expanded(
                child: isPassword!
                    ? TextField(
                        controller: controller,
                        keyboardType: inputType ?? TextInputType.text,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.0,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: hintText,
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.0,
                            color: semiLightColor.withOpacity(.8),
                            fontWeight: FontWeight.w400,
                          ),
                          counterText: '',
                        ),
                        obscureText: obscurText,
                      )
                    : TextField(
                        keyboardType: inputType ?? TextInputType.text,
                        minLines:
                            inputType == TextInputType.multiline ? 3 : null,
                        maxLines:
                            inputType == TextInputType.multiline ? 6 : null,
                        keyboardAppearance: Brightness.dark,
                        controller: controller,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.0,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: hintText,
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.0,
                            color: semiLightColor.withOpacity(.8),
                            fontWeight: FontWeight.w400,
                          ),
                          counterText: '',
                        ),
                      ),
              ),
              if (isPassword!)
                GestureDetector(
                  onTap: () {
                    setter(() => obscurText = !obscurText);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Icon(
                      obscurText
                          ? CupertinoIcons.eye_solid
                          : CupertinoIcons.eye_slash_fill,
                      color: primaryColor,
                      size: 20.0,
                    ),
                  ),
                )
            ],
          ),
        ),
      );
    });
  }
}
