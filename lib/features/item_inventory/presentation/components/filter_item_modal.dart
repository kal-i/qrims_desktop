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
import '../../../../core/utils/readable_enum_converter.dart';
import '../../../../init_dependencies.dart';
import '../../../purchase_request/presentation/components/custom_search_field.dart';

class FilterItemModal extends StatefulWidget {
  const FilterItemModal({
    super.key,
    required this.onApplyFilters,
    this.selectedManufacturer,
    this.selectedBrand,
    this.selectedClassificationFilter,
    this.selectedSubClassFilter,
  });

  final Function(
    String? manufacturer,
    String? brand,
    AssetClassification? assetClassification,
    AssetSubClass? assetSubClass,
  ) onApplyFilters;
  final String? selectedManufacturer;
  final String? selectedBrand;
  final AssetClassification? selectedClassificationFilter;
  final AssetSubClass? selectedSubClassFilter;

  @override
  State<FilterItemModal> createState() => _FilterItemModalState();
}

class _FilterItemModalState extends State<FilterItemModal> {
  late ItemSuggestionsService _itemSuggestionsService;
  late String? _selectedManufacturerFilter;
  late String? _selectedBrandFilter;
  late AssetClassification? _selectedClassificationFilter;
  late AssetSubClass? _selectedSubClassFilter;

  final _manufacturerController = TextEditingController();
  final _brandController = TextEditingController();
  final _assetClassificationController = TextEditingController();
  final _assetSubClassController = TextEditingController();

  final ValueNotifier<String?> _selectedManufacturer = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _itemSuggestionsService = serviceLocator<ItemSuggestionsService>();

    // Initialize with the passed filter values
    _selectedManufacturerFilter = widget.selectedManufacturer;
    _selectedBrandFilter = widget.selectedBrand;
    _selectedClassificationFilter = widget.selectedClassificationFilter;
    _selectedSubClassFilter = widget.selectedSubClassFilter;

    // Set the controllers to show the selected values
    _manufacturerController.text =
        _selectedManufacturerFilter != null ? _selectedManufacturerFilter! : '';
    _brandController.text =
        _selectedBrandFilter != null ? _selectedBrandFilter! : '';
    _assetClassificationController.text = _selectedClassificationFilter != null
        ? readableEnumConverter(_selectedClassificationFilter!)
        : '';
    _assetSubClassController.text = _selectedSubClassFilter != null
        ? readableEnumConverter(_selectedSubClassFilter!)
        : '';
  }

  List<String> _assetClassificationSuggestionCallback(
      String? assetClassification) {
    final assetClassifications = AssetClassification.values
        .map((classification) => readableEnumConverter(classification))
        .toList();

    if (assetClassification != null && assetClassification.isNotEmpty) {
      final filteredClassifications =
          assetClassifications.where((classification) {
        return classification
            .toLowerCase()
            .contains(assetClassification.toLowerCase());
      }).toList();

      return filteredClassifications;
    }
    return assetClassifications;
  }

  List<String> _assetSubClassSuggestionCallback(String? assetSubClass) {
    final assetSubClasses = AssetSubClass.values
        .map((subClass) => readableEnumConverter(subClass))
        .toList();

    if (assetSubClass != null && assetSubClass.isNotEmpty) {
      final filteredSubClass = assetSubClasses.where((subClass) {
        return subClass.toLowerCase().contains(assetSubClass.toLowerCase());
      }).toList();

      return filteredSubClass;
    }
    return assetSubClasses;
  }

  void _onAssetClassificationSelected(String value) {
    _assetClassificationController.text = value;
    _selectedClassificationFilter = AssetClassification.values.firstWhere(
        (assetClassification) =>
            readableEnumConverter(assetClassification) == value);
  }

  void _onAssetSubClassSelected(String value) {
    _assetSubClassController.text = value;
    _selectedSubClassFilter = AssetSubClass.values.firstWhere(
        (assetSubClass) => readableEnumConverter(assetSubClass) == value);
  }

  @override
  void dispose() {
    _selectedManufacturer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      width: 900.0,
      height: 600.0,
      headerTitle: 'Filter Item',
      subtitle: 'Filter items by the following parameters.',
      content: _buildFilterContents(),
      footer: _buildActionsRow(),
    );
  }

  Widget _buildFilterContents() {
    return Column(
      children: [
        _buildItemManufacturersSuggestionField(),
        const SizedBox(
          height: 20.0,
        ),
        _buildItemBrandsSuggestionField(),
        const SizedBox(
          height: 20.0,
        ),
        _buildAssetClassificationsSuggestionField(),
        const SizedBox(
          height: 20.0,
        ),
        _buildAssetSubClassesSuggestionField(),
      ],
    );
  }

  Widget _buildItemManufacturersSuggestionField() {
    return CustomSearchField(
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
        _selectedManufacturerFilter = value;

        _brandController.clear();
        _selectedManufacturer.value = value;
      },
      controller: _manufacturerController,
      label: 'Manufacturer',
      placeHolderText: 'Enter manufacturer name',
    );
  }

  Widget _buildItemBrandsSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedManufacturer,
      builder: (context, selectedManufacturer, child) {
        return CustomSearchField(
          key: ValueKey(selectedManufacturer),
          suggestionsCallback: (brandName) async {
            if (selectedManufacturer != null &&
                selectedManufacturer.isNotEmpty) {
              final brandNames = await _itemSuggestionsService.fetchBrands(
                  manufacturerName: selectedManufacturer, brandName: brandName);

              return brandNames;
            } else {
              return Future.value([]);
            }
          },
          onSelected: (value) {
            _selectedBrandFilter = value;
            _brandController.text = value;
          },
          controller: _brandController,
          label: 'Brand',
          placeHolderText: 'Enter brand name',
        );
      },
    );
  }

  Widget _buildAssetClassificationsSuggestionField() {
    return CustomSearchField(
      suggestionsCallback: _assetClassificationSuggestionCallback,
      onSelected: _onAssetClassificationSelected,
      controller: _assetClassificationController,
      label: 'Asset Classification',
      placeHolderText: 'Select Asset Classification',
    );
  }

  Widget _buildAssetSubClassesSuggestionField() {
    return CustomSearchField(
      suggestionsCallback: _assetSubClassSuggestionCallback,
      onSelected: _onAssetSubClassSelected,
      controller: _assetSubClassController,
      label: 'Asset Sub Class',
      placeHolderText: 'Select Asset Sub Class',
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
            widget.onApplyFilters(
              _selectedManufacturerFilter,
              _selectedBrandFilter,
              _selectedClassificationFilter,
              _selectedSubClassFilter,
            );
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
