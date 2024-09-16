// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:yummap/filter_bar.dart';
// import 'package:yummap/filter_options_modal.dart';
// import 'package:yummap/global.dart';
// import 'package:yummap/theme.dart';
//
//
// void showLocaleSelectionDialog(BuildContext context) {
//   // Liste des locales
//   List<Locale> locales = [
//     Locale('af'), Locale('sq'), Locale('am'), Locale('ar'), Locale('hy'),
//     Locale('az'), Locale('eu'), Locale('be'), Locale('bn'), Locale('bs'),
//     Locale('bg'), Locale('ca'), Locale('ceb'), Locale('ny'), Locale('zh'),
//     Locale('co'), Locale('hr'), Locale('cs'), Locale('da'), Locale('nl'),
//     Locale('en'), Locale('eo'), Locale('et'), Locale('tl'), Locale('fi'),
//     Locale('fr'), Locale('fy'), Locale('gl'), Locale('ka'), Locale('de'),
//     Locale('el'), Locale('gu'), Locale('ht'), Locale('ha'), Locale('haw'),
//     Locale('he'), Locale('hi'), Locale('hmn'), Locale('hu'), Locale('is'),
//     Locale('ig'), Locale('id'), Locale('ga'), Locale('it'), Locale('ja'),
//     Locale('jw'), Locale('kn'), Locale('kk'), Locale('km'), Locale('ko'),
//     Locale('ku'), Locale('ky'), Locale('lo'), Locale('la'), Locale('lv'),
//     Locale('lt'), Locale('lb'), Locale('mk'), Locale('mg'), Locale('ms'),
//     Locale('ml'), Locale('mt'), Locale('mi'), Locale('mr'), Locale('mn'),
//     Locale('my'), Locale('ne'), Locale('no'), Locale('ps'), Locale('fa'),
//     Locale('pl'), Locale('pt'), Locale('pa'), Locale('ro'), Locale('ru'),
//     Locale('sm'), Locale('gd'), Locale('sr'), Locale('st'), Locale('sn'),
//     Locale('sd'), Locale('si'), Locale('sk'), Locale('sl'), Locale('so'),
//     Locale('es'), Locale('su'), Locale('sw'), Locale('sv'), Locale('tg'),
//     Locale('ta'), Locale('te'), Locale('th'), Locale('tr'), Locale('uk'),
//     Locale('ur'), Locale('uz'), Locale('ug'), Locale('vi'), Locale('cy'),
//     Locale('xh'), Locale('yi'), Locale('yo'), Locale('zu'),
//   ];

//   // Variable pour stocker la locale sélectionnée
//   Locale? selectedLocale;

//   // Afficher une boîte de dialogue
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Sélectionner une langue'),
//         content: StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             return DropdownButton<Locale>(
//               value: selectedLocale,
//               isExpanded: true,
//               hint: Text('Choisissez une langue'),
//               onChanged: (Locale? newValue) {
//                 setState(() {
//                   selectedLocale = newValue!;
//                 });
//               },
//               items: locales.map<DropdownMenuItem<Locale>>((Locale locale) {
//                 return DropdownMenuItem<Locale>(
//                   value: locale,
//                   child: Text(locale.languageCode),
//                 );
//               }).toList(),
//             );
//           },
//         ),
//         actions: [
//           TextButton(
//             child: Text('OK'),
//             onPressed: () {
//               Navigator.of(context).pop();
//               // Vous pouvez traiter la locale sélectionnée ici, par exemple :
//               if (selectedLocale != null) {
//                 print('Langue sélectionnée : ${selectedLocale!.languageCode}');
//                 context.setLocale(selectedLocale!);

//               }
//             },
//           ),
//           TextButton(
//             child: Text('Annuler'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }


import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:yummap/filter_bar.dart';
import 'package:yummap/filter_options_modal.dart';
import 'package:yummap/global.dart';
import 'package:yummap/theme.dart';
import 'package:yummap/translate_utils.dart';


