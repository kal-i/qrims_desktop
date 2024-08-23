import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/components/base_container.dart';
import '../../../../core/common/components/custom_dropdown_button.dart';
import '../../../../core/common/components/custom_labeled_text_box.dart';
import '../../../../core/common/components/custom_date_picker.dart';
import '../../../../core/common/components/custom_search_box.dart';
import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/enums/unit.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../../../auth/presentation/components/custom_outline_button.dart';
import '../bloc/item_inventory_bloc.dart';

class ReusableItemView extends StatefulWidget {
  const ReusableItemView({
    super.key,
    required this.isUpdate,
    this.itemId,
  });

  final bool isUpdate;
  final int? itemId;

  @override
  State<ReusableItemView> createState() => _RegisterItemViewState();
}

class _RegisterItemViewState extends State<ReusableItemView> {
  final _formKey = GlobalKey<FormState>();
  final _itemIdController = TextEditingController();
  final _encryptedItemIdController = TextEditingController();
  final _brandController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialNoController = TextEditingController();
  final _specificationController = TextEditingController();
  final _unitController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _estimatedUsefulLifeController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _itemDescriptionsController = TextEditingController();

  final ValueNotifier<int> _quantity = ValueNotifier(0);
  final ValueNotifier<AssetClassification> _selectedAssetClassification =
      ValueNotifier(AssetClassification.unknown);
  final ValueNotifier<AssetSubClass> _selectedAssetSubClassification =
      ValueNotifier(AssetSubClass.unknown);
  final ValueNotifier<DateTime> _pickedDate = ValueNotifier(DateTime.now());
  final ValueNotifier<String?> _qrCodeImageData = ValueNotifier(null);
  final ValueNotifier<Unit> _selectedUnit = ValueNotifier(Unit.undetermined);
  final ValueNotifier<String?> _selectedItemName = ValueNotifier(null);

