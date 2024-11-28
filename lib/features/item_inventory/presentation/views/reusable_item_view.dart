import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';
import '../../../../core/common/components/custom_dropdown_button.dart';
import '../../../../core/common/components/custom_dropdown_field.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_form_text_field.dart';
import '../../../../core/common/components/custom_labeled_text_box.dart';
import '../../../../core/common/components/custom_date_picker.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/common/components/custom_search_box.dart';
import '../../../../core/common/components/reusable_linear_progress_indicator.dart';
import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/enums/unit.dart';
import '../../../../core/services/item_suggestions_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/components/custom_outline_button.dart';
import '../../../purchase_request/presentation/components/custom_search_field.dart';
import '../bloc/item_inventory_bloc.dart';

class ReusableItemView extends StatefulWidget {
  const ReusableItemView({
    super.key,
    required this.isUpdate,
    this.itemId,
  });

  final bool isUpdate;
  final String? itemId;

  @override
  State<ReusableItemView> createState() => _RegisterItemViewState();
}

class _RegisterItemViewState extends State<ReusableItemView> {
  late ItemSuggestionsService _itemSuggestionsService;

  final _formKey = GlobalKey<FormState>();
  final _itemIdController = TextEditingController();
  final _encryptedItemIdController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _brandController = TextEditingController();
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
  final ValueNotifier<Unit> _selectedUnit = ValueNotifier(Unit.undetermined);
  final ValueNotifier<String?> _selectedItemName = ValueNotifier(null);
  final ValueNotifier<String?> _selectedManufacturer = ValueNotifier(null);
  final ValueNotifier<String?> _selectedBrand = ValueNotifier(null);

  bool _isViewOnlyMode() => !widget.isUpdate && widget.itemId != null;

