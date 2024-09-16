import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:yummap/global.dart';
import 'package:yummap/restaurant.dart';
import 'package:yummap/tag.dart';
import 'package:yummap/translate_utils.dart';
import 'package:path_provider/path_provider.dart';

Logger logger = Logger();
final CustomTranslate customTranslate = CustomTranslate(); // Ajout de l'instance


  Future<void> createOrUpdateGLOBALLocalizedRestoInfosJsonFile(
    List<Restaurant> restoList, BuildContext context) async {
  restoInfosLocalizedFinishedLoading.value = false;
  String deviceLocale = context.locale.languageCode;
  bool needsTranslate = deviceLocale != "fr";

  try {
    // Liste pour stocker les infos traduites des restaurants
    List<Map<String, dynamic>> translatedRestoInfos = [];

    for (Restaurant resto in restoList) {
      String translatedName = resto.name;
      String translatedAddress = resto.address;
      String translatedCuisine = resto.cuisine;

      if (needsTranslate) {
        // Traduire les champs nécessaires
        translatedName = await customTranslate.translate(resto.name, 'fr', deviceLocale);
        translatedAddress = await customTranslate.translate(resto.address, 'fr', deviceLocale);
        translatedCuisine = await customTranslate.translate(resto.cuisine, 'fr', deviceLocale);

        // Traduire les reviews
        List<Map<String, dynamic>> translatedReviews = [];
        for (ReviewRestau review in resto.reviews) {
          String translatedReviewText = await customTranslate.translate(review.text, 'fr', deviceLocale);
          translatedReviews.add({
            'author': review.author,
            'text': translatedReviewText,
            'rating': review.rating
          });
        }

        // Ajouter les infos du resto traduites
        translatedRestoInfos.add({
          'id': resto.id,
          'name': resto.name, // Nom non traduit
          'translated_name': translatedName,
          'translated_address': translatedAddress,
          'translated_cuisine': translatedCuisine,
          'translated_reviews': translatedReviews
        });
      } else {
        // Si aucune traduction n'est nécessaire
        translatedRestoInfos.add({
          'id': resto.id,
          'name': resto.name,
          'translated_name': resto.name,
          'translated_address': resto.address,
          'translated_cuisine': resto.cuisine,
          'translated_reviews': resto.reviews.map((review) => {
            'author': review.author,
            'text': review.text,
            'rating': review.rating
          }).toList()
        });
      }
    }

    // Convertir en JSON
    String restoInfosJson = jsonEncode(translatedRestoInfos);

    // Obtenir le répertoire de documents de l'application
    Directory directory = await getApplicationDocumentsDirectory();
    String cacheDirPath = '${directory.path}/pseudo_caches';
    Directory cacheDir = Directory(cacheDirPath);

    // Si le répertoire n'existe pas, le créer
    if (!(await cacheDir.exists())) {
      await cacheDir.create(recursive: true);
    }

    // Créer et écrire dans le fichier localized_resto_infos_{locale}.json
    String filePath = '$cacheDirPath/localized_resto_infos.json';
    File file = File(filePath);
    await file.writeAsString(restoInfosJson);

    restoInfosLocalizedFinishedLoading.value = true;
  } catch (e, stacktrace) {
    logger.e("Erreur lors de la création ou mise à jour du fichier des restaurants localisés : $e");
    logger.e("Stacktrace: $stacktrace");
  }
}

// Future<void> createOrUpdateGLOBALLocalizedRestoInfosJsonFile(
//     List<Restaurant> restoList, BuildContext context) async {
//   restoInfosLocalizedFinishedLoading.value = false;
//   String deviceLocale = context.locale.languageCode;
//   bool needsTranslate = deviceLocale != "fr";

//   // Obtenir le répertoire de documents de l'application
//   Directory directory = await getApplicationDocumentsDirectory();
//   String cacheDirPath = '${directory.path}/pseudo_caches';
//   Directory cacheDir = Directory(cacheDirPath);

