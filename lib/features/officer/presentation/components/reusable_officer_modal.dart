import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/components/base_modal.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_form_text_field.dart';
import '../../../../core/common/components/custom_labeled_text_box.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/common/components/custom_search_box.dart';
import '../../../../core/common/components/custom_text_box.dart';
import '../../../../core/services/officer_suggestions_service.dart';
import '../../../../injection_container.dart';
import '../../../purchase_request/presentation/components/custom_search_field.dart';
import '../bloc/officers_bloc.dart';

class ReusableOfficerModal extends StatefulWidget {
  const ReusableOfficerModal({super.key});

  @override
  State<ReusableOfficerModal> createState() => _ReusableOfficerModalState();
}

class _ReusableOfficerModalState extends State<ReusableOfficerModal> {
  late OfficersBloc _officersBloc;
  late OfficerSuggestionsService _officerSuggestionsService;

  final _formKey = GlobalKey<FormState>();
  final _officeNameController = TextEditingController();
  final _positionNameController = TextEditingController();
  final _nameController = TextEditingController();

  final ValueNotifier<String?> _selectedOfficeName = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _officersBloc = context.read<OfficersBloc>();
    _officerSuggestionsService = serviceLocator<OfficerSuggestionsService>();
  }

  void _addOfficer() {
    if (_formKey.currentState!.validate()) {
      _officersBloc.add(
        RegisterOfficerEvent(
          name: _nameController.text,
          officeName: _officeNameController.text,
          positionName: _positionNameController.text,
        ),
      );

      context.pop();

      _nameController.clear();
      _officeNameController.clear();
      _positionNameController.clear();

      _selectedOfficeName.value = null;
    }
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
    _nameController.dispose();
    _officeNameController.dispose();
    _positionNameController.dispose();

    _selectedOfficeName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      width: 900.0,
      height: 500.0,
      headerTitle: 'Add Officer',
      content: _buildContent(),
      footer: _buildActionsRow(),
    );
  }

  Widget _buildContent() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomFormTextField(
            controller: _nameController,
            label: 'Name',
            placeholderText: 'Enter officer\'s name',
          ),
          const SizedBox(
            height: 20.0,
          ),
          _buildOfficeNameSearchBox(),
          const SizedBox(
            height: 20.0,
          ),
          _buildPositionSearchBox(),
        ],
      ),
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
          onTap: _addOfficer,
          text: 'Create',
          width: 180.0,
          height: 40.0,
        ),
      ],
    );
  }
}
