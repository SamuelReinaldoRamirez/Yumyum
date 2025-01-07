import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yummap/constant/theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      context.go('/home');
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundColor, 
      body: Center(
        child: Image.asset(
          'assets/logo/logo_new.png', 
          width: 150, 
          height: 150, 
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
