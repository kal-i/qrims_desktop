import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/components/base_modal.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_form_text_field.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/services/item_suggestions_service.dart';
import '../../../../init_dependencies.dart';
import '../../../purchase_request/presentation/components/custom_search_field.dart';
import '../bloc/item_inventory_bloc.dart';

class ManageStockModal extends StatefulWidget {
  const ManageStockModal({
    super.key,
  });

  @override
  State<ManageStockModal> createState() => _ManageStockModalState();
}

class _ManageStockModalState extends State<ManageStockModal> {
  late ItemSuggestionsService _itemSuggestionsService;

  final _formKey = GlobalKey<FormState>();

  final _itemNameController = TextEditingController();
  final _itemDescriptionsController = TextEditingController();
  final _stockNoController = TextEditingController();

  final ValueNotifier<String?> _selectedItemName = ValueNotifier(null);
  final ValueNotifier<String?> _selectedDescription = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _itemSuggestionsService = serviceLocator<ItemSuggestionsService>();
  }

  void _submitOfficer() {
    if (_formKey.currentState!.validate()) {
      context.read<ItemInventoryBloc>().add(
            ManageStockEvent(
              itemName: _itemNameController.text,
              description: _itemDescriptionsController.text,
              stockNo: int.parse(_stockNoController.text),
            ),
          );
      context.pop();

      _stockNoController.clear();
      _itemNameController.clear();
      _itemDescriptionsController.clear();

      _selectedDescription.value = null;
    }
  }

  @override
  void dispose() {
    _stockNoController.dispose();
    _itemNameController.dispose();
    _itemDescriptionsController.dispose();

    _selectedItemName.dispose();
    _selectedDescription.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      width: 600.0,
      height: 480.0,
      headerTitle: 'Manage Stock',
      subtitle: 'Add a new item to inventory or update an existing one.',
      content: _buildContent(),
      footer: _buildActionsRow(),
    );
  }

  Widget _buildContent() {
    return Form(
      key: _formKey,
      child: Column(
        spacing: 20.0,
        children: [
          _buildItemNamesSuggestionField(),
          _buildItemDescriptionsSuggestionField(),
          _buildStockNoField(),
        ],
      ),
    );
  }

  Widget _buildItemNamesSuggestionField() {
    return CustomSearchField(
      suggestionsCallback: (productName) async {
        final itemNames = await _itemSuggestionsService.fetchItemNames(
            productName: productName);

        if (itemNames == []) {
          _itemDescriptionsController.clear();
          _stockNoController.clear();

          _selectedItemName.value = null;
          _selectedDescription.value = null;
        }

        return itemNames;
      },
      onSelected: (value) {
        _itemNameController.text = value;
        _itemDescriptionsController.clear();
        _stockNoController.clear();

        _selectedItemName.value = value;
        _selectedDescription.value = null;
      },
      controller: _itemNameController,
      label: '* Item Name',
      placeHolderText: 'Enter item\'s name',
    );
  }

  Widget _buildItemDescriptionsSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedItemName,
      builder: (context, selectedItemName, child) {
        return CustomSearchField(
          key: ValueKey(selectedItemName),
          suggestionsCallback: (productDescription) async {
            if (selectedItemName != null && selectedItemName.isNotEmpty) {
              final descriptions =
                  await _itemSuggestionsService.fetchItemDescriptions(
                productName: selectedItemName,
                productDescription: productDescription,
              );

              if (descriptions == null) {
                _stockNoController.clear();
                _selectedDescription.value = null;
              }
              return descriptions;
            }
            return null;
          },
          onSelected: (value) {
            _itemDescriptionsController.text = value;
            _stockNoController.clear();
            _selectedDescription.value = value;
          },
          controller: _itemDescriptionsController,
          label: '* Description',
          placeHolderText: 'Enter item\'s description',
        );
      },
    );
  }

  Widget _buildStockNoField() {
    return ValueListenableBuilder(
      valueListenable: _selectedItemName,
      builder: (context, selectedItemName, child) {
        return ValueListenableBuilder(
          valueListenable: _selectedDescription,
          builder: (context, selectedDescription, child) {
            return CustomFormTextField(
              key: ValueKey('$selectedItemName-$selectedDescription'),
              controller: _stockNoController,
              label: 'Stock No.',
              placeholderText: 'Enter stock no.',
            );
          },
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
          onTap: _submitOfficer,
          text: 'Save',
          width: 180.0,
          height: 40.0,
        ),
      ],
    );
  }
}
