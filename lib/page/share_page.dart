import 'package:flutter/material.dart';
import 'package:yummap/constant/theme.dart';
import 'package:yummap/widgets/neu_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:yummap/platform/platform.dart';
import 'dart:io' show Platform;

class SharePage extends StatefulWidget {
  final String? id;

  const SharePage({Key? key, this.id}) : super(key: key);

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  final platform = getPlatform();

  bool isIOS() {
    if (!kIsWeb) return Platform.isIOS;
    return false; // Default to false for web
  }

  bool isAndroid() {
    if (!kIsWeb) return Platform.isAndroid;
    return true; // Default to true for web
  }

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
                      Center(
                        child: Text(
                          'Welcome to Yummap',
                          style: AppTextStyles.titleBlackStyle,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Find the restaurant recommendations of @${widget.id}',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.paragraphDarkStyle,
                      ),
                      const SizedBox(height: 52),
                      CustomNeuButton(
                        text: 'Download App',
                        icon: Icons.download,
                        buttonColor: AppColors.appSecondary,
                        textColor: Colors.white,
                        onPressed: () async {
                          try {
                            final deeplink = 'yummap://deepProfile/${widget.id}';
                            await platform.launchURL(deeplink);
                          } catch (e) {
                            // Si l'app n'est pas installée, ouvrir le store approprié
                            if (kIsWeb) {
                              if (isIOS()) {
                                await platform.launchURL('https://apps.apple.com/app/yummap/id123456789');
                              } else if (isAndroid()) {
                                await platform.launchURL('https://play.google.com/store/apps/details?id=com.yummap.app');
                              } else {
                                // Sur desktop ou autre, rediriger vers une page qui explique comment télécharger
                                await platform.launchURL('https://yummap.app/download');
                              }
                            } else {
                              // Sur mobile natif
                              if (isAndroid()) {
                                await platform.launchURL('https://play.google.com/store/apps/details?id=com.yummap.app');
                              } else if (isIOS()) {
                                await platform.launchURL('https://apps.apple.com/app/yummap/id123456789');
                              }
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          context.go(
                              '/deepProfile/${widget.id}'); // Utilisation de GoRouter
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
