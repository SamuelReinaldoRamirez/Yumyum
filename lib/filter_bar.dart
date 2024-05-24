import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yummap/theme.dart';
import 'package:yummap/workspace_options_modal.dart';
import 'filter_options_modal.dart';

class FilterBar extends StatefulWidget implements PreferredSizeWidget {
  final ValueNotifier<List<int>> selectedTagIdsNotifier;
  final ValueNotifier<List<int>> selectedWorkspacesNotifier;


  FilterBar({
    Key? key,
    required this.selectedTagIdsNotifier, required this.selectedWorkspacesNotifier,
  }) : super(key: key);

  @override
  _FilterBarState createState() => _FilterBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _FilterBarState extends State<FilterBar> {
  List<int> selectedTagIds = [];

  @override
  void initState() {
    super.initState();
    _lookPref();
    widget.selectedTagIdsNotifier.addListener(_updateSelectedThings);
    widget.selectedWorkspacesNotifier.addListener(_updateSelectedThings);
  }

  @override
  void dispose() {
    widget.selectedTagIdsNotifier.removeListener(_updateSelectedThings);
    widget.selectedWorkspacesNotifier.removeListener(_updateSelectedThings);
    super.dispose();
  }

  void _updateSelectedThings() {
    setState(() {});
  }

  List<String> aliasList = [];
  // Fonction asynchrone pour récupérer les workspaces sauvegardés
  Future<void> _lookPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      aliasList = prefs.getStringList('workspaceAliases') ?? [];
    });
  }

 @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false, // Ne pas respecter la marge en haut
      child: Container(
        color: Colors.white, // Couleur de fond jaune
        child: Row(
          children: [
            const SizedBox(width: 10),
            IconButton(
              onPressed: () 

              {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return FilterOptionsModal( initialSelectedTagIds: selectedTagIds,
                      onApply: (selectedIds) {
                        setState(() {
                          selectedTagIds = selectedIds;
                        });
                      },);
                    },
                  );
                },

              //   {
              //   showModalBottomSheet<void>(
              //     context: context,
              //     builder: (BuildContext context) {
              //       return FilterOptionsModal( 
              //         initialSelectedTagIds: widget.selectedTagIdsNotifier.value,
              //         // initialSelectedTagIds: selectedTagIds,
              //         onApply: (selectedIds) {
              //           setState(() {
              //             widget.selectedTagIdsNotifier.value = selectedIds;
              //             // selectedTagIds = selectedIds;
              //           });
              //         },);
              //     },
              //   );
              // },

              icon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.orangeButton,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.filter_list,
                  color: Colors.white,
                  size: 25
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () 
                
                // {
                //   showModalBottomSheet<void>(
                //     context: context,
                //     builder: (BuildContext context) {
                //       return FilterOptionsModal( initialSelectedTagIds: selectedTagIds,
                //       onApply: (selectedIds) {
                //         setState(() {
                //           selectedTagIds = selectedIds;
                //         });
                //       },);
                //     },
                //   );
                // },

                {
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return FilterOptionsModal( 
                      initialSelectedTagIds: widget.selectedTagIdsNotifier.value,
                      // initialSelectedTagIds: selectedTagIds,
                      onApply: (selectedIds) {
                        setState(() {
                          widget.selectedTagIdsNotifier.value = selectedIds;
                          // selectedTagIds = selectedIds;
                        });
                      },);
                  },
                );
              },

                child: Material(
                  elevation: 2, // élévation pour donner l'effet de surélévation
                  color: Colors.white,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Filtres',
                      style: TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (aliasList.isNotEmpty)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return WorkspaceOptionsModal(
                          initialSelectedWorkspaces: widget.selectedWorkspacesNotifier.value,
                          // initialSelectedTagIds: selectedTagIds,
                          onApply: (selectedIds) {
                            setState(() {
                              widget.selectedWorkspacesNotifier.value = selectedIds;
                              // selectedTagIds = selectedIds;
                            });
                          }
                        );
                      },
                    );
                  },
                  child: Material(
                    elevation: 2, // élévation pour donner l'effet de surélévation
                    color: Colors.white,
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Comptes Suivis',
                        style: TextStyle(
                          color: AppColors.darkGrey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Ajoutez d'autres widgets de votre barre d'outils ici si nécessaire
          ],
        ),
      ),
    );
  }

}