//   // Si le répertoire n'existe pas, le créer
//   if (!(await cacheDir.exists())) {
//     await cacheDir.create(recursive: true);
//   }

//   // Créer le fichier JSON
//   String filePath = '$cacheDirPath/localized_resto_infos_$deviceLocale.json';
//   File file = File(filePath);
//   IOSink sink = file.openWrite(mode: FileMode.writeOnlyAppend);

//   // Commencer l'écriture du fichier JSON
//   sink.write('['); // Ouvrir la liste JSON

//   try {
//     for (int i = 0; i < restoList.length; i++) {
//       Restaurant resto = restoList[i];
//       String translatedName = resto.name;
//       String translatedAddress = resto.address;
//       String translatedCuisine = resto.cuisine;

//       if (needsTranslate) {
//         // Traduire les champs nécessaires
//         translatedName = await customTranslate.translate(resto.name, 'fr', deviceLocale);
//         translatedAddress = await customTranslate.translate(resto.address, 'fr', deviceLocale);
//         translatedCuisine = await customTranslate.translate(resto.cuisine, 'fr', deviceLocale);

//         // Traduire les reviews
//         List<Map<String, dynamic>> translatedReviews = [];
//         for (ReviewRestau review in resto.reviews) {
//           String translatedReviewText = await customTranslate.translate(review.text, 'fr', deviceLocale);
//           translatedReviews.add({
//             'author': review.author,
//             'text': translatedReviewText,
//             'rating': review.rating
//           });
//         }

//         // Ajouter les infos du resto traduites
//         sink.write(jsonEncode({
//           'id': resto.id,
//           'name': resto.name, // Nom non traduit
//           'translated_name': translatedName,
//           'translated_address': translatedAddress,
//           'translated_cuisine': translatedCuisine,
//           'translated_reviews': translatedReviews
//         }));
//       } else {
//         // Si aucune traduction n'est nécessaire
//         sink.write(jsonEncode({
//           'id': resto.id,
//           'name': resto.name,
//           'translated_name': resto.name,
//           'translated_address': resto.address,
//           'translated_cuisine': resto.cuisine,
//           'translated_reviews': resto.reviews.map((review) => {
//             'author': review.author,
//             'text': review.text,
//             'rating': review.rating
//           }).toList()
//         }));
//       }

//       // Ajouter une virgule sauf pour le dernier élément
//       if (i != restoList.length - 1) {
//         sink.write(',');
//       }
//     }
//   } finally {
//     // Fermer la liste JSON et terminer l'écriture
//     sink.write(']');
//     await sink.flush();
//     await sink.close();
//     restoInfosLocalizedFinishedLoading.value = true;
//   }
// }

Future<Map<String, dynamic>?> readPartialJsonFileForRestaurant(String restaurantId) async {
  try {
    // Obtenir le répertoire de documents de l'application
    Directory directory = await getApplicationDocumentsDirectory();
    String cacheDirPath = '${directory.path}/pseudo_caches';
    String filePath = '$cacheDirPath/localized_resto_infos.json';

    File file = File(filePath);
    if (await file.exists()) {
      String jsonContent = await file.readAsString();

      // Tenter de découper et lire les parties complètes du JSON
      jsonContent = jsonContent.trim();

      if (jsonContent.startsWith('[') && jsonContent.endsWith(']')) {
        // Si le fichier est complet
        List<dynamic> jsonData = jsonDecode(jsonContent);
        for (var resto in jsonData) {
          if (resto['id'] == restaurantId) {
            return {
              'name': resto['name'],
              'translated_name': resto['translated_name'],
              'translated_address': resto['translated_address'],
              'translated_cuisine': resto['translated_cuisine'],
              'translated_reviews': resto['translated_reviews']
            };
          }
        }
      } else if (jsonContent.startsWith('[')) {
        // Si le fichier est partiellement écrit
        int lastValidIndex = jsonContent.lastIndexOf('},');
        if (lastValidIndex != -1) {
          String partialContent = jsonContent.substring(0, lastValidIndex + 1) + ']';
          List<dynamic> jsonData = jsonDecode(partialContent);
          for (var resto in jsonData) {
            if (resto['id'] == restaurantId) {
              return {
                'name': resto['name'],
                'translated_name': resto['translated_name'],
                'translated_address': resto['translated_address'],
                'translated_cuisine': resto['translated_cuisine'],
                'translated_reviews': resto['translated_reviews']
              };
            }
          }
        }
      }
    } else {
      print('Le fichier n\'existe pas encore.');
    }
  } catch (e) {
    print('Erreur lors de la lecture du fichier JSON: $e');
  }

  // Retourne null si le restaurant n'est pas trouvé
  return null;
}


