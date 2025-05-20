import 'package:checkpoint_app/constants/styles.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/widget_extensions.dart';

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
      return DottedBorder(
        color: const Color.fromARGB(255, 168, 222, 229),
        radius: const Radius.circular(12.0),
        strokeWidth: 1,
        borderType: BorderType.RRect,
        dashPattern: const [6, 3],
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: whiteColor,
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
                        child: SvgPicture.asset(
                          iconPath,
                          colorFilter: const ColorFilter.mode(
                            primaryColor,
                            BlendMode.srcIn,
                          ),
                          width: 18.0,
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
                              hintStyle: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12.0,
                                fontStyle: FontStyle.italic,
                                color: greyColor80,
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
                              hintStyle: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12.0,
                                fontStyle: FontStyle.italic,
                                color: greyColor80,
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
                      child: SvgPicture.asset(
                        obscurText == true
                            ? "assets/svgs/eye-alt.svg"
                            : "assets/svgs/eye-slash-alt.svg",
                        height: 24,
                        width: 24,
                        colorFilter: ColorFilter.mode(
                            Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .color!
                                .withOpacity(0.3),
                            BlendMode.srcIn),
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      ).marginOnly(bottom: 10.0);
    });
  }
}
