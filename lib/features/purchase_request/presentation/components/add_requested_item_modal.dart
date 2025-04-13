import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';
import '../../../../core/common/components/base_modal.dart';
import '../../../../core/common/components/custom_dropdown_field.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_form_text_field.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/enums/unit.dart';
import '../../../../core/services/item_suggestions_service.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../../../../init_dependencies.dart';
import '../../../purchase_order/presentation/components/custom_search_field.dart';

class AddRequestedItemModal extends StatefulWidget {
  const AddRequestedItemModal({
    super.key,
    required this.onAdd,
  });

  final Function(
    Map<String, dynamic> requstedItem,
  ) onAdd;

  @override
  State<AddRequestedItemModal> createState() => _AddRequestedItemModalState();
}

class _AddRequestedItemModalState extends State<AddRequestedItemModal> {
  late ItemSuggestionsService _itemSuggestionsService;

  final _formKey = GlobalKey<FormState>();

  final _itemNameController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _itemSpecificationController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitCostController = TextEditingController();

  final ValueNotifier<String?> _selectedItemName = ValueNotifier(null);
  final ValueNotifier<Unit?> _selectedUnit = ValueNotifier(null);
  final ValueNotifier<int> _quantity = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _itemSuggestionsService = serviceLocator<ItemSuggestionsService>();

    _quantityController.addListener(() {
      final newQuantity = int.tryParse(_quantityController.text) ?? 0;
      _quantity.value = newQuantity;
    });

    _quantity.addListener(() {
      _quantityController.text = _quantity.value.toString();
    });
  }

  void _addRequestedItem() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'product_name': _itemNameController.text.trim(),
        'product_description': _itemDescriptionController.text.trim(),
        'specification': _itemSpecificationController.text.isEmpty
            ? null
            : _itemSpecificationController.text,
        'unit': _selectedUnit.value?.toString().split('.').last,
        'quantity': _quantity.value,
        'unit_cost': double.tryParse(_unitCostController.text.trim()) ?? 0.0,
      };
      widget.onAdd(data);
      context.pop();
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _itemSpecificationController.dispose();
    _quantityController.dispose();
    _unitCostController.dispose();

    _selectedItemName.dispose();
    _selectedUnit.dispose();
    _quantity.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      width: 900.0,
      height: 600.0,
      headerTitle: 'Add Requested Item',
      subtitle:
          'Fill in all required fields marked with (*) and leave optional fields blank if not applicable.',
      content: _buildForm(),
      footer: _buildActionsRow(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildItemNameSuggestionField(),
                  ),
                ],
              ),
              const SizedBox(
                height: 15.0,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildItemDescriptionSuggestionField(),
                  ),
                ],
              ),
              const SizedBox(
                height: 15.0,
              ),
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildUnitSelection(),
                    ),
                    const SizedBox(
                      width: 50.0,
                    ),
                    Expanded(
                      child: _buildQuantityCounterField(),
                      // CustomFormTextField(
                      //   label: 'Quantity',
                      // ),
                    ),
                    const SizedBox(
                      width: 50.0,
                    ),
                    Expanded(
                      child: CustomFormTextField(
                        label: '* Unit Cost',
                        controller: _unitCostController,
                        placeholderText: 'Enter item\'s unit cost',
                        fillColor:
                            (context.watch<ThemeBloc>().state == AppTheme.light
                                ? AppColor.lightCustomTextBox
                                : AppColor.darkCustomTextBox),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15.0,
              ),
              CustomFormTextField(
                label: 'Specification (optional)',
                placeholderText: 'Enter item\'s specification',
                maxLines: 4,
                controller: _itemSpecificationController,
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
                hasValidation: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemNameSuggestionField() {
    return CustomSearchField(
      suggestionsCallback: (productName) async {
        final productNames = await _itemSuggestionsService.fetchItemNames(
          productName: productName,
        );

        if (productNames == []) {
          _itemDescriptionController.clear();
          _selectedItemName.value = null;
          _selectedUnit.value = null;
        }

        return productNames;
      },
      onSelected: (value) {
        _itemNameController.text = value;
        _itemDescriptionController.clear();
        _selectedItemName.value = value;
      },
      controller: _itemNameController,
      label: '* Item Name',
      placeHolderText: 'Enter item\'s name',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildItemDescriptionSuggestionField() {
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

              return descriptions;
            }
            return null;
          },
          onSelected: (value) {
            _itemDescriptionController.text = value;
          },
          controller: _itemDescriptionController,
          label: '* Description',
          placeHolderText: 'Enter item\'s description',
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
          maxLines: 4,
        );
      },
    );
  }

  Widget _buildUnitSelection() {
    return ValueListenableBuilder(
      valueListenable: _selectedUnit,
      builder: (context, selectedUnit, child) {
        return CustomDropdownField(
          //value: selectedUnit.toString(),
          onChanged: (value) {
            if (value != null && value.isNotEmpty) {
              _selectedUnit.value = Unit.values.firstWhere(
                  (e) => e.toString().split('.').last == value.split('.').last);
            }
          },
          items: Unit.values
              .map(
                (unit) => DropdownMenuItem(
                  value: unit.toString(),
                  child: Text(
                    readableEnumConverter(unit),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              )
              .toList(),
          label: 'Unit',
          placeholderText: 'Enter item\'s unit',
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        );
      },
    );
  }

  Widget _buildQuantityCounterField() {
    return ValueListenableBuilder(
      valueListenable: _quantity,
      builder: (BuildContext context, int value, Widget? child) {
        return CustomFormTextField(
          label: '* Quantity',
          placeholderText: 'Enter item\'s quantity',
          controller: _quantityController,
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
          isNumeric: true,
          suffixWidget: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  _quantity.value++;
                  _quantityController.text == _quantity.value.toString();
                },
                child: const Icon(
                  Icons.keyboard_arrow_up,
                  size: 18.0,
                ),
              ),
              InkWell(
                onTap: () {
                  if (value != 0) {
                    _quantity.value--;
                    _quantityController.text == _quantity.value.toString();
                  }
                },
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18.0,
                ),
              ),
            ],
          ),
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
          onTap: _addRequestedItem,
          text: 'Add',
          width: 180.0,
          height: 40.0,
        ),
      ],
    );
  }
}
