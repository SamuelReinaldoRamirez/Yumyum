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

Future<void> createOrUpdateGLOBALLocalizedRestoInfosJsonFileBatched(
    List<Restaurant> restoList, 
    BuildContext context, 
    int batchSize) async {
  
  String deviceLocale = context.locale.languageCode;
  bool needsTranslate = deviceLocale != "fr";
  
  try {
    // Effacer le contenu du fichier JSON au début 
    Directory directory = await getApplicationDocumentsDirectory();
    String cacheDirPath = '${directory.path}/pseudo_caches';
    Directory cacheDir = Directory(cacheDirPath);
    if (!(await cacheDir.exists())) {
      await cacheDir.create(recursive: true);
    }
    String filePath = '$cacheDirPath/localized_resto_infos.json';
    File file = File(filePath);
    
    // Écrire une chaîne vide pour effacer le contenu du fichier
    await file.writeAsString(''); 

    for (int i = 0; i < restoList.length; i += batchSize) {
      // Obtenir le batch courant
      List<Restaurant> batch = restoList.sublist(
        i, 
        (i + batchSize > restoList.length) ? restoList.length : i + batchSize
      );

      // Concaténer toutes les infos des restaurants dans un seul string pour une traduction en une seule fois
      String batchForTranslation = batch
          .map((resto) => '${resto.name}|${resto.address}|${resto.cuisine}')
          .join('||'); // Double séparateur pour séparer les restos

      // Effectuer une seule traduction pour tout le batch
      String translatedBatch = needsTranslate
          ? await customTranslate.translate(batchForTranslation, 'fr', deviceLocale)
          : batchForTranslation;

      // Séparer les traductions des différents restaurants
      List<String> translatedRestos = translatedBatch.split('||');

      List<Map<String, dynamic>> translatedRestoInfos = []; // Nouveau pour chaque batch

      for (int j = 0; j < batch.length; j++) {
        Restaurant resto = batch[j];
        String translatedString = translatedRestos[j];

        // Recréer les éléments traduits à partir de la chaîne traduite
        List<String> translatedParts = translatedString.split('|');
        String translatedName = translatedParts[0];
        String translatedAddress = translatedParts[1];
        String translatedCuisine = translatedParts[2];

        translatedRestoInfos.add({
          'id': resto.id,
          'name': resto.name,
          'translated_name': translatedName,
          'translated_address': translatedAddress,
          'translated_cuisine': translatedCuisine,
        });
      }

      // Écriture des traductions dans le fichier JSON
      String restoInfosJson = jsonEncode(translatedRestoInfos);

      // Pour les batches suivants, supprimer le dernier ']' et ajouter les nouvelles traductions
      String existingContent = await file.readAsString();
      logger.d('Contenu du fichier JSON: $existingContent');
      existingContent = existingContent.trim();
      String restoInfoToWrite=restoInfosJson;
      if (existingContent.endsWith(']')) {
        existingContent = existingContent.substring(0, existingContent.length - 1);
        restoInfoToWrite = restoInfosJson.substring(1);
        await file.writeAsString('$existingContent,$restoInfoToWrite', mode: FileMode.write);
      }else{
        await file.writeAsString(restoInfoToWrite, mode: FileMode.write);
      }

//debug
      // String jsonContent = await file.readAsString();
      // logger.d('Contenu du fichier JSON: $jsonContent');

//debug
      // // Attendre 5 secondes avant de passer au batch suivant
      // print("WAIIIITTT");
      // await Future.delayed(Duration(seconds: 10));
    }
//debug
    // String jsonContent = await file.readAsString();
    // logger.d('Contenu du fichier JSON: $jsonContent');
  } catch (e, stacktrace) {
    logger.e("Erreur lors de la création/mise à jour du fichier des restaurants localisés : $e");
    logger.e("Stacktrace: $stacktrace");
  }
}


