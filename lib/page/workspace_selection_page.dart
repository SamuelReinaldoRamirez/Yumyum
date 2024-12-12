// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yummap/service/call_endpoint_service.dart';
import 'package:yummap/constant/global.dart';
import 'package:yummap/helper/map_helper.dart';
import 'package:yummap/model/workspace.dart'; // Importez le modèle de données Workspace si nécessaire
import 'package:yummap/model/restaurant.dart'; // Importez le modèle de données Restaurant si nécessaire
import '../constant/theme.dart'; // Importez les thèmes
import 'package:yummap/widget/filter_bar.dart';
import 'package:yummap/service/local_data_service.dart';

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
          color: Colors.black87, // Fond gris foncé
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
  bool _isLoading = false;
  final LocalDataService _localDataService = LocalDataService();
  final CallEndpointService _callEndpointService = CallEndpointService();

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    _aliasListFuture = _loadAliasList();
    await _localDataService.loadFollowedWorkspaces();
    // Vérifier si le workspace est déjà suivi
    if (_localDataService.followedWorkspacesNotifier.value
        .any((w) => w.id == widget.workspace.id)) {
      setState(() {
        widget.workspace.isFollowed = true;
      });
    }
  }

  Future<List<String>> _loadAliasList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('workspaceAliases') ?? [];
  }

  Future<void> _handleFollowToggle(Workspace workspace) async {
    try {
      final isCurrentlyFollowed = _localDataService.followedWorkspacesNotifier.value
          .any((w) => w.id == workspace.id);

      if (isCurrentlyFollowed) {
        _localDataService.removeFollowedWorkspace(workspace.id);
      } else {
        _localDataService.addFollowedWorkspace(workspace);
      }

      setState(() {
        workspace.isFollowed = !isCurrentlyFollowed;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la modification du suivi'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                      width: 100,
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
                        List<Restaurant> restaurants =
                            await _callEndpointService.getRestaurantsByTagsAndWorkspaces(
                                [], [widget.workspace.id]);
                        if (restaurants.isNotEmpty) {
                          // Afficher les restaurants sur la carte
                          MarkerManager.createFull(
                              MarkerManager.context, restaurants);
                          //SI l'hotel recommande TOUS les restos de notre bdd, la croix sera entourée mais le veut-on?!
                          //quand on clique sur voir les recommandations de l'hotel, ne faudrait-il pas que ca le coche dans les workspaces filtres si on est déjà abonné?
                          filterIsOn.value = true;
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
                            MaterialStateProperty.all(15.0), // Ajout d'élévation
                        shape: MaterialStateProperty.all(
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
                    IconButton(
                      icon: Icon(
                        widget.workspace.isFollowed ? Icons.check_circle : Icons.add_circle_outline,
                        color: widget.workspace.isFollowed ? AppColors.orangeButton : Colors.white,
                        size: 28,
                      ),
                      onPressed: () => _handleFollowToggle(widget.workspace),
                      tooltip: widget.workspace.isFollowed ? 'Ne plus suivre' : 'Suivre',
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
