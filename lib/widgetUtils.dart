import 'package:flutter/material.dart';
import 'package:yummap/filter_bar.dart';
import 'package:yummap/filter_options_modal.dart';
import 'package:yummap/global.dart';
import 'package:yummap/theme.dart';

//factoriser les 2 filterBouttons en passant en parametre la lambda du onTap
// Widget boutonFiltreOrange(context, onTapp){ //quel est le type de context?? il faut le preciser
//   final ValueNotifier<bool> isPressedNotifier = ValueNotifier(false);
//   bool isDisabled = false; //à décaler dans la searchbar pour controler l'apparition de la filterbar ou non
//   double screenWidth = MediaQuery.of(context).size.width;
//   double iconSize = screenWidth * 0.06; // Taille relative de l'icône (4% de la largeur de l'écran)
//   double circleSize = screenWidth * 0.084; // Taille relative du cercle (8% de la largeur de l'écran)
//   return GestureDetector(
//     onTapDown: isDisabled
//           ? null
//           : (details) {
//               isPressedNotifier.value = true; // Indique que le bouton est pressé
//             },
//       onTapUp: isDisabled
//           ? null
//           : 
//           // (details) { //à conditionner par rapport à comptes suivis . si il n'y a pas de compte suivi on garde comme tel et si il y a des comptes suivis, on passe is disabled à true
//           //     isPressedNotifier.value = false; // Indique que le bouton n'est plus pressé
//           //     print("Bouton filtre orange cliqué");
//           //     print("avantswitch : ");
//           //     print(isFilterOpen.value);
//           //     //test : 
//           //     isFilterOpen.value = !isFilterOpen.value;
//           //     updateVisibility();
//           //     if(!hasSubscription.value){
//           //       print("openFilters");
//           //     }else{
//           //       print("openFiltersAndWorkspaces");
//           //       // isDisabled = true;
//           //     }
//           //   },
//           ontapp
//        onTapCancel: () {
//           if (!isDisabled) {
//             isPressedNotifier.value = false; // Réinitialise si l'appui est annulé
//           }
//         },
//     child: ValueListenableBuilder<bool>(
//         valueListenable: isPressedNotifier,
//         builder: (context, isPressed, child) {
//           return Visibility(
//           visible: !isDisabled, // Rend le bouton invisible si isDisabled est true
//           child:
//               Container(
//                 alignment: Alignment.center, // Centre le contenu du leading
//                 child: Container(
//                   width: isPressed ? circleSize * 0.95 : circleSize, // Réduit légèrement le cercle lorsqu'il est pressé
//                 height: isPressed ? circleSize * 0.95 : circleSize,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: AppColors.orangeButton,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       spreadRadius: isPressed ? 0 : 1,
//                       blurRadius: isPressed ? 2 : 4,
//                       offset: isPressed ? Offset(0, 1) : Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Center( // Centre l'icône dans le cercle
//                   child: Icon(
//                     Icons.filter_list,
//                     color: Colors.white,
//                     size: iconSize, // Taille ajustée de l'icône pour s'adapter au cercle
//                   ),
//                 ),
//                 ),
//               ),
//             );
//         }
//     ),
//   );
// }


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