// Future<Map<String, dynamic>?> readPartialJsonFileForRestaurantDirect(String restaurantId, Restaurant restaurant, BuildContext context) async {
//   print("ALOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO");
//   try {
//     Directory directory = await getApplicationDocumentsDirectory();
//     String cacheDirPath = '${directory.path}/pseudo_caches';
//     String filePath = '$cacheDirPath/localized_resto_infos.json';

//     File file = File(filePath);
//     if (await file.exists()) {
//       String jsonContent = await file.readAsString();

//       // Vérifier et déboguer le contenu du fichier
//       logger.d('Contenu du fichier JSONNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN: $jsonContent');

//       jsonContent = jsonContent.trim();
//       print("CONTENT POST TRIM");
//       print(jsonContent);

//       if (jsonContent.startsWith('[') && jsonContent.endsWith(']')) {
//         print("TRUE");
//         // Fichier complet
//         List<dynamic> jsonData = jsonDecode(jsonContent);
//         for (var resto in jsonData) {
//           print("***************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************");
//           print(resto);
//           if (resto['id'].toString() == restaurantId.toString()) {
//             logger.e("FINIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII");
//             return {
//               'name': resto['name'],
//               'translated_name': resto['translated_name'],
//               'translated_address': resto['translated_address'],
//               'translated_cuisine': resto['translated_cuisine'],
//             };
//           }
//         }
//       } else if (jsonContent.startsWith('[')) {
//         print("TRUE2");
//         // Fichier partiel
//         int lastValidIndex = jsonContent.lastIndexOf('},');
//         if (lastValidIndex != -1) {
//           String partialContent = jsonContent.substring(0, lastValidIndex + 1) + ']';
//           List<dynamic> jsonData = jsonDecode(partialContent);
//           for (var resto in jsonData) {
//             if (resto['id'].toString() == restaurantId.toString()) {
//               logger.e("EN COUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUrs");
//               return {
//                 'name': resto['name'],
//                 'translated_name': resto['translated_name'],
//                 'translated_address': resto['translated_address'],
//                 'translated_cuisine': resto['translated_cuisine'],
//               };
//             }
//           }
//         }
//       }
//     } else {
//       logger.e('Le fichier n\'existe pas encore.');
//     }
//   } catch (e) {
//     logger.e('Erreur lors de la lecture du fichier JSON: $e');
//   }

//  try {

//     String deviceLocale = context.locale.languageCode;
//     // Récupération des informations du restaurant à traduire (simulé ici, à remplacer par votre source de données)
//     String originalName = restaurant.name; // À remplacer par la récupération réelle
//     String originalAddress = restaurant.address; // À remplacer par la récupération réelle
//     String originalCuisine = restaurant.cuisine; // À remplacer par la récupération réelle

//       // Concaténation des informations pour une traduction en une seule fois
//       String toTranslate = "$originalName|$originalAddress|$originalCuisine";
//       String translatedResult = await customTranslate.translate(toTranslate, 'fr', deviceLocale);

//       // Séparer les résultats traduits
//       List<String> translatedParts = translatedResult.split('|');

//       return {
//         'name': originalName,
//         'translated_name': translatedParts[0],
//         'translated_address': translatedParts[1],
//         'translated_cuisine': translatedParts[2],
//       };

//   } catch (e) {
//     logger.e('Erreur lors de la traduction: $e');
//     return null; // Renvoyer null si une erreur survient pendant la traduction
//   }
// }