  @override
  void initState() {
    super.initState();
    _itemSuggestionsService = serviceLocator<ItemSuggestionsService>();

    if (widget.isUpdate || widget.itemId != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
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

  void _onAssetClassificationSelection(String? value) {
    if (value != null && value.isNotEmpty) {
      _selectedAssetClassification.value =
          AssetClassification.values.firstWhere(
        (e) => e.toString().split('.').last == value.split('.').last,
      );
    }
  }

  void _onUnitSelection(String? value) {
    if (value != null && value.isNotEmpty) {
      _selectedUnit.value = Unit.values.firstWhere(
        (e) => e.toString().split('.').last == value.split('.').last,
      );
    }
  }

  void _onAssetSubClassSelection(String? value) {
    if (value != null && value.isNotEmpty) {
      _selectedAssetSubClassification.value = AssetSubClass.values.firstWhere(
        (e) => e.toString().split('.').last == value.split('.').last,
      );
    }
  }

  void _saveItem() {
    print('''
    ${_itemNameController.text}
    ${_itemDescriptionsController.text}
    ${_manufacturerController.text}
    ${_brandController.text}
    ${_modelController.text}
    ${_serialNoController.text}
    ${_specificationController.text}
    ${_selectedAssetClassification.value}
    ${_selectedAssetSubClassification.value}
    ${_selectedUnit.value}
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
              manufacturerName: _manufacturerController.text,
              brandName: _brandController.text,
              modelName: _modelController.text,
              serialNo: _serialNoController.text,
              specification: _specificationController.text,
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
    ${_itemNameController.text}
    ${_itemDescriptionsController.text}
    ${_manufacturerController.text}
    ${_brandController.text}
    ${_modelController.text}
    ${_serialNoController.text}
    ${_specificationController.text}
    ${_selectedAssetClassification.value}
    ${_selectedAssetSubClassification.value}
    ${_selectedUnit.value}
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
              manufacturerName: _manufacturerController.text,
              brandName: _brandController.text,
              modelName: _modelController.text,
              serialNo: _serialNoController.text,
              specification: _specificationController.text,
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

  @override
  void dispose() {
    _itemIdController.dispose();
    _encryptedItemIdController.dispose();
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
    //_qrCodeImageData.dispose();
    _selectedUnit.dispose();
    _selectedItemName.dispose();
    _selectedManufacturer.dispose();
    _selectedBrand.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ItemInventoryBloc, ItemInventoryState>(
        listener: (context, state) async {
          if (state is ItemRegistered) {
            final itemCount = state.itemEntities.length;

            DelightfulToastUtils.showDelightfulToast(
              context: context,
              icon: Icons.check_circle_outline,
              title: 'Success',
              subtitle: itemCount > 1 ? '$itemCount items registered successfully.' : 'Item registered successfully.',
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
            _encryptedItemIdController.text =
                initItemData.itemEntity.encryptedId;
            _itemNameController.text = initItemData
                    .productStockEntity.productName.name
                    .toLowerCase() ??
                '';
            _itemDescriptionsController.text = initItemData
                    .productStockEntity.productDescription?.description ??
                '';
            _specificationController.text =
                initItemData.itemEntity.specification;
            _brandController.text =
                initItemData.manufacturerBrandEntity.brand.name;
            _modelController.text = initItemData.modelEntity.modelName;
            _serialNoController.text = initItemData.itemEntity.serialNo ?? '';
            _manufacturerController.text =
                initItemData.manufacturerBrandEntity.manufacturer.name;
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
            //_qrCodeImageData.value = initItemData.itemEntity.qrCodeImageData;
          }

          if (state is ItemsError) {
            DelightfulToastUtils.showDelightfulToast(
              context: context,
              icon: Icons.error_outline,
              title: 'Error',
              subtitle: widget.isUpdate
                  ? 'Item update unsuccessful. ${state.message}'
                  : 'Item registered unsuccessful. ${state.message}',
            );
            print('err: ${state.message}');
          }
        },
        child: BlocBuilder<ItemInventoryBloc, ItemInventoryState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state is ItemsLoading)
                  const ReusableLinearProgressIndicator(),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildForm(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 30.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isViewOnlyMode()) _buildViewOnlyWidgets(),
            _buildItemInformationHeader(),
            const SizedBox(
              height: 20.0,
            ),
            _buildPrimaryItemInformationSection(),
            const SizedBox(
              height: 20.0,
            ),
            _buildOtherItemInformationSection(),
            const SizedBox(
              height: 20.0,
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildViewOnlyWidgets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Item QR Code',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 20.0),
        Row(
          children: [
            _buildQrContainer(),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: Column(
                children: [
                  CustomFormTextField(
                    label: 'Item Id',
                    controller: _itemIdController,
                    enabled: !_isViewOnlyMode(),
                    fillColor:
                        (context.watch<ThemeBloc>().state == AppTheme.light
                            ? AppColor.lightCustomTextBox
                            : AppColor.darkCustomTextBox),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  CustomFormTextField(
                    label: 'Encrypted Id',
                    controller: _encryptedItemIdController,
                    enabled: !_isViewOnlyMode(),
                    fillColor:
                        (context.watch<ThemeBloc>().state == AppTheme.light
                            ? AppColor.lightCustomTextBox
                            : AppColor.darkCustomTextBox),
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

  Widget _buildItemInformationHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Item Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          'Items to be stored in the inventory. To list multiple items of the same type, use a \' - \' symbol as a separator in the serial numbers. Apply the same approach to specifications to ensure proper formatting in the document.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
        ),
      ],
    );
  }

  Widget _buildPrimaryItemInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 100.0,
                child: _buildItemNamesSuggestionField(),
              ),
            ),
            const SizedBox(width: 20.0),
            Expanded(
              child: SizedBox(
                height: 100.0,
                child: _buildItemDescriptionsSuggestionField(),
              ),
            ),
          ],
        ),
        //const SizedBox(height: 20.0),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 100.0,
                    child: _buildItemManufacturersSuggestionField(),
                  ),
                  //const SizedBox(height: 20.0),
                  SizedBox(
                    height: 100.0,
                    child: _buildItemModelsSuggestionField(),
                  ),
                  //const SizedBox(height: 20.0),
                ],
              ),
            ),
            const SizedBox(width: 20.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 100.0,
                    child: _buildItemBrandsSuggestionField(),
                  ),
                  //const SizedBox(height: 20.0),
                  SizedBox(
                    height: 100.0,
                    child: CustomFormTextField(
                      label: 'Serial No.',
                      placeholderText: 'Enter item\'s serial no.',
                      controller: _serialNoController,
                      enabled: !_isViewOnlyMode(),
                      fillColor:
                          (context.watch<ThemeBloc>().state == AppTheme.light
                              ? AppColor.lightCustomTextBox
                              : AppColor.darkCustomTextBox),
                    ),
                  ),
                  //const SizedBox(height: 20.0),
                ],
              ),
            ),
          ],
        ),
        CustomFormTextField(
          label: 'Specification',
          placeholderText: 'Enter item\'s specification',
          maxLines: 4,
          controller: _specificationController,
          enabled: !_isViewOnlyMode(),
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        ),
      ],
    );
  }

  Widget _buildOtherItemInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Text(
        //   'Other Information',
        //   style: Theme.of(context).textTheme.titleLarge?.copyWith(
        //         fontSize: 18.0,
        //         fontWeight: FontWeight.w700,
        //       ),
        // ),
        // const SizedBox(
        //   height: 20.0,
        // ),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 100.0,
                    child: _buildAssetClassificationSelection(),
                  ),
                  //const SizedBox(height: 20.0),
                  SizedBox(
                    height: 100.0,
                    child: _buildUnitSelection(),
                  ),
                  //const SizedBox(height: 20.0),
                  SizedBox(
                    height: 100.0,
                    child: CustomFormTextField(
                      label: 'Unit Cost',
                      placeholderText: 'Enter item\'s unit cost',
                      controller: _unitCostController,
                      enabled: !_isViewOnlyMode(),
                      isNumeric: true,
                      isCurrency: true,
                      fillColor:
                          (context.watch<ThemeBloc>().state == AppTheme.light
                              ? AppColor.lightCustomTextBox
                              : AppColor.darkCustomTextBox),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 100.0,
                    child: _buildAssetSubClassSelection(),
                  ),
                  //const SizedBox(height: 20.0),
                  SizedBox(height: 100.0, child: _buildQuantityCounterField()),
                  //const SizedBox(height: 20.0),
                  SizedBox(
                    height: 100.0,
                    child: CustomFormTextField(
                      label: 'Estimated Useful Life',
                      placeholderText: 'Enter item\'s estimated useful life',
                      controller: _estimatedUsefulLifeController,
                      enabled: !_isViewOnlyMode(),
                      isNumeric: true,
                      fillColor:
                          (context.watch<ThemeBloc>().state == AppTheme.light
                              ? AppColor.lightCustomTextBox
                              : AppColor.darkCustomTextBox),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // const SizedBox(
        //   height: 20.0,
        // ),
        SizedBox(
          height: 100.0,
          child: _buildAcquiredDateSelection(),
        ),
      ],
    );
  }

  Widget _buildQrContainer() {
    return Container(
      //padding: const EdgeInsets.all(10.0),
      width: 160.0,
      height: 160.0,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(10.0),
        color: AppColor.lightPrimary,
      ),
      child: QrImageView(
        data: _encryptedItemIdController.text,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.circle,
          color: AppColor.darkPrimary,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.circle,
          color: AppColor.darkPrimary,
        ),
      ),

      // PrettyQrView.data(
      //   data: _encryptedItemIdController.text,
      //   errorCorrectLevel: QrErrorCorrectLevel.L,
      //   decoration: const PrettyQrDecoration(
      //     shape: PrettyQrRoundedSymbol(
      //       color: AppColor.darkPrimary,
      //     ),
      //   ),
      // ),
    );
  }

  Widget _buildItemNamesSuggestionField() {
    return CustomSearchField(
      enabled: !_isViewOnlyMode(),
      suggestionsCallback: (productName) async {
        final itemNames = await _itemSuggestionsService.fetchItemNames(
            productName: productName);

        if (itemNames == []) {
          _itemDescriptionsController.clear();
          _manufacturerController.clear();
          _brandController.clear();
          _modelController.clear();

          _selectedItemName.value = '';
          _selectedManufacturer.value = '';
          _selectedBrand.value = '';
        }

        return itemNames;
      },
      onSelected: (value) {
        _itemNameController.text = value;
        _itemDescriptionsController.clear();
        _selectedItemName.value = value;
      },
      controller: _itemNameController,
      label: 'Item Name',
      placeHolderText: 'Enter item\'s name',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildItemDescriptionsSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedItemName,
      builder: (context, selectedItemName, child) {
        return CustomSearchField(
          key: ValueKey(selectedItemName),
          enabled: !_isViewOnlyMode(),
          suggestionsCallback: (productDescription) async {
            if (selectedItemName != null && selectedItemName.isNotEmpty) {
              return await _itemSuggestionsService.fetchItemDescriptions(
                  productName: selectedItemName,
                  productDescription: productDescription);
            } else {
              return Future.value([]);
            }
          },
          onSelected: (value) {
            _itemDescriptionsController.text = value;
          },
          controller: _itemDescriptionsController,
          label: 'Description',
          placeHolderText: 'Enter item\'s description',
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        );
      },
    );
  }

  Widget _buildItemManufacturersSuggestionField() {
    return CustomSearchField(
      enabled: !_isViewOnlyMode(),
      suggestionsCallback: (manufacturerName) async {
        final manufacturerNames = await _itemSuggestionsService
            .fetchManufacturers(manufacturerName: manufacturerName);

        if (manufacturerNames == []) {
          _brandController.clear();
          _selectedManufacturer.value = '';
        }

        return manufacturerNames;
      },
      onSelected: (value) {
        _manufacturerController.text = value;
        _brandController.clear();
        _selectedManufacturer.value = value;
      },
      controller: _manufacturerController,
      label: 'Manufacturer',
      placeHolderText: 'Enter item\'s manufacturer',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildItemBrandsSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedManufacturer,
      builder: (context, selectedManufacturer, child) {
        return CustomSearchField(
          key: ValueKey(selectedManufacturer),
          enabled: !_isViewOnlyMode(),
          suggestionsCallback: (brandName) async {
            if (selectedManufacturer != null &&
                selectedManufacturer.isNotEmpty) {
              final brandNames = await _itemSuggestionsService.fetchBrands(
                  manufacturerName: selectedManufacturer, brandName: brandName);

              if (brandNames == []) {
                _modelController.clear();
                _selectedBrand.value = '';
              }

              return brandNames;
            } else {
              return Future.value([]);
            }
          },
          onSelected: (value) {
            _brandController.text = value;
            _selectedBrand.value = value;
          },
          controller: _brandController,
          label: 'Brand',
          placeHolderText: 'Enter item\'s brand',
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        );
      },
    );
  }

  Widget _buildItemModelsSuggestionField() {
    return ValueListenableBuilder(
        valueListenable: _selectedItemName,
        builder: (context, selectedItemName, child) {
          return ValueListenableBuilder(
            valueListenable: _selectedBrand,
            builder: (context, selectedBrand, child) {
              return CustomSearchField(
                key: ValueKey('$selectedItemName$selectedBrand'),
                enabled: !_isViewOnlyMode(),
                suggestionsCallback: (modelName) async {
                  if ((selectedItemName != null &&
                          selectedItemName.isNotEmpty) &&
                      (selectedBrand != null && selectedBrand.isNotEmpty)) {
                    return await _itemSuggestionsService.fetchModels(
                        productName: selectedItemName,
                        brandName: selectedBrand,
                        modelName: modelName);
                  } else {
                    return Future.value([]);
                  }
                },
                onSelected: (value) {
                  _modelController.text = value;
                },
                controller: _modelController,
                label: 'Model',
                placeHolderText: 'Enter item\'s model',
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
              );
            },
          );
        });
  }

  Widget _buildAssetClassificationSelection() {
    return ValueListenableBuilder(
      valueListenable: _selectedAssetClassification,
      builder: (context, selectedValue, child) {
        return CustomDropdownField(
          value: selectedValue.toString(),
          onChanged:
              !_isViewOnlyMode() ? _onAssetClassificationSelection : null,
          label: 'Asset Classification',
          items: AssetClassification.values
              .map(
                (assetClassification) => DropdownMenuItem<String>(
                  value: assetClassification.toString(),
                  child: Text(
                    readableEnumConverter(assetClassification),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              )
              .toList(),
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        );
      },
    );
  }

  Widget _buildUnitSelection() {
    return ValueListenableBuilder(
      valueListenable: _selectedUnit,
      builder: (context, selectedUnit, child) {
        return CustomDropdownField(
          value: selectedUnit.toString(),
          onChanged: !_isViewOnlyMode() ? _onUnitSelection : null,
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
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        );
      },
    );
  }

  Widget _buildAssetSubClassSelection() {
    return ValueListenableBuilder(
      valueListenable: _selectedAssetSubClassification,
      builder: (context, selectedValue, widget) {
        return CustomDropdownField(
          value: selectedValue.toString(),
          onChanged: !_isViewOnlyMode() ? _onAssetSubClassSelection : null,
          label: 'Asset Sub Class',
          items: AssetSubClass.values
              .map(
                (assetSubClass) => DropdownMenuItem<String>(
                  value: assetSubClass.toString(),
                  child: Text(
                    readableEnumConverter(assetSubClass),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              )
              .toList(),
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
          label: 'Quantity',
          placeholderText: 'Enter item\'s quantity',
          controller: _quantityController,
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
          enabled: !_isViewOnlyMode(),
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

  Widget _buildAcquiredDateSelection() {
    return ValueListenableBuilder(
      valueListenable: _pickedDate,
      builder: (context, pickedValue, child) {
        final dateController = TextEditingController(
          text: pickedValue != null ? dateFormatter(pickedValue) : '',
        );

        return CustomDatePicker(
          onDateChanged: (DateTime? date) {
            if (date != null) {
              _pickedDate.value = date;
            }
          },
          label: 'Acquired Date',
          dateController: dateController,
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        );
      },
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomOutlineButton(
          onTap: () => context.pop(),
          text: !_isViewOnlyMode() ? 'Cancel' : 'Back',
          width: 180.0,
          height: 40.0,
        ),
        const SizedBox(
          width: 10.0,
        ),
        if (!_isViewOnlyMode())
          CustomFilledButton(
            onTap: widget.isUpdate ? _updateItem : _saveItem,
            text: widget.isUpdate ? 'Update' : 'Save',
            width: 180.0,
            height: 40.0,
          ),
      ],
    );
  }
}
