import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

import "../../../../core/common/components/base_modal.dart";
import "../../../../core/common/components/custom_filled_button.dart";
import "../../../../core/common/components/custom_outline_button.dart";
import "../../../../core/services/officer_suggestions_service.dart";
import "../../../../init_dependencies.dart";
import "../../../purchase_order/presentation/components/custom_search_field.dart";

class AddReceivingOfficerModal extends StatefulWidget {
  const AddReceivingOfficerModal({super.key});

  @override
  State<AddReceivingOfficerModal> createState() =>
      _AddReceivingOfficerModalState();
}

class _AddReceivingOfficerModalState extends State<AddReceivingOfficerModal> {
  late OfficerSuggestionsService _officerSuggestionsService;

  final _officeNameController = TextEditingController();
  final _positionNameController = TextEditingController();
  final _nameController = TextEditingController();

  final ValueNotifier<String?> _selectedOfficeName = ValueNotifier(null);
  final ValueNotifier<String?> _selectedPositionName = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _officerSuggestionsService = serviceLocator<OfficerSuggestionsService>();
  }

  @override
  void dispose() {
    _officeNameController.dispose();
    _positionNameController.dispose();
    _nameController.dispose();
    _selectedOfficeName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      width: 600.0,
      height: 450.0,
      headerTitle: "Add Receiving Officer",
      subtitle:
          'Designated accountable officer or recipeint of this issuance document.',
      content: _buildContent(),
      footer: _buildActionsRow(),
    );
  }

  Widget _buildContent() {
    return Column(
      spacing: 20.0,
      children: [
        _buildOfficeNameSearchBox(),
        _buildPositionSearchBox(),
        _buildOfficerNameSearchBox(),
      ],
    );
  }

  Widget _buildOfficeNameSearchBox() {
    return CustomSearchField(
      suggestionsCallback: (officeName) async {
        final offices = await _officerSuggestionsService.fetchOffices(
          officeName: officeName,
        );

        if (offices == null) {
          _positionNameController.clear();
          _nameController.clear();

          _selectedOfficeName.value = null;
          _selectedPositionName.value = null;
        }

        return offices;
      },
      onSelected: (value) {
        _officeNameController.text = value;
        _positionNameController.clear();
        _nameController.clear();

        _selectedOfficeName.value = value;
        _selectedPositionName.value = null;
      },
      controller: _officeNameController,
      label: 'Office',
      placeHolderText: 'Enter officer\'s office',
    );
  }

  Widget _buildPositionSearchBox() {
    return ValueListenableBuilder(
      valueListenable: _selectedOfficeName,
      builder: (context, selectedOfficeName, child) {
        return CustomSearchField(
          key: ValueKey(selectedOfficeName),
          suggestionsCallback: (String? positionName) async {
            if (selectedOfficeName != null && selectedOfficeName.isNotEmpty) {
              final positions =
                  await _officerSuggestionsService.fetchOfficePositions(
                officeName: selectedOfficeName,
                positionName: positionName,
              );

              if (positions == null) {
                _nameController.clear();
                _selectedPositionName.value = null;
              }

              return positions;
            }
            return null;
          },
          onSelected: (value) {
            _positionNameController.text = value;
            _nameController.clear();
            _selectedPositionName.value = value;
          },
          controller: _positionNameController,
          label: 'Position',
          placeHolderText: 'Enter officer\'s position',
        );
      },
    );
  }

  Widget _buildOfficerNameSearchBox() {
    return ValueListenableBuilder(
      valueListenable: _selectedOfficeName,
      builder: (context, selectedOfficeName, child) {
        return ValueListenableBuilder(
            valueListenable: _selectedPositionName,
            builder: (context, selectedPositionName, child) {
              return CustomSearchField(
                key: ValueKey('$selectedOfficeName-$selectedPositionName'),
                suggestionsCallback: (String? officerName) async {
                  if ((selectedOfficeName != null &&
                          selectedOfficeName.isNotEmpty) &&
                      (selectedPositionName != null &&
                          selectedPositionName.isNotEmpty)) {
                    final officers =
                        await _officerSuggestionsService.fetchOfficers(
                      officeName: selectedOfficeName,
                      positionName: selectedPositionName,
                      officerName: officerName,
                    );

                    return officers;
                  }
                  return null;
                },
                onSelected: (value) {
                  _nameController.text = value;
                },
                controller: _nameController,
                label: 'Name',
                placeHolderText: 'Enter officer\'s name',
              );
            });
      },
    );
  }

  Widget _buildActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomOutlineButton(
          onTap: () => context.pop(),
          text: 'Cancel',
          width: 180.0,
        ),
        const SizedBox(
          width: 10.0,
        ),
        CustomFilledButton(
          onTap: () {
            // Gather officer data
            final officerData = {
              'officer': {
                'name': _nameController.text,
                'position': _positionNameController.text,
                'office': _officeNameController.text,
              },
              'items': [],
            };
            context.pop(officerData);
          },
          text: 'Add',
          width: 180.0,
          height: 40.0,
        ),
      ],
    );
  }
}