// Future<void> createOrUpdateGLOBALLocalizedRestoInfosJsonFile(
//     List<Restaurant> restoList, BuildContext context, String filePath) async {
//   restoInfosLocalizedFinishedLoading.value = false;
//   String deviceLocale = context.locale.languageCode;
//   bool needsTranslate = deviceLocale != "fr";

//   // Ouvrir le fichier en mode append
//   File file = File(filePath);
//   IOSink sink = file.openWrite(mode: FileMode.writeOnlyAppend);
  
//   // Commencer l'écriture du fichier JSON
//   sink.write('[');  // Ouvrir la liste JSON

//   try {
//     for (int i = 0; i < restoList.length; i++) {
//       Restaurant resto = restoList[i];
//       String translatedName = resto.name;
//       String translatedAddress = resto.address;
//       String translatedCuisine = resto.cuisine;

//       if (needsTranslate) {
//         // Traduire les champs nécessaires
//         translatedName = await customTranslate.translate(resto.name, 'fr', deviceLocale);
//         translatedAddress = await customTranslate.translate(resto.address, 'fr', deviceLocale);
//         translatedCuisine = await customTranslate.translate(resto.cuisine, 'fr', deviceLocale);

//         // Traduire les reviews
//         List<Map<String, dynamic>> translatedReviews = [];
//         for (ReviewRestau review in resto.reviews) {
//           String translatedReviewText = await customTranslate.translate(review.text, 'fr', deviceLocale);
//           translatedReviews.add({
//             'author': review.author,
//             'text': translatedReviewText,
//             'rating': review.rating
//           });
//         }

//         // Ajouter les infos du resto traduites
//         sink.write(jsonEncode({
//           'id': resto.id,
//           'name': resto.name, // Nom non traduit
//           'translated_name': translatedName,
//           'translated_address': translatedAddress,
//           'translated_cuisine': translatedCuisine,
//           'translated_reviews': translatedReviews
//         }));
//       } else {
//         // Si aucune traduction n'est nécessaire
//         sink.write(jsonEncode({
//           'id': resto.id,
//           'name': resto.name,
//           'translated_name': resto.name,
//           'translated_address': resto.address,
//           'translated_cuisine': resto.cuisine,
//           'translated_reviews': resto.reviews.map((review) => {
//             'author': review.author,
//             'text': review.text,
//             'rating': review.rating
//           }).toList()
//         }));
//       }

//       // Ajouter une virgule sauf pour le dernier élément
//       if (i != restoList.length - 1) {
//         sink.write(',');
//       }
//     }
//   } finally {
//     // Fermer la liste JSON et terminer l'écriture
//     sink.write(']');
//     await sink.flush();
//     await sink.close();
//     restoInfosLocalizedFinishedLoading.value = true;
//   }
// }



// Future<void> readPartialJsonFile(String filePath) async {
//   try {
//     File file = File(filePath);
//     if (await file.exists()) {
//       String jsonContent = await file.readAsString();

//       // Tenter de découper et lire les parties complètes du JSON
//       jsonContent = jsonContent.trim();

