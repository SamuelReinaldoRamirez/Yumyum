import 'package:flutter/material.dart';
import 'package:yummap/constant/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yummap/widgets/neu_widgets.dart';
import 'package:go_router/go_router.dart';

class SharePage extends StatelessWidget {
  final String id;

  const SharePage({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Container(
        color: AppColors.backgroundColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(
                  'assets/logo/logo_new.png',
                  width: 100,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(40),
                  margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(height: 32),
                      Text(
                        'Welcome to Yummap',
                        style: AppTextStyles.titleBlackStyle,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Find the restaurant recommendations of @$id',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.paragraphDarkStyle,
                      ),
                      const SizedBox(height: 52),
                      CustomNeuButton(
                        text: 'Download App',
                        icon: Icons.download,
                        buttonColor: AppColors.appSecondary,
                        textColor: Colors.white,
                        onPressed: () {
                          // Logique pour télécharger l'application
                        },
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          context.go('/deepProfile/$id');  // Utilisation de GoRouter
                        },
                        child: Text(
                          'Continue with Web Browser',
                          style: TextStyle(
                            color: AppColors.secondaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
