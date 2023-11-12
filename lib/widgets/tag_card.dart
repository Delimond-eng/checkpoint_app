import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../themes/colors.dart';

class TagCard extends StatelessWidget {
  final String? tagName;
  final String? tag;
  const TagCard({super.key, this.tag, this.tagName});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 70.0,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tagName!.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      'ID: $tag',
                      style: const TextStyle(
                        color: Color(0xFFafa1d9),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
              Lottie.asset(
                "assets/animations/success_1.json",
                height: 50.0,
                repeat: false,
              )
            ],
          ),
        ),
      ),
    );
  }
}
