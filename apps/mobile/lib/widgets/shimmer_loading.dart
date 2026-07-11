import 'package:flutter/material.dart';

/// Lightweight shimmer effect built with only core Flutter APIs —
/// no extra package dependency needed.
class Shimmer extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const Shimmer({super.key, required this.child, this.enabled = true});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final t = _controller.value;
            return LinearGradient(
              colors: const [Color(0xFFE8E8E8), Color(0xFFF6F6F6), Color(0xFFE8E8E8)],
              stops: const [0.35, 0.5, 0.65],
              begin: Alignment(-1 - t * 2, 0),
              end: Alignment(1 - t * 2, 0),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A gray placeholder box, meant to be wrapped in [Shimmer].
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Ready-made shimmer skeleton mimicking an offer/donation card.
/// Drop this in place of CircularProgressIndicator while lists load —
/// it reads as "content is arriving" rather than "please wait".
class ShimmerCardList extends StatelessWidget {
  final int itemCount;

  const ShimmerCardList({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: ShimmerBox(height: 18, width: 160)),
                  const SizedBox(width: 12),
                  ShimmerBox(width: 70, height: 28, radius: 14),
                ],
              ),
              const SizedBox(height: 10),
              const ShimmerBox(height: 12, width: 120),
              const SizedBox(height: 16),
              const ShimmerBox(height: 44, radius: 12),
            ],
          ),
        ),
      ),
    );
  }
}
