import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:yummap/custom_button.dart';
import 'package:yummap/main.dart';

// Centraliser les variables dans une classe
class BranchManager {
  // Static instance
  static final BranchManager _instance = BranchManager._internal();
  Logger logger = Logger();

  // Factory pour retourner la même instance
  factory BranchManager() {
    return _instance;
  }

  // Constructeur interne pour le singleton
  BranchManager._internal();

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // Variables Branch
  late BranchContentMetaData metadata;
  late BranchLinkProperties lp;
  late BranchUniversalObject buo;
  late BranchEvent eventStandard;
  late BranchEvent eventCustom;

  StreamSubscription<Map>? streamSubscription;
  StreamController<String> controllerData = StreamController<String>();
  StreamController<String> controllerInitSession = StreamController<String>();
  static const imageURL =
      'https://raw.githubusercontent.com/RodrigoSMarques/flutter_branch_sdk/master/assets/branch_logo_qrcode.jpeg';

  // Méthode pour écouter les liens dynamiques
  void listenDynamicLinks2(BuildContext context) async {
    streamSubscription = FlutterBranchSdk.listSession().listen((data) async {
      print('listenDynamicLinks - DeepLink Data: $data');
      controllerData.sink.add((data.toString()));

      if (data.containsKey('+clicked_branch_link') &&
          data['+clicked_branch_link'] == true) {
        print('Link clicked: ${data['custom_string']}');

        switch (data["pageName"]) {
          case "page1":
            print("page1");
            Navigator.pushNamed(context, '/');
            break;
          case "page2":
            print("page2");
            Navigator.push(
            context,
            MaterialPageRoute(
              // builder: (context) => Page2(idHotel: data["idHotel"]),
              builder: (context) => Page2(idHotel: int.parse(data["idHotel"])),
            ),
          );
            break;
          case "page3":
            print("page3");
            Navigator.pushNamed(context, '/page3');
            break;
          default:
            print("Valeur inconnue");
        }

        showSnackBar(
            message:
                'Link clicked: Custom string - ${data['custom_string']} - Date: ${data['custom_date_created'] ?? ''}',
            duration: 10);
      }
    }, onError: (error) {
      print('listSession error: ${error.toString()}');
    });
  }

  // // Méthode pour écouter les liens dynamiques
  // void listenDynamicLinks() async {
  //   streamSubscription = FlutterBranchSdk.listSession().listen((data) async {
  //     print('listenDynamicLinks - DeepLink Data: $data');
  //     controllerData.sink.add((data.toString()));

  //     if (data.containsKey('+clicked_branch_link') &&
  //         data['+clicked_branch_link'] == true) {
  //       print('Link clicked: ${data['custom_string']}');
  //       showSnackBar(
  //           message:
  //               'Link clicked: Custom string - ${data['custom_string']} - Date: ${data['custom_date_created'] ?? ''}',
  //           duration: 10);
  //     }
  //   }, onError: (error) {
  //     print('listSession error: ${error.toString()}');
  //   });
  // }