//       if (jsonContent.startsWith('[') && jsonContent.endsWith(']')) {
//         // Si le fichier est complet
//         List<dynamic> jsonData = jsonDecode(jsonContent);
//         for (var resto in jsonData) {
//           print('Restaurant Name: ${resto['name']}');
//         }
//       } else if (jsonContent.startsWith('[')) {
//         // Si le fichier est partiellement écrit
//         int lastValidIndex = jsonContent.lastIndexOf('},');
//         if (lastValidIndex != -1) {
//           String partialContent = jsonContent.substring(0, lastValidIndex + 1) + ']';
//           List<dynamic> jsonData = jsonDecode(partialContent);
//           for (var resto in jsonData) {
//             print('Restaurant Name: ${resto['name']}');
//           }
//         }
//       }
//     } else {
//       print('Le fichier n\'existe pas encore.');
//     }
//   } catch (e) {
//     print('Erreur lors de la lecture du fichier JSON: $e');
//   }
// }







/////////////////////pour les restos ////////////////////////////////////
// Future<void> readPartialJsonFile(String filePath) async {
//   try {
//     File file = File(filePath);
//     if (await file.exists()) {
//       String jsonContent = await file.readAsString();
      
//       // Parse only the part of JSON that's available
//       Map<String, dynamic> jsonData = jsonDecode(jsonContent);
      
//       if (jsonData.containsKey('restoName')) {
//         // Procède avec les données déjà disponibles
//         String restoName = jsonData['restoName'];
//         print('Resto Name: $restoName');
//       }

//       // Continue de traiter les données écrites
//     } else {
//       print('Le fichier n\'existe pas encore.');
//     }
//   } catch (e) {
//     print('Erreur lors de la lecture du fichier JSON: $e');
//   }
// }


//   Future<void> createOrUpdateGLOBALLocalizedRestoInfosJsonFile(
//     List<Restaurant> restoList, BuildContext context) async {
//   restoInfosLocalizedFinishedLoading.value = false;
//   String deviceLocale = context.locale.languageCode;
//   bool needsTranslate = deviceLocale != "fr";

//   try {
//     // Liste pour stocker les infos traduites des restaurants
//     List<Map<String, dynamic>> translatedRestoInfos = [];

//     for (Restaurant resto in restoList) {
//       String translatedName = resto.name;
//       String translatedAddress = resto.address;
//       String translatedCuisine = resto.cuisine;

//       if (needsTranslate) {
//         // Traduire les champs nécessaires
//         translatedName = await customTranslate.translate(resto.name, 'fr', deviceLocale);
//         translatedAddress = await customTranslate.translate(resto.address, 'fr', deviceLocale);
//         translatedCuisine = await customTranslate.translate(resto.cuisine, 'fr', deviceLocale);

//         // Traduire les reviews
//         List<Map<String, dynamic>> translatedReviews = [];
//         for (ReviewRestau review in resto.reviews) {
//           String translatedReviewText = await customTranslate.translate(review.text, 'fr', deviceLocale);
//           translatedReviews.add({
//             'author': review.author,
//             'text': translatedReviewText,
//             'rating': review.rating
//           });
//         }

//         // Ajouter les infos du resto traduites
//         translatedRestoInfos.add({
//           'id': resto.id,
//           'name': resto.name, // Nom non traduit
//           'translated_name': translatedName,
//           'translated_address': translatedAddress,
//           'translated_cuisine': translatedCuisine,
//           'translated_reviews': translatedReviews
//         });
//       } else {
//         // Si aucune traduction n'est nécessaire
//         translatedRestoInfos.add({
//           'id': resto.id,
//           'name': resto.name,
//           'translated_name': resto.name,
//           'translated_address': resto.address,
//           'translated_cuisine': resto.cuisine,
//           'translated_reviews': resto.reviews.map((review) => {
//             'author': review.author,
//             'text': review.text,
//             'rating': review.rating
//           }).toList()
//         });
//       }
//     }