  bool _isViewOnlyMode() => !widget.isUpdate && widget.itemId != null;

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate || widget.itemId != null) {
      print(widget.itemId);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          print('received item id: ${widget.itemId}');
          context.read<ItemInventoryBloc>().add(
                FetchItemById(
                  id: widget.itemId!,
                ),
              );
        },
      );
    }

    _quantityController.addListener(() {
      final newQuantity = int.tryParse(_quantityController.text) ?? 0;
      _quantity.value = newQuantity;
    });

    _quantity.addListener(() {
      _quantityController.text = _quantity.value.toString();
    });
  }

  @override
  void dispose() {
    _brandController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _serialNoController.dispose();
    _specificationController.dispose();
    _unitController.dispose();
    _quantityController.dispose();
    _unitCostController.dispose();
    _estimatedUsefulLifeController.dispose();
    _itemNameController.dispose();
    _itemDescriptionsController.dispose();

    _quantity.dispose();
    _selectedAssetClassification.dispose();
    _selectedAssetSubClassification.dispose();
    _pickedDate.dispose();
    _qrCodeImageData.dispose();
    _selectedUnit.dispose();
    _selectedItemName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ItemInventoryBloc, ItemInventoryState>(
      listener: (context, state) async {
        if (state is ItemRegistered) {
          DelightfulToastUtils.showDelightfulToast(
            context: context,
            icon: Icons.check_circle_outline,
            title: 'Success',
            subtitle: 'Item registered successfully.',
          );
          await Future.delayed(const Duration(seconds: 3));
          context.pop();
        }

        if (state is ItemUpdated) {
          DelightfulToastUtils.showDelightfulToast(
            context: context,
            icon: Icons.check_circle_outline,
            title: 'Success',
            subtitle: 'Item updated successfully.',
          );
          await Future.delayed(const Duration(seconds: 3));
          context.pop();
        }

        if (state is ItemFetched) {
          final initItemData = state.item;

          _itemIdController.text = initItemData.itemEntity.id.toString();
          _encryptedItemIdController.text = initItemData.itemEntity.encryptedId;
          _itemNameController.text =
              initItemData.stockEntity?.productName ?? '';
          _itemDescriptionsController.text =
              initItemData.stockEntity?.description ?? '';
          _specificationController.text = initItemData.itemEntity.specification;
          _brandController.text = initItemData.itemEntity.brand;
          _modelController.text = initItemData.itemEntity.model;
          _serialNoController.text = initItemData.itemEntity.serialNo ?? '';
          _manufacturerController.text = initItemData.itemEntity.manufacturer;
          _selectedAssetClassification.value =
              AssetClassification.values.firstWhere(
            (e) =>
                e.toString().split('.').last ==
                initItemData.itemEntity.assetClassification
                    ?.toString()
                    .split('.')
                    .last,
            orElse: () => AssetClassification.unknown,
          );

          _selectedAssetSubClassification.value =
              AssetSubClass.values.firstWhere(
            (e) =>
                e.toString().split('.').last ==
                initItemData.itemEntity.assetSubClass
                    ?.toString()
                    .split('.')
                    .last,
            orElse: () => AssetSubClass.unknown,
          );
          _selectedUnit.value = Unit.values.firstWhere(
            (e) =>
                e.toString().split('.').last ==
                initItemData.itemEntity.unit.toString().split('.').last,
            orElse: () => Unit.undetermined,
          );
          _quantityController.text =
              initItemData.itemEntity.quantity.toString();
          _unitCostController.text =
              initItemData.itemEntity.unitCost.toString();
          _estimatedUsefulLifeController.text =
              initItemData.itemEntity.estimatedUsefulLife.toString();
          _pickedDate.value =
              initItemData.itemEntity.acquiredDate ?? DateTime.now();
          _qrCodeImageData.value = initItemData.itemEntity.qrCodeImageData;
          print('fetched: $_selectedAssetClassification');
          print('fetched: $_pickedDate');
        }

        if (state is ItemsError) {
          print('err msg: ${state.message}');
          DelightfulToastUtils.showDelightfulToast(
            context: context,
            icon: Icons.error_outline,
            title: 'Error',
            subtitle: widget.isUpdate
                ? 'Item update unsuccessful. ${state.message}'
                : 'Item registered unsuccessful. ${state.message}',
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNavLink(),
          const SizedBox(
            height: 10.0,
          ),
          Expanded(
            child: BaseContainer(
              child: SingleChildScrollView(
                child: _buildForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink() {
    return Row(
      children: [
        TextButton(
          onPressed: () => context.pop(),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
          ),
          child: Text(
            'Inventory Overview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 14.0,
                ),
          ),
        ),
        const SizedBox(width: 8.0),
        Icon(
          CupertinoIcons.chevron_forward,
          color: Theme.of(context).dividerColor,
          size: 20.0,
        ),
        const SizedBox(width: 8.0),
        Text(
          widget.itemId != null
              ? widget.isUpdate
                  ? 'Update Item'
                  : 'View Item'
              : 'Register Item',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 14.0,
              ),
        ),
      ],
    );
  }

  Widget _buildViewOnlyWidgets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Item QR Code',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 20.0),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              width: 120.0,
              height: 120.0,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ValueListenableBuilder(
                valueListenable: _qrCodeImageData,
                builder: (context, qrCodeImage, child) {
                  return qrCodeImage != null
                      ? Image.memory(
                          base64Decode(qrCodeImage),
                        )
                      : const Icon(Icons.qr_code_2_outlined);
                },
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: Column(
                children: [
                  CustomLabeledTextBox(
                    label: 'Item Id',
                    controller: _itemIdController,
                    enabled: !_isViewOnlyMode(),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  CustomLabeledTextBox(
                    label: 'Encrypted Id',
                    controller: _encryptedItemIdController,
                    enabled: !_isViewOnlyMode(),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 40.0,
        ),
      ],
    );
  }

  Widget _buildItemNamesSuggestionField() {
    return CustomSearchBox(
      enabled: !_isViewOnlyMode(),
      suggestionsCallback: itemNamesSuggestionCallback,
      onSelected: (value) {
        _itemNameController.text = value;
        _itemDescriptionsController.clear();
        _selectedItemName.value = value;
      },
      controller: _itemNameController,
      label: 'Item Name',
    );
  }

  Future<List<String>> itemNamesSuggestionCallback(String? productName) async {
    try {
      print(productName);
      final response = await Dio().get(
        'http://localhost:8080/items/stocks/get_product_names',
        queryParameters: {
          if (productName != null && productName.isNotEmpty)
            'product_name': productName,
        },
      );
      final itemNames = (response.data['product_names'] as List<dynamic>?)
          ?.map((itemName) => itemName as String)
          .toList();

      if (itemNames == null || itemNames.isEmpty) {
        _itemDescriptionsController.clear();
        _selectedItemName.value = '';
      }

      return itemNames ?? [];
    } catch (e) {
      print('Error fetching items\' suggestions: $e');
      return [];
    }
  }

  // use tab after searching then it will automatically make the req
  Widget _buildItemDescriptionsSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedItemName,
      builder: (context, selectedItemName, child) {
        return CustomSearchBox(
          key: ValueKey(selectedItemName),
          enabled: !_isViewOnlyMode(),
          suggestionsCallback: (productName) async {
            if (selectedItemName != null && selectedItemName.isNotEmpty) {
              return await itemDescriptionsSuggestionCallback(selectedItemName);
            } else {
              return Future.value([]);
            }
          },
          onSelected: (value) {
            _itemDescriptionsController.text = value;
          },
          controller: _itemDescriptionsController,
          label: 'Description',
        );
      },
    );
  }

  Future<List<String>> itemDescriptionsSuggestionCallback(
      String? productName) async {
    try {
      print(productName);
      final response = await Dio().get(
        'http://localhost:8080/items/stocks/get_descriptions',
        queryParameters: {
          if (productName != null && productName.isNotEmpty)
            'product_name': productName,
        },
      );
      final descriptions = (response.data['descriptions'] as List<dynamic>?)
          ?.map((itemName) => itemName as String)
          .toList();

      return descriptions ?? [];
    } catch (e) {
      print('Error fetching descriptions\' suggestions: $e');
      return [];
    }
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isViewOnlyMode()) _buildViewOnlyWidgets(),
          Text(
            'Item Description',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 20.0),
          Row(
            children: [
              Expanded(child: _buildItemNamesSuggestionField()),
              const SizedBox(width: 20.0),
              Expanded(child: _buildItemDescriptionsSuggestionField()),
            ],
          ),
          const SizedBox(height: 20.0),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomLabeledTextBox(
                      label: 'Brand',
                      controller: _brandController,
                      enabled: !_isViewOnlyMode(),
                    ),
                    const SizedBox(height: 20.0),
                    CustomLabeledTextBox(
                      label: 'Model',
                      controller: _modelController,
                      enabled: !_isViewOnlyMode(),
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
              const SizedBox(width: 20.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomLabeledTextBox(
                      label: 'Manufacturer',
                      controller: _manufacturerController,
                      enabled: !_isViewOnlyMode(),
                    ),
                    const SizedBox(height: 20.0),
                    CustomLabeledTextBox(
                      label: 'Serial No.',
                      controller: _serialNoController,
                      enabled: !_isViewOnlyMode(),
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
            ],
          ),
          CustomLabeledTextBox(
            label: 'Specification',
            maxLines: 4,
            controller: _specificationController,
            enabled: !_isViewOnlyMode(),
          ),
          const SizedBox(
            height: 40.0,
          ),
          Text(
            'Other Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: _selectedAssetClassification,
                      builder: (context, selectedValue, child) {
                        return CustomDropdownButton(
                          value: selectedValue.toString(),
                          onChanged: !_isViewOnlyMode()
                              ? (String? value) {
                                  if (value != null && value.isNotEmpty) {
                                    _selectedAssetClassification.value =
                                        AssetClassification.values.firstWhere(
                                      (e) =>
                                          e.toString().split('.').last ==
                                          value.split('.').last,
                                    );
                                    print(_selectedAssetClassification);
                                  }
                                }
                              : null,
                          label: 'Asset Classification',
                          items: AssetClassification.values
                              .map(
                                (assetClassification) =>
                                    DropdownMenuItem<String>(
                                  value: assetClassification.toString(),
                                  child: Text(
                                    readableEnumConverter(assetClassification),
                                    style:
                                    Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 12.0, fontWeight: FontWeight.w500,),
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 20.0),
                    ValueListenableBuilder(
                      valueListenable: _selectedUnit,
                      builder: (context, selectedUnit, child) {
                        return CustomDropdownButton(
                          value: selectedUnit.toString(),
                          onChanged:
                              !_isViewOnlyMode() ? (String? value) {} : null,
                          items: Unit.values
                              .map(
                                (unit) => DropdownMenuItem(
                                  value: unit.toString(),
                                  child: Text(
                                    readableEnumConverter(unit),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 12.0, fontWeight: FontWeight.w500,),
                                  ),
                                ),
                              )
                              .toList(),
                          label: 'Unit',
                        );
                      },
                    ),
                    const SizedBox(height: 20.0),
                    CustomLabeledTextBox(
                      label: 'Unit Cost',
                      controller: _unitCostController,
                      enabled: !_isViewOnlyMode(),
                      isNumeric: true,
                      isCurrency: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: _selectedAssetSubClassification,
                      builder: (context, selectedValue, widget) {
                        return CustomDropdownButton(
                          value: selectedValue.toString(),
                          onChanged: !_isViewOnlyMode()
                              ? (String? value) {
                                  if (value != null && value.isNotEmpty) {
                                    _selectedAssetSubClassification.value =
                                        AssetSubClass.values.firstWhere(
                                      (e) =>
                                          e.toString().split('.').last ==
                                          value.split('.').last,
                                    );
                                  }
                                }
                              : null,
                          label: 'Asset Sub Class',
                          items: AssetSubClass.values
                              .map(
                                (assetSubClass) => DropdownMenuItem<String>(
                                  value: assetSubClass.toString(),
                                  child: Text(
                                    readableEnumConverter(assetSubClass),
                                    style:
                                    Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 12.0, fontWeight: FontWeight.w500,),
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 20.0),
                    ValueListenableBuilder(
                      valueListenable: _quantity,
                      builder:
                          (BuildContext context, int value, Widget? child) {
                        return CustomLabeledTextBox(
                          label: 'Quantity',
                          controller: _quantityController,
                          enabled: !_isViewOnlyMode(),
                          isNumeric: true,
                          suffixWidget: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  _quantity.value++;
                                  _quantityController.text ==
                                      _quantity.value.toString();
                                },
                                child: const Icon(
                                  Icons.keyboard_arrow_up,
                                  size: 18.0,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  _quantity.value--;
                                  _quantityController.text ==
                                      _quantity.value.toString();
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
                    ),
                    const SizedBox(height: 20.0),
                    CustomLabeledTextBox(
                      label: 'Estimated Useful Life',
                      controller: _estimatedUsefulLifeController,
                      enabled: !_isViewOnlyMode(),
                      isNumeric: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20.0,
          ),
          ValueListenableBuilder(
            valueListenable: _pickedDate,
            builder: (context, pickedValue, child) {
              print(pickedValue);
              final dateController = TextEditingController(
                text: pickedValue != null ? dateFormatter(pickedValue) : '',
              );

              return CustomDatePicker(
                onDateChanged: (DateTime? date) {
                  if (date != null) {
                    print('Date changed to: $date');
                    _pickedDate.value = date;
                  }
                },
                label: 'Acquired Date',
                dateController: dateController,
              );
            },
          ),
          const SizedBox(
            height: 20.0,
          ),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomOutlineButton(
          onTap: () => context.pop(),
          text: !_isViewOnlyMode() ? 'Cancel' : 'Back',
          height: 40.0,
        ),
        const SizedBox(
          width: 10.0,
        ),
        // CustomFilledButton(
        //   onTap: widget.isUpdate ? _updateItem : _saveItem,
        //   text: widget.isUpdate ? 'Update' : 'Save',
        //   height: 40.0,
        // ),
        if (!_isViewOnlyMode())
          CustomOutlineButton(
            onTap: widget.isUpdate ? _updateItem : _saveItem,
            text: widget.isUpdate ? 'Update' : 'Save',
            height: 40.0,
          ),
      ],
    );
  }

  void _saveItem() {
    print('''
    ${_specificationController.text}
    ${_brandController.text}
    ${_modelController.text}
    ${_serialNoController.text}
    ${_manufacturerController.text}
    ${_selectedAssetClassification.value}
    ${_selectedAssetSubClassification.value}
    ${_unitController.text}
    ${_quantityController.text}
    ${_unitCostController.text}
    ${_estimatedUsefulLifeController.text}
    $_pickedDate
    ''');

    if (_formKey.currentState!.validate()) {
      context.read<ItemInventoryBloc>().add(
            ItemRegister(
              itemName: _itemNameController.text,
              description: _itemDescriptionsController.text,
              specification: _specificationController.text,
              brand: _brandController.text,
              model: _modelController.text,
              serialNo: _serialNoController.text,
              manufacturer: _manufacturerController.text,
              assetClassification: _selectedAssetClassification.value,
              assetSubClass: _selectedAssetSubClassification.value,
              unit: _selectedUnit.value,
              quantity: int.parse(_quantityController.text),
              unitCost: double.parse(_unitCostController.text),
              estimatedUsefulLife:
                  int.parse(_estimatedUsefulLifeController.text),
              acquiredDate: _pickedDate.value,
            ),
          );
    }
  }

  void _updateItem() {
    print('''
    Updated Item Info:
    
    ${_specificationController.text}
    ${_brandController.text}
    ${_modelController.text}
    ${_serialNoController.text}
    ${_manufacturerController.text}
    ${_selectedAssetClassification.value}
    ${_selectedAssetSubClassification.value}
    ${_unitController.text}
    ${_quantityController.text}
    ${_unitCostController.text}
    ${_estimatedUsefulLifeController.text}
    $_pickedDate
    ''');

    if (_formKey.currentState!.validate()) {
      context.read<ItemInventoryBloc>().add(
            ItemUpdate(
              id: widget.itemId!,
              itemName: _itemNameController.text,
              description: _itemDescriptionsController.text,
              specification: _specificationController.text,
              brand: _brandController.text,
              model: _modelController.text,
              serialNo: _serialNoController.text,
              manufacturer: _manufacturerController.text,
              assetClassification: _selectedAssetClassification.value,
              assetSubClass: _selectedAssetSubClassification.value,
              unit: _selectedUnit.value,
              quantity: int.parse(_quantityController.text),
              unitCost: double.parse(_unitCostController.text),
              estimatedUsefulLife:
                  int.parse(_estimatedUsefulLifeController.text),
              acquiredDate: _pickedDate.value,
            ),
          );
    }
  }

  getData(String productName) async {}
}
