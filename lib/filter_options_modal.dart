// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/filter_bar.dart';
import 'package:yummap/mixpanel_service.dart';
import 'package:yummap/tag.dart';
import 'package:yummap/theme.dart';
import 'package:yummap/translate_utils.dart';
import 'package:path_provider/path_provider.dart'; // Pour accéder aux chemins de fichiers locaux

import 'restaurant.dart';

class FilterOptionsModal extends StatefulWidget {
  final List<int> initialSelectedTagIds;
  final ValueChanged<List<int>> onApply;
  // final FilterBarState parentState;

  const FilterOptionsModal({
    Key? key,
    required this.initialSelectedTagIds,
    required this.onApply,
    // required this.parentState,
  }) : super(key: key);

  @override
  _FilterOptionsModalState createState() => _FilterOptionsModalState();
}

class _FilterOptionsModalState extends State<FilterOptionsModal> {
  List<int> selectedTagIds = [];
  List<Tag> tagList = [];
  static final CustomTranslate customTranslate = CustomTranslate(); // Ajout de l'instance


//   @override
//   void initState() {
//     super.initState();
//     selectedTagIds = List.from(widget.initialSelectedTagIds);
//     _fetchTagList();
//   }

// Future<void> _fetchTagList() async {
//   try {
//     // Obtenir le chemin du fichier filtres.json
//     Directory directory = await getApplicationDocumentsDirectory();
//     String filePath = '${directory.path}/assets/pseudo_caches/filtres.json';
    
//     // Lire le fichier JSON
//     File file = File(filePath);
//     if (await file.exists()) {
//       String jsonString = await file.readAsString();
      
//       // Décoder le JSON en List<Tag>
//       List<dynamic> jsonResponse = jsonDecode(jsonString);
//       List<Tag> tags = jsonResponse.map((tagJson) => Tag.fromJson(tagJson)).toList();
      
//       setState(() {
//         tagList = tags;
//       });
//     } else {
//       // Si le fichier n'existe pas, gérer le cas ici (ou le créer à partir de Xano)
//       print("Le fichier filtres.json n'existe pas.");
//     }
//   } catch (e) {
//     print("Erreur lors de la lecture du fichier filtres.json: $e");
//   }
// }


// Future<List<Tag>> readJsonFile() async {
//   try {
//     Directory directory = await getApplicationDocumentsDirectory();
//     String filePath = '${directory.path}/pseudo_caches/filtres.json';
    
//     File file = File(filePath);

//     // Vérifier si le fichier existe
//     if (await file.exists()) {
//       String fileContent = await file.readAsString();
//       List<dynamic> jsonData = jsonDecode(fileContent);

//       // Convertir les données JSON en objets Tag
//       List<Tag> tags = jsonData.map((tagJson) => Tag.fromJson(tagJson)).toList();
//       return tags;
//     } else {
//       print("Le fichier filtres.json n'existe pas.");
//       return [];
//     }
//   } catch (e) {
//     print("Erreur lors de la lecture du fichier filtres.json : $e");
//     return [];
//   }
// }


 @override
  void initState() {
    super.initState();
    selectedTagIds = List.from(widget.initialSelectedTagIds);
    _fetchTagList();
  }

  Future<void> _fetchTagList() async {
    try {
      // Obtenir le chemin du fichier filtres.json
      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/pseudo_caches/filtres.json'; // Corrigé le chemin

      // Lire le fichier JSON
      File file = File(filePath);
      if (await file.exists()) {
        String jsonString = await file.readAsString();

        // Décoder le JSON en List<Tag>
        List<dynamic> jsonResponse = jsonDecode(jsonString);
        List<Tag> tags = jsonResponse.map((tagJson) => Tag.fromJson(tagJson)).toList();

        setState(() {
          tagList = tags;
        });
      } else {
        // Si le fichier n'existe pas, gérer le cas ici (ou le créer à partir de Xano)
        print("Le fichier filtres.json n'existe pas.");
      }
    } catch (e) {
      print("Erreur lors de la lecture du fichier filtres.json: $e");
    }
  }

  Future<List<Tag>> readJsonFile() async {
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


  // Future<void> _fetchTagList() async {
  //   List<Tag> tags = await CallEndpointService().getTagsFromXanos();
  //   setState(() {
  //     tagList = tags;
  //   });
  // }

  Widget _buildApplyButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: ElevatedButton(
        onPressed: () async {
          widget.onApply(selectedTagIds);
          MixpanelService.instance.track('FilterTagSearch', properties: {
            'filter_ids': selectedTagIds,
          });
          //  List<Restaurant> newRestaurants = await widget.parentState.generalFilter();
          List<Restaurant> newRestaurants = await FilterBarState.generalFilter();
           if (newRestaurants.isEmpty) {
            Navigator.of(context).pop(); // Ferme le BottomSheet
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("no result found for those filters".tr()),
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: "OK".tr(),
                  onPressed: () {
                    // Action à effectuer lorsque l'utilisateur appuie sur le bouton OK
                  },
                ),
              ),
            );
          }else{
            Navigator.of(context).pop();
          }
        },
        style: AppButtonStyles.elevatedButtonStyle,
        child: Text("apply".tr()),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: Text(
        "filters".tr(),
        style: AppTextStyles.titleDarkStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: handleBackNavigation(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTitle(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tagList.length,
                    itemBuilder: (context, index) {
                      final tag = tagList[index];
                      return CheckboxListTile(
                        // title: 
                        // Text(
                        //   tag.tag,
                        //   style: AppTextStyles.paragraphDarkStyle,
                        // ),


                        title: context.locale.languageCode == "fr"
                          ? Text(
                              tag.tag, // Affiche le texte d'origine si la langue est "fr"
                              style: AppTextStyles.paragraphDarkStyle,
                            )
                          : FutureBuilder<String>(
                              future: customTranslate.translate(
                                tag.tag,
                                "fr", 
                                context.locale.languageCode == "zh" ? "zh-cn" : context.locale.languageCode
                              ), // Utilisation de l'instance pour la traduction
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const SizedBox(
                                    width: 50, // Optionnel, pour donner une largeur fixe à la barre
                                    child: LinearProgressIndicator(), // Affiche une barre de progression 2D
                                  );
                                  // return CircularProgressIndicator(); // Affiche un indicateur de chargement pendant la traduction
                                } else if (snapshot.hasError) {
                                  return Text('Erreur de traduction: ${snapshot.error}');
                                } else {
                                  return Text(
                                    snapshot.data ?? tag.tag, // Affiche le texte traduit, ou le texte d'origine si la traduction échoue
                                    style: AppTextStyles.paragraphDarkStyle,
                                  );
                                }
                              },
                            ),


                        value: selectedTagIds.contains(tag.id),
                        checkColor: Colors.white,
                        activeColor: AppColors.greenishGrey,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value != null && value) {
                              selectedTagIds.add(tag.id);
                            } else {
                              selectedTagIds.remove(tag.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          _buildApplyButton(context),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  bool handleBackNavigation() {
    //à ne pas supprimer : ici on définit ce qu'il se passe quand on clique en dehors du bottomsheet
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // AlertDialog(semanticLabel: "selection perdue");
    // });
    return true; // Retourne true pour permettre le pop, false pour l'empêcher
  }


}
