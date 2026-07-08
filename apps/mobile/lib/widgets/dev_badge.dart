import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dev_provider.dart';

class DevBadge extends StatelessWidget {
  final Widget child;
  final String message;

  const DevBadge({
    super.key,
    required this.child,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DevProvider>(
      builder: (context, dev, _) {
        if (!dev.isDevMode) return child;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              top: -8,
              right: -8,
              child: Tooltip(
                message: message,
                padding: const EdgeInsets.all(12),
                showDuration: const Duration(seconds: 4),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(color: Colors.white, fontSize: 14),
                triggerMode: TooltipTriggerMode.tap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'MOCK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
