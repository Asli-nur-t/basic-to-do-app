import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FullScreenTimer extends StatelessWidget {
  final Widget child;

  const FullScreenTimer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Ana içerik
            Center(
              child: child,
            ),
            // Kapatma butonu
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
