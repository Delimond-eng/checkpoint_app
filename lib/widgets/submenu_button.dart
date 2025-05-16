import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/styles.dart';

class SubMenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData icon;
  const SubMenuButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      child: Card(
        margin: EdgeInsets.zero,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Material(
          borderRadius: BorderRadius.circular(10.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(10.0),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        size: 18.0,
                      ).paddingRight(8.0),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const Icon(
                    CupertinoIcons.chevron_right,
                    size: 17.0,
                    color: greyColor,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
