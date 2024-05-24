import 'package:flutter/material.dart';
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
            ...workspaces.map((workspace) => _buildWorkspaceItem(context, workspace)),
            if (restaurants != null && restaurants!.isNotEmpty) // Afficher le titre uniquement si la liste de restaurants n'est pas vide
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

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(8.0),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 4,
//             child: Text(
//               '0' * numberOfZeroes,
//               style: TextStyle(fontSize: 16.0), // Taille de police par défaut
//               maxLines: 2, // Limite à 2 lignes
//               overflow: TextOverflow.ellipsis, // Tronquer le texte si nécessaire
//             ),
//           ),
//           Expanded(
//             child: Container(
//               child: Text(
//                 longText,
//                 style: TextStyle(fontSize: 16.0), // Taille de police par défaut
//                 maxLines: 2, // Limite à 2 lignes
//                 overflow: TextOverflow.ellipsis, // Tronquer le texte si nécessaire
//               ),
//             ),
//           ),
//           Expanded(
//             child: Container(
//               child: Text(
//                 longText,
//                 style: TextStyle(fontSize: 16.0), // Taille de police par défaut
//                 maxLines: 2, // Limite à 2 lignes
//                 overflow: TextOverflow.ellipsis, // Tronquer le texte si nécessaire
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }


  Widget _buildWorkspaceItem(BuildContext context, Workspace workspace) {
    return InkWell(
      onTap: () {
        Navigator.pop(context, workspace); // Retourne le workspace sélectionné à la page précédente
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ajout du mainAxisAlignment
          children: [
            Row(
              children: [
                Icon(Icons.business, color: AppColors.lightGreen), // Icône en vert clair
                SizedBox(width: 10.0),
                Text(
                  workspace.name,
                  style: AppTextStyles.paragraphWhiteStyle, // Utilise le style de texte pour les paragraphes
                ),
              ],
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    // Action pour le bouton "Voir"
                  },
                  child: Text(
                    'Voir',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                    elevation: WidgetStateProperty.all(15.0), // Ajout d'élévation
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.white.withOpacity(0.5)), // Bordure plus claire
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                TextButton(
                  onPressed: () {
                    // Action pour le bouton "Suivre"
                  },
                  child: Text(
                    'Suivre',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                    elevation: WidgetStateProperty.all(15.0), // Ajout d'élévation
                    shape: WidgetStateProperty.all(
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

