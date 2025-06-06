import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/unit.dart';
import '../../../../core/services/item_suggestions_service.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/utils/confirmation_dialog.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../../core/utils/fund_cluster_to_readable_string.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../../../../init_dependencies.dart';
import '../../../purchase_order/presentation/components/custom_search_field.dart';
import '../../domain/entities/supply.dart';
import '../bloc/item_inventory_bloc.dart';

class ReusableSupplyItemView extends StatefulWidget {
  const ReusableSupplyItemView({
    super.key,
    required this.isUpdate,
    this.itemId,
  });

  final bool isUpdate;
  final String? itemId;

  @override
  State<ReusableSupplyItemView> createState() => _ReusableSupplyItemViewState();
}

class _ReusableSupplyItemViewState extends State<ReusableSupplyItemView> {
  late ItemSuggestionsService _itemSuggestionsService;

  final _formKey = GlobalKey<FormState>();
  final _itemIdController = TextEditingController();
  final _encryptedItemIdController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _itemDescriptionsController = TextEditingController();
  final _specificationController = TextEditingController();
  final _unitController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitCostController = TextEditingController();

  final ValueNotifier<int> _quantity = ValueNotifier(1);
  final ValueNotifier<String?> _selectedItemName = ValueNotifier(null);
  final ValueNotifier<Unit?> _selectedUnit = ValueNotifier(null);

  final ValueNotifier<DateTime> _pickedDate = ValueNotifier(DateTime.now());
  final ValueNotifier<FundCluster?> _selectedFundCluster = ValueNotifier(null);

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

  void _saveItem() {
    if (!_formKey.currentState!.validate()) return;

    confirmationDialog(
      context: context,
      title: 'Register Supply Item?',
      content: 'Are you sure you want to register this item?',
      onConfirmed: () => context.read<ItemInventoryBloc>().add(
            SupplyItemRegister(
              itemName: _itemNameController.text,
              description: _itemDescriptionsController.text,
              specification: _specificationController.text.isEmpty
                  ? null
                  : _specificationController.text,
              unit: _selectedUnit.value!,
              quantity: int.parse(_quantityController.text),
              unitCost: double.parse(_unitCostController.text),
              acquiredDate: _pickedDate.value,
              fundCluster: _selectedFundCluster.value,
            ),
          ),
    );
  }

  void _updateItem() {
    if (!_formKey.currentState!.validate()) return;

    confirmationDialog(
      context: context,
      title: 'Update Supply Item?',
      content: 'Are you sure you want to update this item?',
      onConfirmed: () => context.read<ItemInventoryBloc>().add(
            ItemUpdate(
              id: widget.itemId!,
              itemName: _itemNameController.text,
              description:
                  _itemDescriptionsController.text == 'No description defined.'
                      ? null
                      : _itemDescriptionsController.text,
              specification:
                  _specificationController.text == 'No specification defined.'
                      ? null
                      : _specificationController.text,
              unit: _selectedUnit.value,
              quantity: int.parse(_quantityController.text),
              unitCost: double.parse(_unitCostController.text),
            ),
          ),
    );
  }

  @override
  void dispose() {
    _itemIdController.dispose();
    _encryptedItemIdController.dispose();
    _itemNameController.dispose();
    _itemDescriptionsController.dispose();
    _specificationController.dispose();
    _unitController.dispose();
    _quantityController.dispose();
    _unitCostController.dispose();

    _quantity.dispose();
    _selectedItemName.dispose();
    _selectedUnit.dispose();

    _pickedDate.dispose();
    _selectedFundCluster.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ItemInventoryBloc, ItemInventoryState>(
        listener: (context, state) async {
          if (state is SupplyItemRegistered) {
            DelightfulToastUtils.showDelightfulToast(
              context: context,
              icon: Icons.check_circle_outline,
              title: 'Success',
              subtitle: 'Supply item registered successfully.',
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

            if (initItemData is SupplyEntity) {
              final itemEntity = state.item;
              final productStock = itemEntity.productStockEntity;
              final productNameEntity = productStock.productName;
              final productDescriptionEntity = productStock.productDescription;
              final shareableItemInformationEntity =
                  itemEntity.shareableItemInformationEntity;

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

              _selectedUnit.value = Unit.values.firstWhere(
                (e) =>
                    e.toString().split('.').last ==
                    initItemData.shareableItemInformationEntity.unit
                        .toString()
                        .split('.')
                        .last,
                orElse: () => Unit.undetermined,
              );
              _quantityController.text = initItemData
                  .shareableItemInformationEntity.quantity
                  .toString();
              _unitCostController.text = formatCurrency(
                  initItemData.shareableItemInformationEntity.unitCost);

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
              title: 'Error',
              subtitle: widget.isUpdate
                  ? 'Item update unsuccessful. ${state.message}'
                  : 'Item registered unsuccessful. ${state.message}',
            );
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
                    child: _buildSupplyForm(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSupplyForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 30.0,
        ),
        child: Column(
          children: [
            if (_isViewOnlyMode()) _buildViewOnlyWidgets(),
            _buildItemInformationHeader(),
            const SizedBox(
              height: 20.0,
            ),
            _buildSupplyInformationSection(),
            const SizedBox(
              height: 20.0,
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemInformationHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '**📦 Supply Item Information**',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
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
          'Items to be stored as consumables or supplies.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
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

  Widget _buildSupplyInformationSection() {
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
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return null;
            }
            return null;
          },
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

  Widget _buildItemNamesSuggestionField() {
    return CustomSearchField(
      enabled: !widget.isUpdate && !_isViewOnlyMode(),
      suggestionsCallback: (productName) async {
        final itemNames = await _itemSuggestionsService.fetchItemNames(
            productName: productName);

        if (itemNames == []) {
          _itemDescriptionsController.clear();
          _selectedItemName.value = '';
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

  Widget _buildQuantityCounterField() {
    return ValueListenableBuilder(
      valueListenable: _quantity,
      builder: (BuildContext context, int value, Widget? child) {
        return CustomFormTextField(
          label: '* Quantity',
          placeholderText: value.toString(),
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
                  if (value != 1) {
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
