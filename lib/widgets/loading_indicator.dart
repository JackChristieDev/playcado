import 'package:flutter/material.dart';

class LoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.size = 40,
    this.color,
  });

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = widget.color ?? Theme.of(context).colorScheme.primary;

    return Center(
      child: SizedBox(
        width: widget.size * 2.5,
        height: widget.size,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) {
            return _PulseDot(
              controller: _controller,
              index: index,
              color: color,
              size: widget.size * 0.4,
            );
          }),
        ),
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Color color;
  final double size;

  const _PulseDot({
    required this.controller,
    required this.index,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Calculate delay for each dot to create a wave effect
        double delay = index * 0.2;
        double progress = (controller.value - delay) % 1.0;
        if (progress < 0) progress += 1.0;

        // Use a curved value for smoother scaling and fading
        double curve = Curves.easeInOut.transform(
          progress < 0.5 ? progress * 2 : (1 - progress) * 2,
        );

        return Opacity(
          opacity: 0.3 + (curve * 0.7),
          child: Transform.scale(
            scale: 0.8 + (curve * 0.4),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4 * curve),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
