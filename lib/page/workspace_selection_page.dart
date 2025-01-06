import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yummap/service/call_endpoint_service.dart';
import 'package:yummap/constant/global.dart';
import 'package:yummap/helper/map_helper.dart';
import 'package:yummap/model/workspace.dart'; // Importez le modèle de données Workspace si nécessaire
import 'package:yummap/model/restaurant.dart'; // Importez le modèle de données Restaurant si nécessaire
import '../constant/theme.dart'; // Importez les thèmes
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
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 50.0, // Taille du container pour la flèche
              height: 50.0, // Taille du container pour la flèche
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.black,
                  width: 3.0,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Center(
                // Centrer l'icône à l'intérieur du container
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 30,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            const SizedBox(
                width: 16), // Espacement entre la flèche et "Résultats"
            Expanded(
              child: Text(
                'Résultats',
                style: AppTextStyles.titleDarkStyle.copyWith(
                  color: Colors.black,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center, // Centrer le texte "Résultats"
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: AppColors.backgroundColor,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle(context, 'Profils publics'),
            const SizedBox(height: 8),
            ...workspaces.map((workspace) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: WorkspaceItem(workspace: workspace),
                )),
            if (restaurants != null && restaurants!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSectionTitle(context, 'Restaurants'),
              const SizedBox(height: 8),
              ...restaurants!.map((restaurant) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildRestaurantItem(context, restaurant),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        border: Border.all(
          color: Colors.black,
          width: 3.0,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        title,
        style: AppTextStyles.titleDarkStyle.copyWith(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildRestaurantItem(BuildContext context, Restaurant restaurant) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black,
          width: 3.0,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: () => Navigator.pop(context, restaurant),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    border: Border.all(
                      color: Colors.black,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        style: AppTextStyles.titleDarkStyle.copyWith(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        restaurant.cuisine,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
      final isCurrentlyFollowed = _localDataService
          .followedWorkspacesNotifier.value
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
        aliasList.contains(widget.workspace.alias);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.black,
              width: 3.0,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(9),
              onTap: () {
                // Navigator.pop(context, widget.workspace); // Retourne le workspace sélectionné à la page précédente
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            border: Border.all(
                              color: Colors.black,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.business,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 150,
                          child: Text(
                            widget.workspace.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2, // Limite à une seule ligne
                            style: AppTextStyles.titleBlackStyle.copyWith(
                              fontSize: 18,
                              color: Colors.black,
                            ), // Utilise le style de texte pour les paragraphes
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 10.0),
                        IconButton(
                          icon: Icon(
                            widget.workspace.isFollowed
                                ? Icons.check_circle
                                : Icons.add_circle_outline,
                            color: widget.workspace.isFollowed
                                ? AppColors.secondaryColor
                                : Colors.black,
                            size: 28,
                          ),
                          onPressed: () =>
                              _handleFollowToggle(widget.workspace),
                          tooltip: widget.workspace.isFollowed
                              ? 'Ne plus suivre'
                              : 'Suivre',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
