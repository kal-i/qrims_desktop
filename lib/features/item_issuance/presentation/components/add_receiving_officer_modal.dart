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

  @override
  void initState() {
    super.initState();
    _officerSuggestionsService = serviceLocator<OfficerSuggestionsService>();
  }

  Future<List<String>?> _nameSuggestionCallback(String? name) async {
    final names = await _officerSuggestionsService.fetchOfficers(
      officerName: name,
    );

    if (names == null) {
      _nameController.clear();
    }

    return names;
  }

  Future<List<String>?> _officeSuggestionCallback(String? officeName) async {
    final offices = await _officerSuggestionsService.fetchOffices(
      officeName: officeName,
    );

    if (offices == null) {
      _positionNameController.clear();
      _selectedOfficeName.value = null;
    }

    return offices;
  }

  void _onOfficeSelected(String value) {
    _officeNameController.text = value;
    _positionNameController.clear();
    _selectedOfficeName.value = value;
  }

  void _onPositionSelected(String value) {
    _positionNameController.text = value;
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
      content: _buildContent(),
      footer: _buildActionsRow(),
    );
  }

  Widget _buildContent() {
    return Column(
      spacing: 20.0,
      children: [
        _buildOfficerNameSearchBox(),
        _buildOfficeNameSearchBox(),
        _buildPositionSearchBox(),
      ],
    );
  }

  Widget _buildOfficerNameSearchBox() {
    return CustomSearchField(
      suggestionsCallback: _nameSuggestionCallback,
      onSelected: (value) {
        _nameController.text = value;
        // Optionally, you can set _showAdditionalFields.value = false here if needed
      },
      controller: _nameController,
      label: 'Officer Name',
      placeHolderText: 'Enter officer\'s name',
    );
  }

  Widget _buildOfficeNameSearchBox() {
    return CustomSearchField(
      suggestionsCallback: _officeSuggestionCallback,
      onSelected: _onOfficeSelected,
      controller: _officeNameController,
      label: 'Office Name',
      placeHolderText: 'Enter officer\'s office',
    );
  }

  Widget _buildPositionSearchBox() {
    return ValueListenableBuilder(
      valueListenable: _selectedOfficeName,
      builder: (context, selectedOfficeName, child) {
        return CustomSearchField(
          suggestionsCallback: (String? positionName) async {
            if (selectedOfficeName != null && selectedOfficeName.isNotEmpty) {
              final positionNames =
                  await _officerSuggestionsService.fetchOfficePositions(
                officeName: selectedOfficeName,
                positionName: positionName,
              );

              return positionNames;
            }
            return null;
          },
          onSelected: _onPositionSelected,
          controller: _positionNameController,
          label: 'Position Name',
          placeHolderText: 'Enter officer\'s position',
        );
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
          text: 'Create',
          width: 180.0,
          height: 40.0,
        ),
      ],
    );
  }
}
