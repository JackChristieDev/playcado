import 'package:flutter/material.dart';

class CircleLogo extends StatelessWidget {
  const CircleLogo({required this.radius, super.key});

  final double radius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      backgroundColor: colorScheme.surface,
      backgroundImage: const AssetImage('assets/playcado_logo.png'),
      radius: radius,
    );
  }
}