Future<bool> showLocaleSelectionDialog(BuildContext context) async {
  // Liste des locales avec noms des langues en anglais
  List<Map<String, dynamic>> locales = [
    {'locale': Locale('af'), 'name': 'Afrikaans'},
    {'locale': Locale('sq'), 'name': 'Albanian'},
    {'locale': Locale('am'), 'name': 'Amharic'},
    {'locale': Locale('ar'), 'name': 'Arabic'},
    {'locale': Locale('hy'), 'name': 'Armenian'},
    {'locale': Locale('az'), 'name': 'Azerbaijani'},
    {'locale': Locale('eu'), 'name': 'Basque'},
    {'locale': Locale('be'), 'name': 'Belarusian'},
    {'locale': Locale('bn'), 'name': 'Bengali'},
    {'locale': Locale('bs'), 'name': 'Bosnian'},
    {'locale': Locale('bg'), 'name': 'Bulgarian'},
    {'locale': Locale('ca'), 'name': 'Catalan'},
    {'locale': Locale('ceb'), 'name': 'Cebuano'},
    {'locale': Locale('ny'), 'name': 'Chichewa'},
    {'locale': Locale('zh'), 'name': 'Chinese'},
    {'locale': Locale('co'), 'name': 'Corsican'},
    {'locale': Locale('hr'), 'name': 'Croatian'},
    {'locale': Locale('cs'), 'name': 'Czech'},
    {'locale': Locale('da'), 'name': 'Danish'},
    {'locale': Locale('nl'), 'name': 'Dutch'},
    {'locale': Locale('en'), 'name': 'English'},
    {'locale': Locale('eo'), 'name': 'Esperanto'},
    {'locale': Locale('et'), 'name': 'Estonian'},
    {'locale': Locale('tl'), 'name': 'Filipino'},
    {'locale': Locale('fi'), 'name': 'Finnish'},
    {'locale': Locale('fr'), 'name': 'French'},
    {'locale': Locale('fy'), 'name': 'Frisian'},
    {'locale': Locale('gl'), 'name': 'Galician'},
    {'locale': Locale('ka'), 'name': 'Georgian'},
    {'locale': Locale('de'), 'name': 'German'},
    {'locale': Locale('el'), 'name': 'Greek'},
    {'locale': Locale('gu'), 'name': 'Gujarati'},
    {'locale': Locale('ht'), 'name': 'Haitian Creole'},
    {'locale': Locale('ha'), 'name': 'Hausa'},
    {'locale': Locale('haw'), 'name': 'Hawaiian'},
    {'locale': Locale('he'), 'name': 'Hebrew'},
    {'locale': Locale('hi'), 'name': 'Hindi'},
    {'locale': Locale('hmn'), 'name': 'Hmong'},
    {'locale': Locale('hu'), 'name': 'Hungarian'},
    {'locale': Locale('is'), 'name': 'Icelandic'},
    {'locale': Locale('ig'), 'name': 'Igbo'},
    {'locale': Locale('id'), 'name': 'Indonesian'},
    {'locale': Locale('ga'), 'name': 'Irish'},
    {'locale': Locale('it'), 'name': 'Italian'},
    {'locale': Locale('ja'), 'name': 'Japanese'},
    {'locale': Locale('jw'), 'name': 'Javanese'},
    {'locale': Locale('kn'), 'name': 'Kannada'},
    {'locale': Locale('kk'), 'name': 'Kazakh'},
    {'locale': Locale('km'), 'name': 'Khmer'},
    {'locale': Locale('ko'), 'name': 'Korean'},
    {'locale': Locale('ku'), 'name': 'Kurdish'},
    {'locale': Locale('ky'), 'name': 'Kyrgyz'},
    {'locale': Locale('lo'), 'name': 'Lao'},
    {'locale': Locale('la'), 'name': 'Latin'},
    {'locale': Locale('lv'), 'name': 'Latvian'},
    {'locale': Locale('lt'), 'name': 'Lithuanian'},
    {'locale': Locale('lb'), 'name': 'Luxembourgish'},
    {'locale': Locale('mk'), 'name': 'Macedonian'},
    {'locale': Locale('mg'), 'name': 'Malagasy'},
    {'locale': Locale('ms'), 'name': 'Malay'},
    {'locale': Locale('ml'), 'name': 'Malayalam'},
    {'locale': Locale('mt'), 'name': 'Maltese'},
    {'locale': Locale('mi'), 'name': 'Maori'},
    {'locale': Locale('mr'), 'name': 'Marathi'},
    {'locale': Locale('mn'), 'name': 'Mongolian'},
    {'locale': Locale('my'), 'name': 'Myanmar (Burmese)'},
    {'locale': Locale('ne'), 'name': 'Nepali'},
    {'locale': Locale('no'), 'name': 'Norwegian'},
    {'locale': Locale('ps'), 'name': 'Pashto'},
    {'locale': Locale('fa'), 'name': 'Persian'},
    {'locale': Locale('pl'), 'name': 'Polish'},
    {'locale': Locale('pt'), 'name': 'Portuguese'},
    {'locale': Locale('pa'), 'name': 'Punjabi'},
    {'locale': Locale('ro'), 'name': 'Romanian'},
    {'locale': Locale('ru'), 'name': 'Russian'},
    {'locale': Locale('sm'), 'name': 'Samoan'},
    {'locale': Locale('gd'), 'name': 'Scots Gaelic'},
    {'locale': Locale('sr'), 'name': 'Serbian'},
    {'locale': Locale('st'), 'name': 'Sesotho'},
    {'locale': Locale('sn'), 'name': 'Shona'},
    {'locale': Locale('sd'), 'name': 'Sindhi'},
    {'locale': Locale('si'), 'name': 'Sinhala'},
    {'locale': Locale('sk'), 'name': 'Slovak'},
    {'locale': Locale('sl'), 'name': 'Slovenian'},
    {'locale': Locale('so'), 'name': 'Somali'},
    {'locale': Locale('es'), 'name': 'Spanish'},
    {'locale': Locale('su'), 'name': 'Sundanese'},
    {'locale': Locale('sw'), 'name': 'Swahili'},
    {'locale': Locale('sv'), 'name': 'Swedish'},
    {'locale': Locale('tg'), 'name': 'Tajik'},
    {'locale': Locale('ta'), 'name': 'Tamil'},
    {'locale': Locale('te'), 'name': 'Telugu'},
    {'locale': Locale('th'), 'name': 'Thai'},
    {'locale': Locale('tr'), 'name': 'Turkish'},
    {'locale': Locale('uk'), 'name': 'Ukrainian'},
    {'locale': Locale('ur'), 'name': 'Urdu'},
    {'locale': Locale('uz'), 'name': 'Uzbek'},
    {'locale': Locale('ug'), 'name': 'Uyghur'},
    {'locale': Locale('vi'), 'name': 'Vietnamese'},
    {'locale': Locale('cy'), 'name': 'Welsh'},
    {'locale': Locale('xh'), 'name': 'Xhosa'},
    {'locale': Locale('yi'), 'name': 'Yiddish'},
    {'locale': Locale('yo'), 'name': 'Yoruba'},
    {'locale': Locale('zu'), 'name': 'Zulu'},
  ];

  // Trier par nom de langue
  locales.sort((a, b) => a['name'].compareTo(b['name']));

  // Variable pour stocker la locale sélectionnée
  Locale? selectedLocale;

  // Filtrage des résultats
  String filter = '';

  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Sélectionner une langue'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher une langue',
                  ),
                  onChanged: (String value) {
                    setState(() {
                      filter = value.toLowerCase();
                    });
                  },
                ),
                SizedBox(height: 10),
                // Dropdown filtered by search
                Expanded(
                  child: DropdownButton<Locale>(
                    isExpanded: true,
                    value: selectedLocale,
                    hint: Text('Choisissez une langue'),
                    onChanged: (Locale? newValue) {
                      setState(() {
                        selectedLocale = newValue;
                      });
                    },
                    items: locales
                        .where((localeMap) => localeMap['name']
                            .toLowerCase()
                            .contains(filter))
                        .map<DropdownMenuItem<Locale>>((localeMap) {
                      return DropdownMenuItem<Locale>(
                        value: localeMap['locale'],
                        child: Text(
                            '${localeMap['name']} (${localeMap['locale'].languageCode})'),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(true); // Retourne true si OK est cliqué
                  if (selectedLocale != null) {
                    context.setLocale(selectedLocale!);
                  }
                },
              ),
              TextButton(
                child: Text('Annuler'),
                onPressed: () {
                  Navigator.of(context).pop(false); // Retourne false si Annuler est cliqué
                },
              ),
            ],
          );
        },
      );
    },
  ).then((value) => value ?? false); // Par défaut, retourne false si aucune option n'est sélectionnée.
}

  // showDialog(
  //   context: context,
  //   builder: (BuildContext context) {
  //     return StatefulBuilder(
  //       builder: (BuildContext context, StateSetter setState) {
  //         return AlertDialog(
  //           title: Text('Sélectionner une langue'),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               // Search bar
  //               TextField(
  //                 decoration: InputDecoration(
  //                   hintText: 'Rechercher une langue',
  //                 ),
  //                 onChanged: (String value) {
  //                   setState(() {
  //                     filter = value.toLowerCase();
  //                   });
  //                 },
  //               ),
  //               SizedBox(height: 10),
  //               // Dropdown filtered by search
  //               Expanded(
  //                 child: DropdownButton<Locale>(
  //                   isExpanded: true,
  //                   value: selectedLocale,
  //                   hint: Text('Choisissez une langue'),
  //                   onChanged: (Locale? newValue) {
  //                     setState(() {
  //                       selectedLocale = newValue;
  //                     });
  //                   },
  //                   items: locales
  //                       .where((localeMap) => localeMap['name']
  //                           .toLowerCase()
  //                           .contains(filter))
  //                       .map<DropdownMenuItem<Locale>>((localeMap) {
  //                     return DropdownMenuItem<Locale>(
  //                       value: localeMap['locale'],
  //                       child: Text(
  //                           '${localeMap['name']} (${localeMap['locale'].languageCode})'),
  //                     );
  //                   }).toList(),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           actions: [
  //             TextButton(
  //               child: Text('OK'),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //                 // Applique la langue sélectionnée
  //                 if (selectedLocale != null) {
  //                   context.setLocale(selectedLocale!);
  //                 }
  //               },
  //             ),
  //             TextButton(
  //               child: Text('Annuler'),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   },
  // );
