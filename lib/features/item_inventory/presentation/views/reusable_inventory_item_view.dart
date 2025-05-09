import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';
import '../../../../core/common/components/custom_date_picker.dart';
import '../../../../core/common/components/custom_dropdown_field.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_form_text_field.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/common/components/reusable_linear_progress_indicator.dart';
import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/unit.dart';
import '../../../../core/services/item_suggestions_service.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../../core/utils/fund_cluster_to_readable_string.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../../../../init_dependencies.dart';
import '../../../purchase_order/presentation/components/custom_search_field.dart';
import '../../domain/entities/inventory_item.dart';
import '../bloc/item_inventory_bloc.dart';

class ReusableInventoryItemView extends StatefulWidget {
  const ReusableInventoryItemView({
    super.key,
    required this.isUpdate,
    this.itemId,
  });

  final bool isUpdate;
  final String? itemId;

  @override
  State<ReusableInventoryItemView> createState() =>
      _ReusableInventoryItemViewState();
}

class _ReusableInventoryItemViewState extends State<ReusableInventoryItemView> {
  late ItemSuggestionsService _itemSuggestionsService;

  final _formKey = GlobalKey<FormState>();
  final _itemIdController = TextEditingController();
  final _encryptedItemIdController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _itemDescriptionsController = TextEditingController();
  final _specificationController = TextEditingController();
  final _unitController = TextEditingController();
  final _quantityController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialNoController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _estimatedUsefulLifeController = TextEditingController();

  final ValueNotifier<String?> _selectedItemName = ValueNotifier(null);
  final ValueNotifier<String?> _selectedManufacturer = ValueNotifier(null);
  final ValueNotifier<String?> _selectedBrand = ValueNotifier(null);
  final ValueNotifier<Unit?> _selectedUnit = ValueNotifier(null);
  final ValueNotifier<int> _quantity = ValueNotifier(1);
  final ValueNotifier<AssetClassification?> _selectedAssetClassification =
      ValueNotifier(null);
  final ValueNotifier<AssetSubClass?> _selectedAssetSubClassification =
      ValueNotifier(null);
  final ValueNotifier<DateTime> _pickedDate = ValueNotifier(DateTime.now());
  final ValueNotifier<FundCluster?> _selectedFundCluster = ValueNotifier(null);
  final ValueNotifier<List<String>> _serialNumbers = ValueNotifier([]);

  bool _isViewOnlyMode() => !widget.isUpdate && widget.itemId != null;

