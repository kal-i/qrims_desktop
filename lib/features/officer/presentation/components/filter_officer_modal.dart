import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/components/custom_dropdown_field.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/common/components/base_modal.dart';
import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/enums/auth_status.dart';
import '../../../../core/services/item_suggestions_service.dart';
import '../../../../core/services/officer_suggestions_service.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../../../../init_dependencies.dart';
import '../../../purchase_request/presentation/components/custom_search_field.dart';

class FilterOfficerModal extends StatefulWidget {
  const FilterOfficerModal({
    super.key,
    required this.onApplyFilters,
    this.office,
  });

  final Function(
    String? office,
  ) onApplyFilters;
  final String? office;

  @override
  State<FilterOfficerModal> createState() => _FilterOfficerModalState();
}

class _FilterOfficerModalState extends State<FilterOfficerModal> {
  late OfficerSuggestionsService _officerSuggestionsService;
  late String? _selectedOfficeFilter;

  final _officeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _officerSuggestionsService = serviceLocator<OfficerSuggestionsService>();
    _selectedOfficeFilter = widget.office;
    _officeController.text =
        _selectedOfficeFilter != null ? _selectedOfficeFilter! : '';
  }

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      width: 900.0,
      height: 300.0,
      headerTitle: 'Filter Officer',
      subtitle: 'Filter officer by their office.',
      content: _buildFilterContents(),
      footer: _buildActionsRow(),
    );
  }

  Widget _buildFilterContents() {
    return Column(
      children: [
        _buildItemManufacturersSuggestionField(),
      ],
    );
  }

  Widget _buildItemManufacturersSuggestionField() {
    return CustomSearchField(
      suggestionsCallback: (officeName) async {
        final manufacturerNames = await _officerSuggestionsService.fetchOffices(
            officeName: officeName);

        if (manufacturerNames == []) {
          _officeController.clear();
          _selectedOfficeFilter = '';
        }

        return manufacturerNames;
      },
      onSelected: (value) {
        _officeController.text = value;
        _selectedOfficeFilter = value;
      },
      controller: _officeController,
      label: 'Office',
      placeHolderText: 'Enter office name',
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
            widget.onApplyFilters(_selectedOfficeFilter);
            context.pop();
          },
          text: 'Apply',
          width: 180.0,
          height: 40.0,
        ),
      ],
    );
  }
}