// }


Widget infoButton(){
  return FloatingActionButton(
            onPressed: () {
            },
            backgroundColor: const Color(0xFF95A472),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50), // Définit le bouton comme rond
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.white, // Couleur de l'icône en blanc
              size: 30, // Ajuste la taille de l'icône si nécessaire
            ),
          );
}

Widget infobulle(BuildContext context) {
  return IconButton(
    icon: Icon(
      Icons.help_outline, // Utilise l'icône de point d'interrogation
      color: const Color(0xFF95A472), // Couleur de l'icône
      // size: 30, // Ajuste la taille de l'icône si nécessaire
    ),
    onPressed: () async {
      // Crée une instance de CustomTranslate
      CustomTranslate translator = CustomTranslate();

      // Traduire le message
      String translatedMessage = await translator.translate(
        '- Type "##" in the search bar for a random search or \n - Type "#" to enable or disable the shake mode for random search \n - Type "#lang" to choose the language.',
        "en",
        context.locale.languageCode == "zh" ? "zh-cn" : context.locale.languageCode,
      );

      String translateTitle = await translator.translate(
        'Information',
        "en",
        context.locale.languageCode == "zh" ? "zh-cn" : context.locale.languageCode,
      );

      // Affiche une boîte de dialogue d'alerte
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(translateTitle), // Titre de la boîte de dialogue
            content: Text(
              translatedMessage,
              softWrap: true
            ), // Message traduit
            actions: <Widget>[
              TextButton(
                child: Text("OK".tr()),
                onPressed: () {
                  Navigator.of(context).pop(); // Ferme la boîte de dialogue
                },
              ),
            ],
          );
        },
      );
    },
  );
}


