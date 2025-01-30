import 'package:flutter/material.dart';
import 'package:yummap/constant/theme.dart';
import 'package:yummap/page/home_page.dart';
import 'package:yummap/widgets/neu_widgets.dart';
import 'package:go_router/go_router.dart'; // Importation de GoRouter
import 'package:yummap/service/call_endpoint_service.dart'; // Importer la fonction de recherche
import 'package:yummap/model/workspace.dart'; // Importer le modèle Workspace
import 'package:yummap/service/local_data_service.dart'; // Importer le service de données locales

class DeepProfilePage extends StatelessWidget {
  final String id;
  final CallEndpointService callservice = CallEndpointService();
  final LocalDataService localDataService =
      LocalDataService(); // Service pour gérer les données locales

  DeepProfilePage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: FutureBuilder<List<Workspace>?>(
        future: callservice.findWorkspacesByAlias(
            [id]), // Utiliser l'ID pour rechercher le workspace
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun workspace trouvé.'));
          }

          final workspace =
              snapshot.data!.first; // Obtenir le premier workspace

          return Container(
            color: AppColors.backgroundColor,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset(
                      'assets/logo/logo_new.png',
                      width: 100,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(40),
                      margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowColor.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const SizedBox(height: 32),
                          Text(
                            'Informations sur le Workspace',
                            style: AppTextStyles.titleBlackStyle,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nom: ${workspace.name}',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.paragraphDarkStyle,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Alias: ${workspace.alias}',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.paragraphDarkStyle,
                          ),
                          const SizedBox(height: 52),
                          CustomNeuButton(
                            text: 'Follow',
                            icon: Icons.person_add,
                            buttonColor: AppColors.appSecondary,
                            textColor: Colors.white,
                            onPressed: () async {
                              await _followWorkspace(
                                  workspace); // Appeler la méthode pour suivre
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomePage(
                                    followedWorkspaceId: workspace
                                        .id, // Passer l'ID du workspace suivi
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              // Retour à la page d'accueil
                              context.go('/home');
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppColors.secondaryColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _followWorkspace(Workspace workspace) async {
    print('Tentative de suivre le workspace: ${workspace.name}'); // Debug
    await localDataService.followWorkspace(workspace);
    print('Workspace suivi avec succès'); // Debug
  }
}
