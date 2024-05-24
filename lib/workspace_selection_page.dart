// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:yummap/workspace.dart'; // Importez le modèle de données Workspace si nécessaire
// import 'package:yummap/restaurant.dart'; // Importez le modèle de données Restaurant si nécessaire
// import 'theme.dart'; // Importez les thèmes

// class WorkspaceSelectionPage extends StatelessWidget {
//   final List<Workspace> workspaces;
//   final List<Restaurant>? restaurants; // Liste de restaurants facultative
  

//   const WorkspaceSelectionPage({
//     Key? key,
//     required this.workspaces,
//     this.restaurants, // Initialisation facultative de la liste de restaurants
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false, // Enlève la flèche de retour par défaut
//         backgroundColor: AppColors.darkGrey, // Fond de l'app bar en gris foncé
//         title: Row(
//           children: [
//             Container(
//               width: 40.0,
//               height: 40.0,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: AppColors.lightGreen, // Fond vert clair pour le cercle
//               ),
//               child: IconButton(
//                 icon: Icon(Icons.map, color: AppColors.darkGrey), // Icône "plan de Paris" en vert clair
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             ),
//             SizedBox(width: 10.0),
//             Expanded(
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 5.0),
//                 decoration: BoxDecoration(
//                   color: AppColors.darkGrey, // Fond gris foncé pour le titre
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 child: Center(
//                   child: Text(
//                     'Résultats',
//                     style: AppTextStyles.titleDarkStyle.copyWith(
//                       color: AppColors.lightGreen,
//                     ), // Utilise le style de titre avec la couleur définie
//                     textAlign: TextAlign.center, // Centre le texte
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Container(
//         color: AppColors.lightGreen, // Fond vert clair
//         child: ListView(
//           children: [
            
//           _buildSectionTitle(context, 'Recommandeurs'),
//           FutureBuilder<List<Widget>>(
//             future: Future.wait(workspaces.map((workspace) => _buildWorkspaceItem(context, workspace))),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return CircularProgressIndicator(); // Ou un indicateur de chargement similaire
//               }
//               if (snapshot.hasError) {
//                 return Text('Erreur: ${snapshot.error}');
//               }
//               return Column(
//                 children: snapshot.data ?? [],
//               );
//             },
//           ),
//             // _buildSectionTitle(context, 'Recommandeurs'),
//             // ...workspaces.map((workspace) => _buildWorkspaceItem(context, workspace)),
//             if (restaurants != null && restaurants!.isNotEmpty) // Afficher le titre uniquement si la liste de restaurants n'est pas vide
//               _buildSectionTitle(context, 'Restaurants'),
//             ...(restaurants?.map((restaurant) => _buildRestaurantItem(context, restaurant)) ?? []),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(BuildContext context, String title) {
//     return Padding(
//       padding: const EdgeInsets.all(10.0),
//       child: Text(
//         title,
//         style: AppTextStyles.titleDarkStyle.copyWith(color: AppColors.darkGrey),
//       ),
//     );
//   }
// //POUR QUE LE TEXTE NE DEPASSE PAS
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: EdgeInsets.all(8.0),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             flex: 4,
// //             child: Text(
// //               '0' * numberOfZeroes,
// //               style: TextStyle(fontSize: 16.0), // Taille de police par défaut
// //               maxLines: 2, // Limite à 2 lignes
// //               overflow: TextOverflow.ellipsis, // Tronquer le texte si nécessaire
// //             ),
// //           ),
// //           Expanded(
// //             child: Container(
// //               child: Text(
// //                 longText,
// //                 style: TextStyle(fontSize: 16.0), // Taille de police par défaut
// //                 maxLines: 2, // Limite à 2 lignes
// //                 overflow: TextOverflow.ellipsis, // Tronquer le texte si nécessaire
// //               ),
// //             ),
// //           ),
// //           Expanded(
// //             child: Container(
// //               child: Text(
// //                 longText,
// //                 style: TextStyle(fontSize: 16.0), // Taille de police par défaut
// //                 maxLines: 2, // Limite à 2 lignes
// //                 overflow: TextOverflow.ellipsis, // Tronquer le texte si nécessaire
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

//   Future<List<String>> getPreferences() async{
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         return prefs.getStringList('workspaceAliases') ?? [];
//   }


//   Future<Widget> _buildWorkspaceItem(BuildContext context, Workspace workspace) async {
//     List<String> aliasList = await getPreferences();
//     return InkWell(
//       onTap: () {
//         Navigator.pop(context, workspace); // Retourne le workspace sélectionné à la page précédente
//       },
//       child: Container(
//         margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
//         padding: EdgeInsets.all(15.0),
//         decoration: BoxDecoration(
//           color: AppColors.darkGrey, // Fond gris foncé
//           borderRadius: BorderRadius.circular(10.0),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.5),
//               spreadRadius: 2,
//               blurRadius: 5,
//               offset: Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ajout du mainAxisAlignment
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.business, color: AppColors.lightGreen), // Icône en vert clair
//                 SizedBox(width: 10.0),
//                 Text(
//                   workspace.name,
//                   style: AppTextStyles.paragraphWhiteStyle, // Utilise le style de texte pour les paragraphes
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 TextButton(
//                   onPressed: () {
//                     // Action pour le bouton "Voir"
//                   },
//                   child: Text(
//                     'Voir',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   style: ButtonStyle(
//                     elevation: WidgetStateProperty.all(15.0), // Ajout d'élévation
//                     shape: WidgetStateProperty.all(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                         side: BorderSide(color: Colors.white.withOpacity(0.5)), // Bordure plus claire
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 10.0),
//                 if(!aliasList.contains(workspace.alias))
//                 TextButton(
//                   onPressed: () async {
//                     // Action pour le bouton "Suivre"
//                     SharedPreferences prefs = await SharedPreferences.getInstance();
//                     List<String> aliasListMemory = prefs.getStringList('workspaceAliases') ?? [];
//                     aliasListMemory.add(workspace.alias);
//                     aliasList = aliasListMemory;
//                     // Sauvegarder la liste mise à jour dans les préférences partagées
//                     await prefs.setStringList('workspaceAliases', aliasListMemory);
//                   },
//                   child: Text(
//                     'Suivre',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   style: ButtonStyle(
//                     elevation: WidgetStateProperty.all(15.0), // Ajout d'élévation
//                     shape: WidgetStateProperty.all(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                         side: BorderSide(color: Colors.white.withOpacity(0.5)), // Bordure plus claire
//                       ),
//                     ),
//                   ),
//                 ),
//                 if(aliasList.contains(workspace.alias))
//                 TextButton(
//                   onPressed: () async {

//                     SharedPreferences prefs = await SharedPreferences.getInstance();
//                     List<String> aliasListMemory = prefs.getStringList('workspaceAliases') ?? [];
//                     // Supprimer l'ancien alias s'il existe déjà
//                     aliasListMemory.remove(workspace.alias);
//                     aliasList = aliasListMemory;
//                     // Sauvegarder la liste mise à jour dans les préférences partagées
//                     await prefs.setStringList('workspaceAliases', aliasListMemory);
//                     //IL FAUT APPELER UN SETSTATE SUR la variable du if pour afficher les boutons suivre et desbonner


//                     // Action pour le bouton "désabonner"

//                   //   void _handleWorkspaceSelection(Workspace workspace) async {
//                   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//                   //   List<String> aliasList = prefs.getStringList('workspaceAliases') ?? [];

//                   //   // Afficher la liste actuelle des alias avant la mise à jour
//                   //   _showAliasAlert(context, aliasList, 'Before setting');

//                   //   // Supprimer l'ancien alias s'il existe déjà
//                   //   aliasList.remove(workspace.alias);

//                   //   // Ajouter le nouvel alias à la liste
//                   //   aliasList.add(workspace.alias);

//                   //   // Sauvegarder la liste mise à jour dans les préférences partagées
//                   //   await prefs.setStringList('workspaceAliases', aliasList);

//                   //   // Afficher la liste mise à jour des alias
//                   //   _showAliasAlert(context, aliasList, 'After setting');

//                   //   // Récupérer les restaurants à partir des placeId
//                   //   List<String> placeIds = workspace.restaurants_placeId;
//                   //   List<Restaurant> restaurants = await CallEndpointService.searchRestaurantsByPlaceIDs(placeIds);

//                   //   if (restaurants.isNotEmpty) {
//                   //     // Afficher les restaurants sur la carte
//                   //     MarkerManager.createFull(MarkerManager.context, restaurants);
//                   //   } else {
//                   //     ScaffoldMessenger.of(MarkerManager.context).showSnackBar(
//                   //       const SnackBar(
//                   //         content: Text('Aucun restaurant trouvé pour ce workspace'),
//                   //       ),
//                   //     );
//                   //   }
//                   // }


//                   },
//                   child: Text(
//                     'Désabonner',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   style: ButtonStyle(
//                     elevation: WidgetStateProperty.all(15.0), // Ajout d'élévation
//                     shape: WidgetStateProperty.all(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                         side: BorderSide(color: Colors.white.withOpacity(0.5)), // Bordure plus claire
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRestaurantItem(BuildContext context, Restaurant restaurant) {
//     return InkWell(
//       onTap: () {
//         Navigator.pop(context, restaurant); // Retourne le restaurant sélectionné à la page précédente
//       },
//       child: Container(
//         margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
//         padding: EdgeInsets.all(15.0),
//         decoration: BoxDecoration(
//           color: AppColors.darkGrey, // Fond gris foncé
//           borderRadius: BorderRadius.circular(10.0),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.5),
//               spreadRadius: 2,
//               blurRadius: 5,
//               offset: Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.restaurant, color: AppColors.lightGreen), // Icône en vert clair
//             SizedBox(width: 10.0),
//             Expanded(
//               child: Text(
//                 restaurant.name,
//                 style: AppTextStyles.paragraphWhiteStyle, // Utilise le style de texte pour les paragraphes
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/map_helper.dart';
import 'package:yummap/workspace.dart'; // Importez le modèle de données Workspace si nécessaire
import 'package:yummap/restaurant.dart'; // Importez le modèle de données Restaurant si nécessaire
import 'theme.dart'; // Importez les thèmes

class WorkspaceSelectionPage extends StatelessWidget {
  final List<Workspace> workspaces;
  final List<Restaurant>? restaurants; // Liste de restaurants facultative

  const WorkspaceSelectionPage({
    Key? key,
    required this.workspaces,
    this.restaurants, // Initialisation facultative de la liste de restaurants
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Enlève la flèche de retour par défaut
        backgroundColor: AppColors.darkGrey, // Fond de l'app bar en gris foncé
        title: Row(
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightGreen, // Fond vert clair pour le cercle
              ),
              child: IconButton(
                icon: Icon(Icons.map, color: AppColors.darkGrey), // Icône "plan de Paris" en vert clair
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                decoration: BoxDecoration(
                  color: AppColors.darkGrey, // Fond gris foncé pour le titre
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: Text(
                    'Résultats',
                    style: AppTextStyles.titleDarkStyle.copyWith(
                      color: AppColors.lightGreen,
                    ), // Utilise le style de titre avec la couleur définie
                    textAlign: TextAlign.center, // Centre le texte
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: AppColors.lightGreen, // Fond vert clair
        child: ListView(
          children: [
            _buildSectionTitle(context, 'Recommandeurs'),
            Column(
              children: workspaces.map((workspace) => WorkspaceItem(workspace: workspace)).toList(),
            ),
            if (restaurants != null && restaurants!.isNotEmpty)
              _buildSectionTitle(context, 'Restaurants'),
            ...(restaurants?.map((restaurant) => _buildRestaurantItem(context, restaurant)) ?? []),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        title,
        style: AppTextStyles.titleDarkStyle.copyWith(color: AppColors.darkGrey),
      ),
    );
  }

  Widget _buildRestaurantItem(BuildContext context, Restaurant restaurant) {
    return InkWell(
      onTap: () {
        Navigator.pop(context, restaurant); // Retourne le restaurant sélectionné à la page précédente
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.red, // Fond gris foncé
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.restaurant, color: AppColors.lightGreen), // Icône en vert clair
            SizedBox(width: 10.0),
            Expanded(
              child: Text(
                restaurant.name,
                style: AppTextStyles.paragraphWhiteStyle, // Utilise le style de texte pour les paragraphes
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkspaceItem extends StatefulWidget {
  final Workspace workspace;

  const WorkspaceItem({Key? key, required this.workspace}) : super(key: key);

  @override
  _WorkspaceItemState createState() => _WorkspaceItemState();
}

class _WorkspaceItemState extends State<WorkspaceItem> {
  late Future<List<String>> _aliasListFuture;

  @override
  void initState() {
    super.initState();
    _aliasListFuture = _getPreferences();
  }

  Future<List<String>> _getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('workspaceAliases') ?? [];
  }

  void _updatePreferences() {
    setState(() {
      _aliasListFuture = _getPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _aliasListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Ou un indicateur de chargement similaire
        }
        if (snapshot.hasError) {
          return Text('Erreur: ${snapshot.error}');
        }
        List<String> aliasList = snapshot.data ?? [];
        bool isFollowing = aliasList.contains(widget.workspace.alias);

        return InkWell(
          onTap: () {
            // Navigator.pop(context, widget.workspace); // Retourne le workspace sélectionné à la page précédente
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            padding: EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              color: AppColors.darkGrey, // Fond gris foncé
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.business, color: AppColors.lightGreen), // Icône en vert clair
                    SizedBox(width: 10.0),
                    Text(
                      widget.workspace.name,
                      style: AppTextStyles.paragraphWhiteStyle, // Utilise le style de texte pour les paragraphes
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        List<String> placeIds = widget.workspace.restaurants_placeId;
                        List<Restaurant> restaurants = await CallEndpointService.searchRestaurantsByPlaceIDs(placeIds);

                        if (restaurants.isNotEmpty) {
                          // Afficher les restaurants sur la carte
                          MarkerManager.createFull(MarkerManager.context, restaurants);
                        } else {
                          ScaffoldMessenger.of(MarkerManager.context).showSnackBar(
                            const SnackBar(
                              content: Text('Aucun restaurant trouvé pour ce workspace'),
                            ),
                          );
                        }
                        Navigator.pop(context, widget.workspace);
                        // Action pour le bouton "Voir"
                      },
                      child: Text(
                        'Voir',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(15.0), // Ajout d'élévation
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(color: Colors.white.withOpacity(0.5)), // Bordure plus claire
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.0),
                    if (!isFollowing)
                      TextButton(
                        onPressed: () async {
                          // Action pour le bouton "Suivre"
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          List<String> aliasListMemory = prefs.getStringList('workspaceAliases') ?? [];
                          aliasListMemory.add(widget.workspace.alias);
                          await prefs.setStringList('workspaceAliases', aliasListMemory);
                          _updatePreferences();
                        },
                        child: Text(
                          'Suivre',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(15.0), // Ajout d'élévation
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(color: Colors.white.withOpacity(0.5)), // Bordure plus claire
                            ),
                          ),
                        ),
                      ),
                    if (isFollowing)
                      TextButton(
                        onPressed: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          List<String> aliasListMemory = prefs.getStringList('workspaceAliases') ?? [];
                          // Supprimer l'ancien alias s'il existe déjà
                          aliasListMemory.remove(widget.workspace.alias);
                          await prefs.setStringList('workspaceAliases', aliasListMemory);
                          _updatePreferences();
                        },
                        child: Text(
                          'Désabonner',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(15.0), // Ajout d'élévation
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(color: Colors.white.withOpacity(0.5)), // Bordure plus claire
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