//     // Convertir en JSON
//     String restoInfosJson = jsonEncode(translatedRestoInfos);

//     // Obtenir le répertoire de documents de l'application
//     Directory directory = await getApplicationDocumentsDirectory();
//     String cacheDirPath = '${directory.path}/pseudo_caches';
//     Directory cacheDir = Directory(cacheDirPath);

//     // Si le répertoire n'existe pas, le créer
//     if (!(await cacheDir.exists())) {
//       await cacheDir.create(recursive: true);
//     }

//     // Créer et écrire dans le fichier localized_resto_infos_{locale}.json
//     String filePath = '$cacheDirPath/localized_resto_infos.json';
//     File file = File(filePath);
//     await file.writeAsString(restoInfosJson);

//     restoInfosLocalizedFinishedLoading.value = true;
//   } catch (e, stacktrace) {
//     logger.e("Erreur lors de la création ou mise à jour du fichier des restaurants localisés : $e");
//     logger.e("Stacktrace: $stacktrace");
//   }
// }



//pour les filtres ////////////////////////////////////////////////////////////////////////////////////////

  Future<List<Tag>> readJsonFile() async {
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/pseudo_caches/filtres_fr.json'; // Corrigé le chemin

      File file = File(filePath);

      // Vérifier si le fichier existe
      if (await file.exists()) {
        String fileContent = await file.readAsString();
        List<dynamic> jsonData = jsonDecode(fileContent);

        // Convertir les données JSON en objets Tag
        List<Tag> tags = jsonData.map((tagJson) => Tag.fromJson(tagJson)).toList();
        return tags;
      } else {
        print("Le fichier filtres.json n'existe pas.");
        return [];
      }
    } catch (e) {
      print("Erreur lors de la lecture du fichier filtres.json : $e");
      return [];
    }
  }

    Future<List<Tag>> readGLOBALJsonFile() async {
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/pseudo_caches/filtres.json'; // Corrigé le chemin

      File file = File(filePath);

      // Vérifier si le fichier existe
      if (await file.exists()) {
        String fileContent = await file.readAsString();
        List<dynamic> jsonData = jsonDecode(fileContent);

        // Convertir les données JSON en objets Tag
        List<Tag> tags = jsonData.map((tagJson) => Tag.fromJson(tagJson)).toList();
        return tags;
      } else {
        print("Le fichier filtres.json n'existe pas.");
        return [];
      }
    } catch (e) {
      print("Erreur lors de la lecture du fichier filtres.json : $e");
      return [];
    }
  }


// Future<void> createOrUpdateGLOBALLocalizedRestoInfosJsonFile(List<Restaurant> restoList, BuildContext context) async {
//   restoInfosLocalizedFinishedLoading.value = false;
//   String deviceLocale = context.locale.languageCode;
//   bool needsTranslate = deviceLocale != "fr";
//   try {
//     // Traduire les tags dans la langue de la locale
//     String restoInfosJson;
//     if(needsTranslate){
//       List<Restaurant> translatedRestoInfos = [];
//       for (Restaurant resto in restoList) {
//         String translatedRestoInfos = await customTranslate.translate(tag.tag, 'fr', deviceLocale);
//         translatedTags.add(Tag(id: tag.id, tag: translatedTag, type: tag.type));
//       }
//       // Convertir les tags traduits en JSON
//       tagsJson = jsonEncode(translatedTags.map((tag) => tag.toJson()).toList());
//     }else{
//       tagsJson = jsonEncode(tags.map((tag) => tag.toJson()).toList());
//     }
//     // Obtenir le répertoire de documents de l'application
//     Directory directory = await getApplicationDocumentsDirectory();
//     // Créer le chemin pour le sous-répertoire pseudo_caches
//     String cacheDirPath = '${directory.path}/pseudo_caches';
//     Directory cacheDir = Directory(cacheDirPath);
//     // Si le répertoire n'existe pas, le créer
//     if (!(await cacheDir.exists())) {
//       await cacheDir.create(recursive: true); // Crée tous les sous-répertoires nécessaires
//     }
//     // Créer le chemin du fichier en fonction de la locale
//     String filePath = '$cacheDirPath/filtres.json';
//     // Créer et écrire dans le fichier filtres_{locale}.json
//     File file = File(filePath);
//     await file.writeAsString(tagsJson);
//     restoInfosLocalizedFinishedLoading.value = true;
//   } catch (e, stacktrace) {
//     logger.e("Erreur lors de la création ou mise à jour du fichier GLOBAL filtres.json : $e");
//     logger.e("Stacktrace: $stacktrace");
//   }
// }