//factoriser les 2 filterBouttons en passant en parametre la lambda du onTap
// Widget boutonFiltreOrange(context, onTapp){ //quel est le type de context?? il faut le preciser


void openFilter(BuildContext context, Function(List<int>) onApply) {
  showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return FilterOptionsModal(
        initialSelectedTagIds: selectedTagIdsNotifier.value,
        onApply: onApply, // Passer un callback pour setState ici
        // parentState: FilterBarState(),
      );
    },
  );
}

Widget boutonFiltreOrangeSearchBar(context, onApply){ //quel est le type de context?? il faut le preciser
  final ValueNotifier<bool> isPressedNotifier = ValueNotifier(false);
  // bool isDisabled = false;  //à décaler dans la searchbar pour controler l'apparition de la filterbar ou non
  bool isDisabled = isFilterOpen.value;
  double screenWidth = MediaQuery.of(context).size.width;
  double iconSize = screenWidth * 0.06; // Taille relative de l'icône (4% de la largeur de l'écran)
  double circleSize = screenWidth * 0.084; // Taille relative du cercle (8% de la largeur de l'écran)
  return GestureDetector(
    onTapDown: isDisabled
          ? null
          : (details) {
              isPressedNotifier.value = true; // Indique que le bouton est pressé
            },
      onTapUp: isDisabled
          ? null
          : 
          (details) { //à conditionner par rapport à comptes suivis . si il n'y a pas de compte suivi on garde comme tel et si il y a des comptes suivis, on passe is disabled à true
              isPressedNotifier.value = false; // Indique que le bouton n'est plus pressé
              print("Bouton filtre orange cliqué");
              print("avantswitch : ");
              print(isFilterOpen.value);
              //test : 
              if(!hasSubscription.value){
                print("openFilters");
                openFilter(context, onApply);
              }else{
                print("openFiltersAndWorkspaces");
                isFilterOpen.value = !isFilterOpen.value;
                updateVisibility();
              }
            },
       onTapCancel: () {
          if (!isDisabled) {
            isPressedNotifier.value = false; // Réinitialise si l'appui est annulé
          }
        },
    child: ValueListenableBuilder<bool>(
        valueListenable: isPressedNotifier,
        builder: (context, isPressed, child) {
          return Visibility(
          visible: !isDisabled, // Rend le bouton invisible si isDisabled est true
          child:
              Container(
                alignment: Alignment.center, // Centre le contenu du leading
                child: Container(
                  width: isPressed ? circleSize * 0.95 : circleSize, // Réduit légèrement le cercle lorsqu'il est pressé
                height: isPressed ? circleSize * 0.95 : circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.orangeButton,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: isPressed ? 0 : 1,
                      blurRadius: isPressed ? 2 : 4,
                      offset: isPressed ? Offset(0, 1) : Offset(0, 2),
                    ),
                  ],
                ),
                child: Center( // Centre l'icône dans le cercle
                  child: Icon(
                    Icons.filter_list,
                    color: Colors.white,
                    size: iconSize, // Taille ajustée de l'icône pour s'adapter au cercle
                  ),
                ),
                ),
              ),
            );
        }
    ),
  );
}

