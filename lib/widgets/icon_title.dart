import 'package:flutter/material.dart';
import 'package:playcado/widgets/widgets.dart';

class IconTitle extends StatelessWidget {
  const IconTitle({required this.title, this.centerTitle = false, super.key});

  final bool centerTitle;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: centerTitle
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [CircleLogo(radius: 20), const SizedBox(width: 8), Text(title)],
    );
  }
}