//à renommer car ce n'est que pour les filtre ou alors à fusionner avec la methode pour la cuisine, ca serait meme mieux mais la méthode serait un tantinet plus long à executer
Future<void> createOrUpdateGLOBALLocalizedJsonFile(List<Tag> tags, BuildContext context) async {
  filtersLocalizedFinishedLoading.value = false;
  logger.d("Entrée dans createOrUpdateGLOBALLocalizedJsonFile");  // Debug 8
  String deviceLocale = context.locale.languageCode;
  logger.d("Locale de l'appareil: $deviceLocale");  // Debug 9
  bool needsTranslate = deviceLocale != "fr";
  logger.d("needsTranslate: $needsTranslate");  // Debug 9

  try {
    // Traduire les tags dans la langue de la locale
    String tagsJson;
    if(needsTranslate){
      List<Tag> translatedTags = [];
      for (Tag tag in tags) {
        logger.d("Traduction du tag: ${tag.tag}");  // Debug 10
        String translatedTag = await customTranslate.translate(tag.tag, 'fr', deviceLocale);
        logger.d("Tag traduit: $translatedTag");  // Debug 11
        translatedTags.add(Tag(id: tag.id, tag: translatedTag, type: tag.type));
      }

      // Convertir les tags traduits en JSON
      tagsJson = jsonEncode(translatedTags.map((tag) => tag.toJson()).toList());
    }else{
      tagsJson = jsonEncode(tags.map((tag) => tag.toJson()).toList());
    }
    logger.d("JSON des tags traduits généré");  // Debug 12

    // Obtenir le répertoire de documents de l'application
    Directory directory = await getApplicationDocumentsDirectory();
    logger.d("Répertoire de documents obtenu: ${directory.path}");  // Debug 13

    // Créer le chemin pour le sous-répertoire pseudo_caches
    String cacheDirPath = '${directory.path}/pseudo_caches';
    logger.d("Chemin du cache: $cacheDirPath");  // Debug 14
    Directory cacheDir = Directory(cacheDirPath);

    // Si le répertoire n'existe pas, le créer
    if (!(await cacheDir.exists())) {
      logger.d("Le répertoire n'existe pas, création...");  // Debug 15
      await cacheDir.create(recursive: true); // Crée tous les sous-répertoires nécessaires
    }

    // Créer le chemin du fichier en fonction de la locale
    String filePath = '$cacheDirPath/filtres.json';
    logger.d("Chemin du fichier localisé: $filePath");  // Debug 16

    // Créer et écrire dans le fichier filtres_{locale}.json
    File file = File(filePath);
    await file.writeAsString(tagsJson);

    logger.d("Fichier GLOBAL filtres.json créé/mis à jour");  // Debug 17
    filtersLocalizedFinishedLoading.value = true;
  } catch (e, stacktrace) {
    logger.e("Erreur lors de la création ou mise à jour du fichier GLOBAL filtres.json : $e");
    logger.e("Stacktrace: $stacktrace");
  }
}

