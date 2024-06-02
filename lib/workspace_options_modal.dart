// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/map_helper.dart';
import 'package:yummap/mixpanel_service.dart';
import 'package:yummap/theme.dart';
import 'package:yummap/workspace.dart';

import 'restaurant.dart';

class WorkspaceOptionsModal extends StatefulWidget {
  final List<int> initialSelectedWorkspaces;
  final ValueChanged<List<int>> onApply;

  const WorkspaceOptionsModal(
      {Key? key,
      required this.onApply,
      required this.initialSelectedWorkspaces})
      : super(key: key);

  @override
  _WorkspaceOptionsModalState createState() => _WorkspaceOptionsModalState();
}

class _WorkspaceOptionsModalState extends State<WorkspaceOptionsModal> {
  List<int> selectedTagIds = [];
  List<List<String>> selectedPlaceIDsList = [];
  List<Workspace> workspaceList = [];

  @override
  void initState() {
    super.initState();
    selectedTagIds = List.from(widget.initialSelectedWorkspaces);
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _fetchWorkspaceList();
    await _populateSelectedPlaceIDsList();
  }

  Future<void> _populateSelectedPlaceIDsList() async {
    List<Workspace> workspaceSelected =
        workspaceList.where((obj) => selectedTagIds.contains(obj.id)).toList();
    List<List<String>> returnedPaceIdsList =
        workspaceSelected.map<List<String>>((obj) => obj.placeIds).toList();
    setState(() {
      selectedPlaceIDsList = returnedPaceIdsList;
    });
  }

  Future<void> _fetchWorkspaceList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> aliass = prefs.getStringList('workspaceAliases') ?? [];
    List<Workspace> returnedWorkspaces =
        await CallEndpointService.searchWorkspacesByAliass(aliass);
    setState(() {
      workspaceList = returnedWorkspaces;
    });
  }

  void _handleWorkspaceSelection(List<List<String>> placeIdsList) async {
    // Récupérer les restaurants à partir des placeId
    List<String> placeIds = [];
    for (List<String> placeIDS in placeIdsList) {
      for (String placeId in placeIDS) {
        if (!placeIds.contains(placeId)) {
          placeIds.add(placeId);
        }
      }
    }
    List<Restaurant> restaurants =
        await CallEndpointService.searchRestaurantsByPlaceIDs(placeIds);
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
  }

  Widget _buildApplyButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: ElevatedButton(
        onPressed: () async {
          widget.onApply(selectedTagIds);
          MixpanelService.instance.track('FilterWorkspaceSearch', properties: {
            'filter_ids': selectedTagIds,
          });
          _handleWorkspaceSelection(selectedPlaceIDsList);
          Navigator.of(context).pop();
        },
        style: AppButtonStyles.elevatedButtonStyle,
        child: const Text('Appliquer'),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: Text(
        'Comptes Suivis',
        style: AppTextStyles.titleDarkStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  itemCount: workspaceList.length,
                  itemBuilder: (context, index) {
                    final workspace = workspaceList[index];
                    return CheckboxListTile(
                      title: Text(
                        workspace.name,
                        style: AppTextStyles.paragraphDarkStyle,
                      ),
                      value: selectedTagIds.contains(workspace.id),
                      checkColor: Colors.white,
                      activeColor: AppColors.greenishGrey,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value != null && value) {
                            selectedTagIds.add(workspace.id);
                            print("added ");
                            print(workspace.restaurants_placeId);
                            print("to");
                            print(selectedPlaceIDsList);
                            selectedPlaceIDsList
                                .add(workspace.restaurants_placeId);
                            print(selectedPlaceIDsList);
                          } else {
                            selectedTagIds.remove(workspace.id);
                            print("removed ");
                            print(workspace.restaurants_placeId);
                            print("to");
                            print(selectedPlaceIDsList);
                            selectedPlaceIDsList
                                .remove(workspace.restaurants_placeId);
                            print(selectedPlaceIDsList);
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
    );
  }
}
