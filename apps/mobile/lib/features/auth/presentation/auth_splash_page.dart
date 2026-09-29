import 'package:flutter/material.dart';

class AuthSplashPage extends StatelessWidget {
  const AuthSplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF7449),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/branding/cat_checkin_icon.png',
              width: 128,
              height: 128,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(height: 20),
            const Text(
              '猫咪打卡',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