Future<void> createOrUpdateJsonFile(List<Tag> tags) async {
  logger.d("Entrée dans createOrUpdateJsonFile");  // Debug 1
  try {
    // Convertir les tags en JSON
    logger.d("Conversion des tags en JSON");  // Debug 2
    String tagsJson = jsonEncode(tags.map((tag) => tag.toJson()).toList());

    // Obtenir le répertoire de documents de l'application
    logger.d("Obtention du répertoire de documents");  // Debug 3
    Directory directory = await getApplicationDocumentsDirectory();

    // Créer le chemin pour le sous-répertoire pseudo_caches
    String cacheDirPath = '${directory.path}/pseudo_caches';
    logger.d("Chemin du cache: $cacheDirPath");  // Debug 4
    Directory cacheDir = Directory(cacheDirPath);

    // Si le répertoire n'existe pas, le créer
    if (!(await cacheDir.exists())) {
      logger.d("Le répertoire n'existe pas, création...");  // Debug 5
      await cacheDir.create(recursive: true); // Crée tous les sous-répertoires nécessaires
    }

    // Chemin du fichier filtres.json dans ce sous-répertoire
    String filePath = '$cacheDirPath/filtres_fr.json';
    logger.d("Chemin du fichier: $filePath");  // Debug 6

    // Créer et écrire dans le fichier filtres.json
    File file = File(filePath);
    await file.writeAsString(tagsJson);

    logger.d("Fichier filtres_fr.json créé/mis à jour");  // Debug 7
  } catch (e, stacktrace) {
    logger.e("Erreur lors de la création ou mise à jour du fichier filtres_fr.json : $e");
    logger.e("Stacktrace: $stacktrace");
  }
}

// Future<void> createOrUpdateLocalizedJsonFile(List<Tag> tags, BuildContext context) async {
//   logger.d("Entrée dans createOrUpdateLocalizedJsonFile");  // Debug 8
//   String deviceLocale = context.locale.languageCode;
//   logger.d("Locale de l'appareil: $deviceLocale");  // Debug 9
//   try {
//     // Traduire les tags dans la langue de la locale
//     List<Tag> translatedTags = [];
//     for (Tag tag in tags) {
//       logger.d("Traduction du tag: ${tag.tag}");  // Debug 10
//       String translatedTag = await customTranslate.translate(tag.tag, 'fr', deviceLocale);
//       logger.d("Tag traduit: $translatedTag");  // Debug 11
//       translatedTags.add(Tag(id: tag.id, tag: translatedTag, type: tag.type));
//     }

//     // Convertir les tags traduits en JSON
//     String tagsJson = jsonEncode(translatedTags.map((tag) => tag.toJson()).toList());
//     logger.d("JSON des tags traduits généré");  // Debug 12

//     // Obtenir le répertoire de documents de l'application
//     Directory directory = await getApplicationDocumentsDirectory();
//     logger.d("Répertoire de documents obtenu: ${directory.path}");  // Debug 13

//     // Créer le chemin pour le sous-répertoire pseudo_caches
//     String cacheDirPath = '${directory.path}/pseudo_caches';
//     logger.d("Chemin du cache: $cacheDirPath");  // Debug 14
//     Directory cacheDir = Directory(cacheDirPath);

//     // Si le répertoire n'existe pas, le créer
//     if (!(await cacheDir.exists())) {
//       logger.d("Le répertoire n'existe pas, création...");  // Debug 15
//       await cacheDir.create(recursive: true); // Crée tous les sous-répertoires nécessaires
//     }

//     // Créer le chemin du fichier en fonction de la locale
//     String filePath = '$cacheDirPath/filtres_$deviceLocale.json';
//     logger.d("Chemin du fichier localisé: $filePath");  // Debug 16

//     // Créer et écrire dans le fichier filtres_{locale}.json
//     File file = File(filePath);
//     await file.writeAsString(tagsJson);

//     logger.d("Fichier filtres_$deviceLocale.json créé/mis à jour");  // Debug 17
//   } catch (e, stacktrace) {
//     logger.e("Erreur lors de la création ou mise à jour du fichier filtres_$deviceLocale.json : $e");
//     logger.e("Stacktrace: $stacktrace");
//   }
// }
