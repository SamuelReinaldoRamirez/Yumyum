import 'package:flutter/material.dart';
import 'package:yummap/constant/theme.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    ));
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Naviguer vers la page d'accueil après l'animation
        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pushReplacementNamed('/home');
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor, // Utilisation de la couleur de fond définie dans AppColors
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Image.asset(
            'assets/logo/logo_new.png', // Votre logo ici
            width: 150, // Définir une largeur pour réduire la taille
            height: 150, // Définir une hauteur pour réduire la taille
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