  // Méthode pour afficher une notification SnackBar
  void showSnackBar({required String message, int duration = 2}) {
    scaffoldMessengerKey.currentState!.removeCurrentSnackBar();
    scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: duration),
      ),
    );
  }

   // Initialiser les données du deep link
  void initDeepLinkData2(String pageName, int idHotel) {
    String dateString =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    metadata = BranchContentMetaData()
      ..addCustomMetadata('pageName', pageName)
      ..addCustomMetadata('idHotel', idHotel);
      // ..addCustomMetadata('custom_date_created', dateString);
    // logger.e("initDeepLinkData2 " + pageName + " " + idHotel.toString());

    final canonicalIdentifier = const Uuid().v4();
    buo = BranchUniversalObject(
        canonicalIdentifier: 'flutter/branch_$canonicalIdentifier',
        title: 'Flutter Branch Plugin - $dateString',
        imageUrl: imageURL,
        contentDescription: 'Flutter Branch Description - $dateString',
        contentMetadata: metadata,
        keywords: ['Plugin', 'Branch', 'Flutter'],
        publiclyIndex: true,
        locallyIndex: true,
        expirationDateInMilliSec: DateTime.now()
            .add(const Duration(days: 365))
            .millisecondsSinceEpoch);

    lp = BranchLinkProperties(
        channel: 'share',
        feature: 'sharing',
        stage: 'new share',
        campaign: 'campaign',
        tags: ['one', 'two', 'three'])
      ..addControlParam('\$uri_redirect_mode', '1')
      ..addControlParam('\$ios_nativelink', true)
      ..addControlParam('\$match_duration', 7200);
  }

  // // Initialiser les données du deep link
  // void initDeepLinkData() {
  //   String dateString =
  //       DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  //   metadata = BranchContentMetaData()
  //     ..addCustomMetadata('custom_string', 'abcd')
  //     ..addCustomMetadata('custom_number', 12345)
  //     ..addCustomMetadata('custom_bool', true)
  //     ..addCustomMetadata('custom_list_number', [1, 2, 3, 4, 5])
  //     ..addCustomMetadata('custom_list_string', ['a', 'b', 'c'])
  //     ..addCustomMetadata('custom_date_created', dateString);

  //   final canonicalIdentifier = const Uuid().v4();
  //   buo = BranchUniversalObject(
  //       canonicalIdentifier: 'flutter/branch_$canonicalIdentifier',
  //       title: 'Flutter Branch Plugin - $dateString',
  //       imageUrl: imageURL,
  //       contentDescription: 'Flutter Branch Description - $dateString',
  //       contentMetadata: metadata,
  //       keywords: ['Plugin', 'Branch', 'Flutter'],
  //       publiclyIndex: true,
  //       locallyIndex: true,
  //       expirationDateInMilliSec: DateTime.now()
  //           .add(const Duration(days: 365))
  //           .millisecondsSinceEpoch);

  //   lp = BranchLinkProperties(
  //       channel: 'share',
  //       feature: 'sharing',
  //       stage: 'new share',
  //       campaign: 'campaign',
  //       tags: ['one', 'two', 'three'])
  //     ..addControlParam('\$uri_redirect_mode', '1')
  //     ..addControlParam('\$ios_nativelink', true)
  //     ..addControlParam('\$match_duration', 7200);
  // }

  // Générer un lien
  void generateLink2(BuildContext context, String pageName, int idHotel) async {
    // logger.e("generateLink" + pageName + " " + idHotel.toString());
    initDeepLinkData2(pageName, idHotel);
    BranchResponse response =
        await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    if (response.success) {
      if (context.mounted) {
        showGeneratedLink2(context, response.result, pageName, idHotel);
      }
    } else {
      showSnackBar(
          message: 'Error : ${response.errorCode} - ${response.errorMessage}');
    }
  }

  // // Générer un lien
  // void generateLink(BuildContext context) async {
  //   initDeepLinkData();
  //   BranchResponse response =
  //       await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
  //   if (response.success) {
  //     if (context.mounted) {
  //       showGeneratedLink(context, response.result);
  //     }
  //   } else {
  //     showSnackBar(
  //         message: 'Error : ${response.errorCode} - ${response.errorMessage}');
  //   }
  // }

   // Afficher le lien généré
  void showGeneratedLink2(BuildContext context, String url, String pageName, int idHotel) async {
    // logger.e("showGeneratedLink2" + pageName + " " + idHotel.toString());

    initDeepLinkData2(pageName, idHotel);
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return Container(
            padding: const EdgeInsets.all(12),
            height: 200,
            child: Column(
              children: <Widget>[
                const Center(
                    child: Text(
                  'Link created',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                )),
                const SizedBox(height: 10),
                Text(url,
                    maxLines: 1,
                    style: const TextStyle(overflow: TextOverflow.ellipsis)),
                const SizedBox(height: 10),
                CustomButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: url));
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Copy link')),
              ],
            ),
          );
        });
  }
  

  // // Afficher le lien généré
  // void showGeneratedLink(BuildContext context, String url) async {
  //   initDeepLinkData();
  //   showModalBottomSheet(
  //       context: context,
  //       builder: (_) {
  //         return Container(
  //           padding: const EdgeInsets.all(12),
  //           height: 200,
  //           child: Column(
  //             children: <Widget>[
  //               const Center(
  //                   child: Text(
  //                 'Link created',
  //                 style: TextStyle(
  //                     color: Colors.blue, fontWeight: FontWeight.bold),
  //               )),
  //               const SizedBox(height: 10),
  //               Text(url,
  //                   maxLines: 1,
  //                   style: const TextStyle(overflow: TextOverflow.ellipsis)),
  //               const SizedBox(height: 10),
  //               CustomButton(
  //                   onPressed: () async {
  //                     await Clipboard.setData(ClipboardData(text: url));
  //                     if (context.mounted) {
  //                       Navigator.pop(context);
  //                     }
  //                   },
  //                   child: const Text('Copy link')),
  //             ],
  //           ),
  //         );
  //       });
  // }

  // Partager un lien
  void shareLink2(String pageName, int idHotel) async {
    initDeepLinkData2(pageName, idHotel);
    BranchResponse response = await FlutterBranchSdk.showShareSheet(
        buo: buo,
        linkProperties: lp,
        messageText: 'My Share text',
        androidMessageTitle: 'My Message Title',
        androidSharingTitle: 'My Share with');

    if (response.success) {
      showSnackBar(message: 'showShareSheet Success', duration: 5);
    } else {
      showSnackBar(
          message:
              'showShareSheet Error: ${response.errorCode} - ${response.errorMessage}',
          duration: 5);
    }
  }

  // // Partager un lien
  // void shareLink() async {
  //   initDeepLinkData();
  //   BranchResponse response = await FlutterBranchSdk.showShareSheet(
  //       buo: buo,
  //       linkProperties: lp,
  //       messageText: 'My Share text',
  //       androidMessageTitle: 'My Message Title',
  //       androidSharingTitle: 'My Share with');

  //   if (response.success) {
  //     showSnackBar(message: 'showShareSheet Success', duration: 5);
  //   } else {
  //     showSnackBar(
  //         message:
  //             'showShareSheet Error: ${response.errorCode} - ${response.errorMessage}',
  //         duration: 5);
  //   }
  // }
}
