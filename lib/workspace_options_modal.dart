// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yummap/call_endpoint_service.dart';
import 'package:yummap/filter_bar.dart';
import 'package:yummap/map_helper.dart';
import 'package:yummap/mixpanel_service.dart';
import 'package:yummap/theme.dart';
import 'package:yummap/workspace.dart';
import 'restaurant.dart';

class WorkspaceOptionsModal extends StatefulWidget {
  final List<int> initialSelectedWorkspaces;
  final ValueChanged<List<int>> onApply;
  // final FilterBarState parentState;

  const WorkspaceOptionsModal(
      {Key? key,
      required this.onApply,
      required this.initialSelectedWorkspaces,
      // required this.parentState,
})
      : super(key: key);

  @override
  _WorkspaceOptionsModalState createState() => _WorkspaceOptionsModalState();
}

class _WorkspaceOptionsModalState extends State<WorkspaceOptionsModal> {
  List<int> selectedTagIds = [];
  List<Workspace> workspaceList = [];

  @override
  void initState() {
    super.initState();
    selectedTagIds = List.from(widget.initialSelectedWorkspaces);
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _fetchWorkspaceList();
  }

  Future<void> _fetchWorkspaceList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> aliass = prefs.getStringList('workspaceAliases') ?? [];
    List<Workspace> returnedWorkspaces =
        await CallEndpointService().searchWorkspacesByAliass(aliass);
    setState(() {
      workspaceList = returnedWorkspaces;
    });
  }

  void _handleWorkspaceSelection() async {
    // List<Restaurant> restaurants = await widget.parentState.generalFilter();
    List<Restaurant> restaurants = await FilterBarState.generalFilter();
    if (restaurants.isEmpty) {
      ScaffoldMessenger.of(MarkerManager.context).showSnackBar(
        SnackBar(
          content: Text("no resto found".tr()),
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
          _handleWorkspaceSelection();
          Navigator.of(context).pop();
        },
        style: AppButtonStyles.elevatedButtonStyle,
        child: Text("apply".tr()),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: Text(
        "followed workspaces".tr(),
        style: AppTextStyles.titleDarkStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: handleBackNavigation(),
      child: Column(
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
                            } else {
                              selectedTagIds.remove(workspace.id);
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
      ),
    );
  }

  bool handleBackNavigation() {
    //à ne pas supprimer car le corps de la méthode permet de définir le comportement en cas de clique en dehors du bottomsheet pour le fermer.
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // widget.onApply(selectedTagIds);
    // });
    return true; // Retourne true pour permettre le pop, false pour l'empêcher
  }

}