Widget boutonFiltreOrangeFilterhBar(context){ //quel est le type de context?? il faut le preciser
  final ValueNotifier<bool> isPressedNotifier = ValueNotifier(false);
  bool isDisabled = false; //à décaler dans la searchbar pour controler l'apparition de la filterbar ou non
  double screenWidth = MediaQuery.of(context).size.width;
  double iconSize = screenWidth * 0.06; // Taille relative de l'icône (4% de la largeur de l'écran)
  double circleSize = screenWidth * 0.084; // Taille relative du cercle (8% de la largeur de l'écran)
  return GestureDetector(
    onTapDown: isDisabled
          ? null
          : (details) {
              isPressedNotifier.value = true; // Indique que le bouton est pressé
            },
      onTapUp: isDisabled
          ? null
          : 
          (details) { //à conditionner par rapport à comptes suivis . si il n'y a pas de compte suivi on garde comme tel et si il y a des comptes suivis, on passe is disabled à true
              isPressedNotifier.value = false; // Indique que le bouton n'est plus pressé
              print("Bouton filtre orange cliqué");
              print("avantswitch : ");
              print(isFilterOpen.value);
              //test : 
              isFilterOpen.value = !isFilterOpen.value;
              updateVisibility();
              if(!hasSubscription.value){
                print("openFilters");
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return FilterOptionsModal(
                      initialSelectedTagIds:
                          selectedTagIdsNotifier.value,
                      onApply: (selectedIds) {
                        FilterBarState().setState(() {
                          selectedTagIdsNotifier.value = selectedIds;
                        });
                      },
                      // parentState: FilterBarState(),
                    );
                  },
                );
              }else{
                print("openFiltersAndWorkspaces");
                // isDisabled = true;
              }
            },
       onTapCancel: () {
          if (!isDisabled) {
            isPressedNotifier.value = false; // Réinitialise si l'appui est annulé
          }
        },
    child: ValueListenableBuilder<bool>(
        valueListenable: isPressedNotifier,
        builder: (context, isPressed, child) {
          return Visibility(
          visible: !isDisabled, // Rend le bouton invisible si isDisabled est true
          child:
          Container(
  alignment: Alignment.center, // Centre le contenu du leading
  child: Container(
    width: isPressed ? circleSize * 0.95 : circleSize, // Réduit légèrement le cercle lorsqu'il est pressé
    height: isPressed ? circleSize * 0.95 : circleSize,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.orangeButton,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          spreadRadius: isPressed ? 0 : 1,
          blurRadius: isPressed ? 2 : 4,
          offset: isPressed ? Offset(0, 1) : Offset(0, 2),
        ),
      ],
    ),
    child: Center( // Centre l'icône dans le cercle
      child: Icon(
        Icons.arrow_back, // Remplace par l'icône de flèche
        color: Colors.white,
        size: iconSize, // Taille ajustée de l'icône pour s'adapter au cercle
      ),
    ),
  ),
),

            );
        }
    ),
  );
}