// import 'dart:convert';
// import 'dart:io';

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';
// import 'package:yummap/tag.dart';
// import 'package:yummap/translate_utils.dart';
// import 'package:path_provider/path_provider.dart';

// getApplicationDocumentsDirectory() {
// }

// // Future<Directory> getApplicationDocumentsDirectory() async {
// //   return await getApplicationDocumentsDirectory();
// // }


// Logger logger = Logger();
// final CustomTranslate customTranslate = CustomTranslate(); // Ajout de l'instance


// Future<void> createOrUpdateJsonFile(List<Tag> tags, BuildContext context) async {
//   logger.e("A1");
//   try {
//     // Convertir les tags en JSON
//     String tagsJson = jsonEncode(tags.map((tag) => tag.toJson()).toList());
//     logger.e("A2");

//     // Obtenir le répertoire de documents de l'application
//     Directory directory = await getApplicationDocumentsDirectory();
//     logger.e("A3");

//     // Créer le chemin pour le sous-répertoire pseudo_caches
//     String cacheDirPath = '${directory.path}/pseudo_caches';
//     logger.e("A");
//     logger.e(cacheDirPath);
//     Directory cacheDir = Directory(cacheDirPath);

//     // Si le répertoire n'existe pas, le créer
//     if (!(await cacheDir.exists())) {
//       await cacheDir.create(recursive: true); // Crée tous les sous-répertoires nécessaires
//     }

//     // Chemin du fichier filtres.json dans ce sous-répertoire
//     String filePath = '$cacheDirPath/filtres_fr.json';

//     // Créer et écrire dans le fichier filtres.json
//     File file = File(filePath);
//     await file.writeAsString(tagsJson);

//     print("Fichier filtres.json créé/mis à jour dans : $filePath");
//   } catch (e) {
//     print("Erreur lors de la création ou mise à jour du fichier filtres.json : $e");
//   }
// }

// Future<void> createOrUpdateLocalizedJsonFile(List<Tag> tags, BuildContext context) async {
//   String deviceLocale = context.locale.languageCode;
//   try {
//     // Obtenir la locale de l'appareil

//     // Traduire les tags dans la langue de la locale
//     List<Tag> translatedTags = [];
//     for (Tag tag in tags) {
//       String translatedTag = await customTranslate.translate(tag.tag, 'fr', deviceLocale);
//       translatedTags.add(Tag(id: tag.id, tag: translatedTag, type: tag.type));
//     }

//     // Convertir les tags traduits en JSON
//     String tagsJson = jsonEncode(translatedTags.map((tag) => tag.toJson()).toList());

//     // Obtenir le répertoire de documents de l'application
//     Directory directory = await getApplicationDocumentsDirectory();

//     // Créer le chemin pour le sous-répertoire pseudo_caches
//     String cacheDirPath = '${directory.path}/pseudo_caches';
//     logger.e("B");
//     logger.e(cacheDirPath);
//     Directory cacheDir = Directory(cacheDirPath);

//     // Si le répertoire n'existe pas, le créer
//     if (!(await cacheDir.exists())) {
//       await cacheDir.create(recursive: true); // Crée tous les sous-répertoires nécessaires
//     }

//     // Créer le chemin du fichier en fonction de la locale
//     String filePath = '$cacheDirPath/filtres_$deviceLocale.json';

//     // Créer et écrire dans le fichier filtres_{locale}.json
//     File file = File(filePath);
//     await file.writeAsString(tagsJson);

//     print("Fichier filtres_$deviceLocale.json créé/mis à jour dans : $filePath");
//   } catch (e) {
//     print("Erreur lors de la création ou mise à jour du fichier filtres_$deviceLocale.json : $e");
//   }
// }


import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:yummap/global.dart';
import 'package:yummap/tag.dart';
import 'package:yummap/translate_utils.dart';
import 'package:path_provider/path_provider.dart';

Logger logger = Logger();
final CustomTranslate customTranslate = CustomTranslate(); // Ajout de l'instance

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

Future<void> createOrUpdateLocalizedJsonFile(List<Tag> tags, BuildContext context) async {
  logger.d("Entrée dans createOrUpdateLocalizedJsonFile");  // Debug 8
  String deviceLocale = context.locale.languageCode;
  logger.d("Locale de l'appareil: $deviceLocale");  // Debug 9
  try {
    // Traduire les tags dans la langue de la locale
    List<Tag> translatedTags = [];
    for (Tag tag in tags) {
      logger.d("Traduction du tag: ${tag.tag}");  // Debug 10
      String translatedTag = await customTranslate.translate(tag.tag, 'fr', deviceLocale);
      logger.d("Tag traduit: $translatedTag");  // Debug 11
      translatedTags.add(Tag(id: tag.id, tag: translatedTag, type: tag.type));
    }

    // Convertir les tags traduits en JSON
    String tagsJson = jsonEncode(translatedTags.map((tag) => tag.toJson()).toList());
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
    String filePath = '$cacheDirPath/filtres_$deviceLocale.json';
    logger.d("Chemin du fichier localisé: $filePath");  // Debug 16

    // Créer et écrire dans le fichier filtres_{locale}.json
    File file = File(filePath);
    await file.writeAsString(tagsJson);

    logger.d("Fichier filtres_$deviceLocale.json créé/mis à jour");  // Debug 17
  } catch (e, stacktrace) {
    logger.e("Erreur lors de la création ou mise à jour du fichier filtres_$deviceLocale.json : $e");
    logger.e("Stacktrace: $stacktrace");
  }
}