//sans l'alerte
Future<Map<String, dynamic>?> readPartialJsonFileForRestaurant(String restaurantId, BuildContext context) async {
  print("ALOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO");
  try {
    Directory directory = await getApplicationDocumentsDirectory();
    String cacheDirPath = '${directory.path}/pseudo_caches';
    String filePath = '$cacheDirPath/localized_resto_infos.json';

    File file = File(filePath);
    if (await file.exists()) {
      String jsonContent = await file.readAsString();

      // Vérifier et déboguer le contenu du fichier
      logger.d('Contenu du fichier JSONNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN: $jsonContent');

      jsonContent = jsonContent.trim();
      print("CONTENT POST TRIM");
      print(jsonContent);

      if (jsonContent.startsWith('[') && jsonContent.endsWith(']')) {
        print("TRUE");
        // Fichier complet
        List<dynamic> jsonData = jsonDecode(jsonContent);
        for (var resto in jsonData) {
          print("***************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************");
          print(resto);
          if (resto['id'].toString() == restaurantId.toString()) {
            logger.e("FINIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII");
            return {
              'name': resto['name'],
              'translated_name': resto['translated_name'],
              'translated_address': resto['translated_address'],
              'translated_cuisine': resto['translated_cuisine'],
            };
          }
        }
      } else if (jsonContent.startsWith('[')) {
        print("TRUE2");
        // Fichier partiel
        int lastValidIndex = jsonContent.lastIndexOf('},');
        if (lastValidIndex != -1) {
          String partialContent = jsonContent.substring(0, lastValidIndex + 1) + ']';
          List<dynamic> jsonData = jsonDecode(partialContent);
          for (var resto in jsonData) {
            if (resto['id'].toString() == restaurantId.toString()) {
              logger.e("EN COUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUrs");
              return {
                'name': resto['name'],
                'translated_name': resto['translated_name'],
                'translated_address': resto['translated_address'],
                'translated_cuisine': resto['translated_cuisine'],
              };
            }
          }
        }
      }
    } else {
      logger.e('Le fichier n\'existe pas encore.');
    }
  } catch (e) {
    logger.e('Erreur lors de la lecture du fichier JSON: $e');
  }

  // Retourne null si le restaurant n'est pas trouvé
  logger.e("PAS TROUVEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE");
  return null;
}

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

//à renommer car ce n'est que pour les filtre ou alors à fusionner avec la methode pour la cuisine, ca serait meme mieux mais la méthode serait un tantinet plus long à executer
Future<void> createOrUpdateGLOBALLocalizedJsonFileBatched(
    List<Tag> tags, 
    BuildContext context, 
    int batchSize) async {
  
  filtersLocalizedFinishedLoading.value = false;
  String deviceLocale = context.locale.languageCode;
  bool needsTranslate = deviceLocale != "fr";

  try {
    List<Map<String, dynamic>> translatedTagsBatch = [];

    for (int i = 0; i < tags.length; i += batchSize) {
      // Obtenir le batch courant
      List<Tag> batch = tags.sublist(
        i, 
        (i + batchSize > tags.length) ? tags.length : i + batchSize
      );

      // Concaténer tous les tags dans un seul string pour une traduction en une seule fois
      String batchForTranslation = batch
          .map((tag) => tag.tag)
          .join('|');  // Utilisation d'un séparateur unique

      // Effectuer une seule traduction pour tout le batch
      String translatedBatch = needsTranslate
          ? await customTranslate.translate(batchForTranslation, 'fr', deviceLocale)
          : batchForTranslation;

      // Séparer les tags traduits
      List<String> translatedTags = translatedBatch.split('|');

      for (int j = 0; j < batch.length; j++) {
        Tag tag = batch[j];
        String translatedTag = translatedTags[j];

        translatedTagsBatch.add({
          'id': tag.id,
          'tag': translatedTag,
          'type': tag.type,
        });
      }
    }

    // Conversion en JSON et écriture du fichier
    String tagsJson = jsonEncode(translatedTagsBatch);
    Directory directory = await getApplicationDocumentsDirectory();
    String cacheDirPath = '${directory.path}/pseudo_caches';
    Directory cacheDir = Directory(cacheDirPath);
    if (!(await cacheDir.exists())) {
      await cacheDir.create(recursive: true);
    }
    String filePath = '$cacheDirPath/filtres.json';
    File file = File(filePath);
    await file.writeAsString(tagsJson);
    filtersLocalizedFinishedLoading.value = true;
    
  } catch (e, stacktrace) {
    logger.e("Erreur lors de la création/mise à jour du fichier des tags localisés : $e");
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