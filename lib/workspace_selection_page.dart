// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/map_helper.dart';
import 'package:yummap/workspace.dart'; // Importez le modèle de données Workspace si nécessaire
import 'package:yummap/restaurant.dart'; // Importez le modèle de données Restaurant si nécessaire
import 'theme.dart'; // Importez les thèmes
import 'package:yummap/filter_bar.dart';

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
        automaticallyImplyLeading:
            false, // Enlève la flèche de retour par défaut
        backgroundColor: AppColors.darkGrey, // Fond de l'app bar en gris foncé
        title: Row(
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.orangeButton, // Fond vert clair pour le cercle
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back, // Icône de flèche de retour
                  color: Colors.white, // Couleur de l'icône
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                decoration: BoxDecoration(
                  color: AppColors.darkGrey, // Fond gris foncé pour le titre
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: Text(
                    'Résultats',
                    style: AppTextStyles.titleDarkStyle.copyWith(
                      color: Colors.white,
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
        color: Colors.white, // Fond vert clair
        child: ListView(
          children: [
            _buildSectionTitle(context, 'Profils publics'),
            Column(
              children: workspaces
                  .map((workspace) => WorkspaceItem(workspace: workspace))
                  .toList(),
            ),
            if (restaurants != null && restaurants!.isNotEmpty)
              _buildSectionTitle(context, 'Restaurants'),
            ...(restaurants?.map((restaurant) =>
                    _buildRestaurantItem(context, restaurant)) ??
                []),
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
        Navigator.pop(context,
            restaurant); // Retourne le restaurant sélectionné à la page précédente
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.red, // Fond gris foncé
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.restaurant,
                color: AppColors.lightGreen), // Icône en vert clair
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                restaurant.name,
                style: AppTextStyles
                    .paragraphWhiteStyle, // Utilise le style de texte pour les paragraphes
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
          return const CircularProgressIndicator(); // Ou un indicateur de chargement similaire
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
            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              color: AppColors.darkGrey, // Fond gris foncé
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.business,
                        color: Colors.white), // Icône en vert clair
                    const SizedBox(width: 10.0),
                    SizedBox(
                      width: 150,
                      child: Text(
                        widget.workspace.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2, // Limite à une seule ligne
                        style: AppTextStyles
                            .paragraphWhiteStyle, // Utilise le style de texte pour les paragraphes
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        List<String> placeIds =
                            widget.workspace.restaurants_placeId;
                        List<Restaurant> restaurants = await CallEndpointService
                            .searchRestaurantsByPlaceIDs(placeIds);

                        if (restaurants.isNotEmpty) {
                          // Afficher les restaurants sur la carte
                          MarkerManager.createFull(
                              MarkerManager.context, restaurants);
                        } else {
                          ScaffoldMessenger.of(MarkerManager.context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Aucun restaurant trouvé pour ce workspace'),
                            ),
                          );
                        }
                        Navigator.pop(context, widget.workspace);
                        // Action pour le bouton "Voir"
                      },
                      style: ButtonStyle(
                        elevation:
                            WidgetStateProperty.all(15.0), // Ajout d'élévation
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(
                                color: Colors.white
                                    .withOpacity(0.5)), // Bordure plus claire
                          ),
                        ),
                      ),
                      child: const Text(
                        'Voir',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    if (!isFollowing)
                      TextButton(
                        onPressed: () async {
                          // Action pour le bouton "Suivre"
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          List<String> aliasListMemory =
                              prefs.getStringList('workspaceAliases') ?? [];
                          aliasListMemory.add(widget.workspace.alias);
                          await prefs.setStringList(
                              'workspaceAliases', aliasListMemory);
                          _updatePreferences();
                          FilterBar.showAccounts();
                        },
                        style: ButtonStyle(
                          elevation: WidgetStateProperty.all(
                              15.0), // Ajout d'élévation
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: const BorderSide(
                                  color: AppColors
                                      .lightGreen), // Bordure plus claire
                            ),
                          ),
                        ),
                        child: const Text(
                          'Suivre',
                          style: TextStyle(color: AppColors.lightGreen),
                        ),
                      ),
                    if (isFollowing)
                      TextButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          List<String> aliasListMemory =
                              prefs.getStringList('workspaceAliases') ?? [];
                          // Supprimer l'ancien alias s'il existe déjà
                          aliasListMemory.remove(widget.workspace.alias);
                          await prefs.setStringList(
                              'workspaceAliases', aliasListMemory);
                          _updatePreferences();

                          // Vérifier s'il y a encore des comptes suivis
                          if (aliasListMemory.isEmpty) {
                            FilterBar.hideAccounts();
                          }
                        },
                        style: ButtonStyle(
                          elevation: WidgetStateProperty.all(
                              15.0), // Ajout d'élévation
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(
                                color: Colors.white
                                    .withOpacity(0.5), // Bordure plus claire
                              ),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Désabonner',
                          style: TextStyle(color: Colors.white),
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