  @override
  void initState() {
    super.initState();
    _itemSuggestionsService = serviceLocator<ItemSuggestionsService>();

    _quantityController.text = _quantity.value.toString();

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
      final newQuantity = int.tryParse(_quantityController.text) ?? 1;
      _quantity.value = newQuantity;
    });

    _quantity.addListener(() {
      _quantityController.text = _quantity.value.toString();
    });
  }

  void _addSerial(String serial) {
    final trimmed = serial.trim();
    if (trimmed.isEmpty || _serialNumbers.value.contains(trimmed)) return;

    // For update mode, replace existing serial number
    if (widget.isUpdate) {
      _serialNumbers.value = [trimmed];
    } else {
      // For create mode, add to list
      _serialNumbers.value = List.from(_serialNumbers.value)..add(trimmed);
    }
    _serialNoController.clear();
  }

  void _removeSerial(String serial) {
    // Update the list and notify listeners
    _serialNumbers.value = List.from(_serialNumbers.value)..remove(serial);
  }

  void _saveItem() {
    if (_serialNumbers.value.isNotEmpty &&
        (_manufacturerController.text.isEmpty ||
            _brandController.text.isEmpty ||
            _modelController.text.isEmpty)) {
      DelightfulToastUtils.showDelightfulToast(
        context: context,
        title: 'Error',
        subtitle:
            'Please define the manufacturer, brand, and model when serial no. is defined.',
      );
    }

    if (_formKey.currentState!.validate()) {
      context.read<ItemInventoryBloc>().add(
            InventoryItemRegister(
              fundCluster: _selectedFundCluster.value,
              itemName: _itemNameController.text,
              description: _itemDescriptionsController.text,
              specification: _specificationController.text,
              unit: _selectedUnit.value!,
              quantity: _serialNumbers.value.isNotEmpty
                  ? 1
                  : int.parse(_quantityController.text),
              manufacturerName: _manufacturerController.text,
              brandName: _brandController.text,
              modelName: _modelController.text,
              serialNos: widget.isUpdate
                  ? (_serialNumbers.value.isNotEmpty
                      ? [_serialNumbers.value.first]
                      : [])
                  : _serialNumbers.value,
              assetClassification: _selectedAssetClassification.value,
              assetSubClass: _selectedAssetSubClassification.value,
              unitCost: double.parse(_unitCostController.text),
              estimatedUsefulLife:
                  _estimatedUsefulLifeController.text.isNotEmpty
                      ? int.parse(_estimatedUsefulLifeController.text)
                      : null,
              acquiredDate: _pickedDate.value,
            ),
          );
    }
  }

  void _updateItem() {
    if (_serialNumbers.value.isNotEmpty &&
        (_manufacturerController.text.isEmpty ||
            _brandController.text.isEmpty ||
            _modelController.text.isEmpty)) {
      DelightfulToastUtils.showDelightfulToast(
        context: context,
        title: 'Error',
        subtitle:
            'Please define the manufacturer, brand, and model when serial no. is defined.',
      );
    }

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
              quantity: 1,
              unitCost: double.parse(_unitCostController.text),
              estimatedUsefulLife:
                  _estimatedUsefulLifeController.text.isNotEmpty
                      ? int.parse(_estimatedUsefulLifeController.text)
                      : null,
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
    _selectedUnit.dispose();
    _selectedItemName.dispose();
    _selectedManufacturer.dispose();
    _selectedBrand.dispose();
    _selectedFundCluster.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ItemInventoryBloc, ItemInventoryState>(
        listener: (context, state) async {
          if (state is InventoryItemRegistered) {
            final itemCount = state.itemEntities.length;

            DelightfulToastUtils.showDelightfulToast(
              context: context,
              icon: Icons.check_circle_outline,
              title: 'Success',
              subtitle: itemCount > 1
                  ? '$itemCount inventory items registered successfully.'
                  : 'Inventory item registered successfully.',
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

            if (initItemData is InventoryItemEntity) {
              final itemEntity = state.item as InventoryItemEntity;
              final productStockEntity = itemEntity.productStockEntity;
              final productNameEntity = productStockEntity.productName;
              final productDescriptionEntity =
                  productStockEntity.productDescription;
              final shareableItemInformationEntity =
                  itemEntity.shareableItemInformationEntity;
              final manufacturerBrandEntity =
                  itemEntity.manufacturerBrandEntity;
              final manufacturerEntity = manufacturerBrandEntity?.manufacturer;
              final brandEntity = manufacturerBrandEntity?.brand;
              final modelEntity = itemEntity.modelEntity;

              _itemIdController.text =
                  shareableItemInformationEntity.id.toString();
              _encryptedItemIdController.text =
                  shareableItemInformationEntity.encryptedId;
              _itemNameController.text = capitalizeWord(productNameEntity.name);
              _itemDescriptionsController.text =
                  productDescriptionEntity?.description ??
                      'No description defined.';
              _specificationController.text =
                  (shareableItemInformationEntity.specification == null ||
                          shareableItemInformationEntity.specification
                                  ?.toLowerCase() ==
                              'n/a')
                      ? 'No specification defined.'
                      : shareableItemInformationEntity.specification!;
              _brandController.text =
                  brandEntity?.name ?? 'No brand specified.';
              _modelController.text =
                  modelEntity?.modelName ?? 'No model specified.';
              _serialNoController.text = itemEntity.serialNo ?? 'No serial no.';
              _manufacturerController.text =
                  manufacturerEntity?.name ?? 'No manufacturer specified.';
              _selectedAssetClassification.value =
                  AssetClassification.values.firstWhere(
                (e) =>
                    e.toString().split('.').last ==
                    itemEntity.assetClassification?.toString().split('.').last,
                orElse: () => AssetClassification.unknown,
              );

              _selectedAssetSubClassification.value =
                  AssetSubClass.values.firstWhere(
                (e) =>
                    e.toString().split('.').last ==
                    itemEntity.assetSubClass?.toString().split('.').last,
                orElse: () => AssetSubClass.unknown,
              );
              _selectedUnit.value = Unit.values.firstWhere(
                (e) =>
                    e.toString().split('.').last ==
                    shareableItemInformationEntity.unit
                        .toString()
                        .split('.')
                        .last,
                orElse: () => Unit.undetermined,
              );
              _quantityController.text =
                  shareableItemInformationEntity.quantity.toString();
              _unitCostController.text =
                  formatCurrency(shareableItemInformationEntity.unitCost);
              _estimatedUsefulLifeController.text =
                  itemEntity.estimatedUsefulLife != null
                      ? itemEntity.estimatedUsefulLife.toString()
                      : 'No estimated useful life specified.';
              _pickedDate.value =
                  initItemData.shareableItemInformationEntity.acquiredDate ??
                      DateTime.now();

              _selectedFundCluster.value = FundCluster.values.firstWhere(
                (e) =>
                    e.toString().split('.').last ==
                    shareableItemInformationEntity.fundCluster
                        .toString()
                        .split('.')
                        .last,
                orElse: () => FundCluster.unknown,
              );
            }
          }

          if (state is ItemsError) {
            DelightfulToastUtils.showDelightfulToast(
                context: context,
                icon: Icons.error_outline,
                title: widget.isUpdate
                    ? 'Item Update Error'
                    : 'Item Registration Error',
                subtitle: state.message);
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
                    child: _buildEquipmentForm(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEquipmentForm() {
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
          '**📱 Item QR Code**',
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
          '**🔧 Inventory Item Information**',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        _buildInstruction(),
      ],
    );
  }

  Widget _buildInstruction() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: 5.0,
        ),
        Text(
          'Inventory items are stored as individual records in the database for easier tracking and issuance. Each item\'s quantity is always set to 1. If you want to store multiple records at the same time, you can either specify a quantity or list multiple serial numbers, in which case the quantity field will be ignored.',
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
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: SizedBox(
                height: 100.0,
                child: _buildItemDescriptionsSuggestionField(),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 100.0,
                child: _buildUnitSelection(),
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: SizedBox(
                height: 100.0,
                child: _buildQuantityCounterField(),
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: SizedBox(
                height: 100.0,
                child: CustomFormTextField(
                  label: '* Unit Cost',
                  placeholderText: 'Enter item\'s unit cost',
                  controller: _unitCostController,
                  enabled: !_isViewOnlyMode(),
                  isNumeric: true,
                  isCurrency: true,
                  fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                      ? AppColor.lightCustomTextBox
                      : AppColor.darkCustomTextBox),
                ),
              ),
            ),
          ],
        ),
        CustomFormTextField(
          label: 'Specification (optional)',
          placeholderText: 'Enter item\'s specification',
          maxLines: 4,
          controller: _specificationController,
          enabled: !_isViewOnlyMode(),
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
          hasValidation: false,
        ),
        const SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 100.0,
                child: _buildAcquiredDateSelection(),
              ),
            ),
            const SizedBox(width: 20.0),
            Expanded(
              child: SizedBox(
                height: 100.0,
                child: _buildFundClusterSelection(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtherItemInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '**❓ Additional Information**',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          'These details are optional. However, if a serial no. is defined, the manufacturer, brand, and model are required too to prevent conflicts with the unique serial no. constraint.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 100.0,
                child: _buildAssetClassificationSelection(),
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: SizedBox(
                height: 100.0,
                child: _buildAssetSubClassSelection(),
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: SizedBox(
                height: 100.0,
                child: CustomFormTextField(
                  label: 'Estimated Useful Life',
                  placeholderText: 'Enter item\'s estimated useful life',
                  controller: _estimatedUsefulLifeController,
                  enabled: !_isViewOnlyMode(),
                  isNumeric: true,
                  fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                      ? AppColor.lightCustomTextBox
                      : AppColor.darkCustomTextBox),
                  hasValidation: false,
                ),
              ),
            ),
          ],
        ),
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
                  SizedBox(
                    height: 100.0,
                    child: _buildItemModelsSuggestionField(),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 100.0,
                    child: _buildItemBrandsSuggestionField(),
                  ),
                  SizedBox(
                    height: 100.0,
                    child: _buildSerialNoField(),
                  ),
                ],
              ),
            ),
          ],
        ),
        ValueListenableBuilder(
          valueListenable: _serialNumbers,
          builder: (context, serialNumbers, child) {
            return Wrap(
              spacing: 8.0,
              children: (serialNumbers.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: Chip(
                    label: Text(e),
                    onDeleted: widget.isUpdate && serialNumbers.length <= 1
                        ? null // Prevent deletion of last chip in update mode
                        : () => _removeSerial(e),
                  ),
                ),
              )).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQrContainer() {
    return Container(
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
    );
  }

  Widget _buildItemNamesSuggestionField() {
    return CustomSearchField(
      enabled: !widget.isUpdate && !_isViewOnlyMode(),
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
      label: '* Item Name',
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
          label: '* Description',
          placeHolderText: 'Enter item\'s description',
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        );
      },
    );
  }

  Widget _buildItemManufacturersSuggestionField() {
    return ValueListenableBuilder(
        valueListenable: _serialNumbers,
        builder: (context, serialNos, child) {
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
            hasValidation:
                serialNos.isNotEmpty, // Changed from isEmpty to isNotEmpty
          );
        });
  }

  Widget _buildItemBrandsSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _serialNumbers,
      builder: (context, serialNos, child) {
        return CustomSearchField(
          enabled: !_isViewOnlyMode(),
          suggestionsCallback: (brandName) async {
            final brandNames = await _itemSuggestionsService.fetchBrands(
                manufacturerName: _manufacturerController.text,
                brandName: brandName);

            if (brandNames == []) {
              _modelController.clear();
              _selectedBrand.value = '';
            }

            return brandNames;
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
          hasValidation: serialNos.isNotEmpty, // Add validation check for brand
        );
      },
    );
  }

  Widget _buildItemModelsSuggestionField() {
    return ValueListenableBuilder(
        valueListenable: _serialNumbers,
        builder: (context, serialNos, child) {
          return CustomSearchField(
            enabled: !_isViewOnlyMode(),
            suggestionsCallback: (modelName) async {
              final modelNames = await _itemSuggestionsService.fetchModels(
                  productName: _itemNameController.text,
                  brandName: _brandController.text,
                  modelName: modelName);

              return modelNames;
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
            hasValidation:
                serialNos.isNotEmpty, // Add validation check for model
          );
        });
  }

  Widget _buildSerialNoField() {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.enter) {
          _addSerial(_serialNoController.text);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: CustomFormTextField(
        label: 'Serial No.',
        placeholderText: 'Enter item\'s serial no.',
        controller: _serialNoController,
        fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
            ? AppColor.lightCustomTextBox
            : AppColor.darkCustomTextBox),
        enabled: !_isViewOnlyMode(),
        suffixWidget: InkWell(
          onTap: () => _addSerial(_serialNoController.text),
          child: const Icon(
            HugeIcons.strokeRoundedAddCircle,
            size: 20.0,
          ),
        ),
        hasValidation: false,
      ),
    );
  }

  Widget _buildAssetClassificationSelection() {
    return ValueListenableBuilder(
      valueListenable: _selectedAssetClassification,
      builder: (context, selectedValue, child) {
        return CustomDropdownField<AssetClassification>(
          value: selectedValue,
          onChanged: (value) => !_isViewOnlyMode()
              ? _selectedAssetClassification.value = value
              : null,
          label: 'Asset Classification',
          items: [
            const DropdownMenuItem<AssetClassification>(
              value: null,
              child: Text('Select asset classification'),
            ),
            ...AssetClassification.values.map(
              (assetClassification) => DropdownMenuItem(
                value: assetClassification,
                child: Text(
                  readableEnumConverter(assetClassification),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ),
          ],
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
          hasValidation: false,
        );
      },
    );
  }

  Widget _buildUnitSelection() {
    return ValueListenableBuilder(
      valueListenable: _selectedUnit,
      builder: (context, selectedUnit, child) {
        return CustomDropdownField<Unit>(
          value: selectedUnit,
          onChanged: !_isViewOnlyMode()
              ? (value) => _selectedUnit.value = value
              : null,
          items: [
            const DropdownMenuItem<Unit>(
              value: null,
              child: Text('Select unit'),
            ),
            ...Unit.values.map(
              (unit) => DropdownMenuItem(
                value: unit,
                child: Text(
                  readableEnumConverter(unit),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            )
          ],
          label: '* Unit',
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
        return CustomDropdownField<AssetSubClass>(
          value: selectedValue,
          onChanged: (value) => !_isViewOnlyMode()
              ? _selectedAssetSubClassification.value = value
              : null,
          label: 'Asset Sub Class',
          items: [
            const DropdownMenuItem<AssetSubClass>(
              value: null,
              child: Text('Select asset sub class'),
            ),
            ...AssetSubClass.values.map(
              (assetSubClass) => DropdownMenuItem(
                value: assetSubClass,
                child: Text(
                  readableEnumConverter(assetSubClass),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ),
          ],
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
          hasValidation: false,
        );
      },
    );
  }

  Widget _buildQuantityCounterField() {
    return ValueListenableBuilder(
        valueListenable: _serialNumbers,
        builder: (context, serialNos, child) {
          return ValueListenableBuilder(
            valueListenable: _quantity,
            builder: (BuildContext context, int value, Widget? child) {
              return CustomFormTextField(
                label: '* Quantity',
                placeholderText: value.toString(), // Changed this line
                controller: _quantityController,
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
                enabled: !widget.isUpdate && !_isViewOnlyMode(),
                isNumeric: true,
                hasValidation: serialNos.isEmpty,
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
                        if (value != 1) {
                          _quantity.value--;
                          _quantityController.text ==
                              _quantity.value.toString();
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
        });
  }

  Widget _buildAcquiredDateSelection() {
    return ValueListenableBuilder(
      valueListenable: _pickedDate,
      builder: (context, pickedValue, child) {
        final dateController = TextEditingController(
          text: pickedValue != null ? dateFormatter(pickedValue) : '',
        );

        return CustomDatePicker(
          onDateChanged: !widget.isUpdate && !_isViewOnlyMode()
              ? (DateTime? date) {
                  if (date != null) {
                    _pickedDate.value = date;
                  }
                }
              : null,
          enabled: !widget.isUpdate && !_isViewOnlyMode(),
          label: 'Acquired Date',
          dateController: dateController,
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        );
      },
    );
  }

  Widget _buildFundClusterSelection() {
    return ValueListenableBuilder(
      valueListenable: _selectedFundCluster,
      builder: (context, selectedFundCluster, child) {
        return CustomDropdownField<FundCluster>(
          value: selectedFundCluster,
          onChanged: !widget.isUpdate && !_isViewOnlyMode()
              ? (value) => _selectedFundCluster.value = value
              : null,
          items: [
            const DropdownMenuItem<FundCluster>(
              value: null,
              child: Text('Select fund cluster'),
            ),
            ...FundCluster.values.map(
              (fundCluster) => DropdownMenuItem(
                value: fundCluster,
                child: Text(
                  fundCluster.toReadableString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ),
          ],
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
          label: 'Fund Cluster',
          placeholderText: 'Enter purchase request\'s fund cluster',
          hasValidation: false,
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
