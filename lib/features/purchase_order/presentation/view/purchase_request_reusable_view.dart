import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';
import '../../../../core/common/components/custom_date_picker.dart';
import '../../../../core/common/components/custom_dropdown_field.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/common/components/reusable_linear_progress_indicator.dart';
import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/unit.dart';
import '../../../../core/services/entity_suggestions_service.dart';
import '../../../../core/services/item_suggestions_service.dart';
import '../../../../core/services/officer_suggestions_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../../../../core/common/components/custom_form_text_field.dart';
import '../../../../init_dependencies.dart';
import '../bloc/purchase_requests_bloc.dart';
import '../components/custom_search_field.dart';

class PurchaseRequestReusableView extends StatefulWidget {
  const PurchaseRequestReusableView({super.key});

  @override
  State<PurchaseRequestReusableView> createState() =>
      _PurchaseRequestReusableViewState();
}

class _PurchaseRequestReusableViewState
    extends State<PurchaseRequestReusableView> {
  late EntitySuggestionService _entitySuggestionService;
  late ItemSuggestionsService _itemSuggestionsService;
  late OfficerSuggestionsService _officerSuggestionsService;

  final _formKey = GlobalKey<FormState>();

  final _prIdController = TextEditingController();
  final _officeController = TextEditingController();
  final _dateController = TextEditingController();
  final _entityNameController = TextEditingController();
  final _purposeController = TextEditingController();

  final _itemNameController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitCostController = TextEditingController();

  final _requestingOfficerOfficeController = TextEditingController();
  final _requestingOfficerPositionController = TextEditingController();
  final _requestingOfficerNameController = TextEditingController();

  final _approvingOfficerOfficeController = TextEditingController();
  final _approvingOfficerPositionController = TextEditingController();
  final _approvingOfficerNameController = TextEditingController();

  final ValueNotifier<FundCluster?> _selectedFundCluster = ValueNotifier(null);
  final ValueNotifier<String?> _selectedItemName = ValueNotifier(null);
  final ValueNotifier<Unit?> _selectedUnit = ValueNotifier(null);
  final ValueNotifier<int> _quantity = ValueNotifier(0);
  final ValueNotifier<String?> _selectedRequestingOfficerOffice =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedRequestingOfficerPosition =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedApprovingOfficerOffice =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedApprovingOfficerPosition =
      ValueNotifier(null);

  final ValueNotifier<DateTime> _pickedDate = ValueNotifier(DateTime.now());

  @override
  void initState() {
    super.initState();
    _entitySuggestionService = serviceLocator<EntitySuggestionService>();
    _itemSuggestionsService = serviceLocator<ItemSuggestionsService>();
    _officerSuggestionsService = serviceLocator<OfficerSuggestionsService>();
    //_officeScrollController.addListener(_loadMoreOffices);

    _quantityController.addListener(() {
      final newQuantity = int.tryParse(_quantityController.text) ?? 0;
      _quantity.value = newQuantity;
    });

    _quantity.addListener(() {
      _quantityController.text = _quantity.value.toString();
    });
  }

  void _savePurchaseRequest() {
    if (_formKey.currentState!.validate()) {
      context.read<PurchaseRequestsBloc>().add(
            RegisterPurchaseRequestEvent(
              entityName: _entityNameController.text,
              fundCluster: _selectedFundCluster.value!,
              officeName: _officeController.text,
              date: _pickedDate.value,
              productName: _itemNameController.text,
              productDescription: _itemDescriptionController.text,
              unit: _selectedUnit.value!,
              quantity: int.parse(_quantityController.text),
              unitCost: double.parse(_unitCostController.text),
              purpose: _purposeController.text,
              requestingOfficerOffice: _requestingOfficerOfficeController.text,
              requestingOfficerPosition:
                  _requestingOfficerPositionController.text,
              requestingOfficerName: _requestingOfficerNameController.text,
              approvingOfficerOffice: _approvingOfficerOfficeController.text,
              approvingOfficerPosition:
                  _approvingOfficerPositionController.text,
              approvingOfficerName: _approvingOfficerNameController.text,
            ),
          );
    }
  }

  @override
  void dispose() {
    _prIdController.dispose();
    _officeController.dispose();
    _dateController.dispose();
    _entityNameController.dispose();
    _purposeController.dispose();

    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _quantityController.dispose();
    _unitCostController.dispose();

    _requestingOfficerOfficeController.dispose();
    _requestingOfficerPositionController.dispose();
    _requestingOfficerNameController.dispose();

    _approvingOfficerOfficeController.dispose();
    _approvingOfficerPositionController.dispose();
    _approvingOfficerNameController.dispose();

    _selectedFundCluster.dispose();
    _selectedItemName.dispose();
    _selectedUnit.dispose();
    _quantity.dispose();
    _selectedRequestingOfficerOffice.dispose();
    _selectedRequestingOfficerPosition.dispose();
    _selectedApprovingOfficerOffice.dispose();
    _selectedApprovingOfficerPosition.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<PurchaseRequestsBloc, PurchaseRequestsState>(
        listener: (context, state) async {
          if (state is PurchaseRequestRegistered) {
            print('triggered');
            DelightfulToastUtils.showDelightfulToast(
              icon: HugeIcons.strokeRoundedCheckmarkCircle02,
              context: context,
              title: 'Success',
              subtitle: 'Purchase Request registered successfully.',
            );
            await Future.delayed(const Duration(seconds: 3));
            context.pop();
          }

          if (state is PurchaseRequestsError) {
            DelightfulToastUtils.showDelightfulToast(
              icon: HugeIcons.strokeRoundedCheckmarkCircle02,
              context: context,
              title: 'Error',
              subtitle:
                  'Failed to register Purchase Request: ${state.message}.',
            );
          }
        },
        child: BlocBuilder<PurchaseRequestsBloc, PurchaseRequestsState>(
          builder: (context, state) {
            return Column(
              children: [
                if (state is PurchaseRequestsLoading)
                  const ReusableLinearProgressIndicator(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 30.0,
                      ),
                      child: _buildForm(),
                    ),
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
      child: Column(
        children: [
          // _buildHeader(),
          // const SizedBox(
          //   height: 50.0,
          // ),
          _buildPurchaseRequestInitialInformationFields(),
          const SizedBox(
            height: 50.0,
          ),
          _buildItemInformationFields(),
          const SizedBox(
            height: 50.0,
          ),
          _buildRequestingOfficerInformationFields(),
          const SizedBox(
            height: 50.0,
          ),
          _buildApprovingOfficerInformationFields(),
          const SizedBox(
            height: 80.0,
          ),
          _buildActionsRow(),
        ],
      ),
    );
  }

  // Widget _buildHeader() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Text(
  //         'Purchase Request',
  //         style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //               fontSize: 18.0,
  //               fontWeight: FontWeight.w600,
  //             ),
  //       ),
  //       IconButton(
  //         onPressed: () => context.pop(),
  //         icon: const Icon(
  //           HugeIcons.strokeRoundedCancel01,
  //           size: 20.0,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildPurchaseRequestInitialInformationFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Purchase Request',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          'Initial information for the request.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
        ),
        // Divider(
        //   color: Theme.of(context).dividerColor,
        //   thickness: 2.5,
        // ),
        const SizedBox(
          height: 20.0,
        ),
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Expanded(
              //   child: CustomFormTextField(
              //     label: 'PR No.',
              //     controller: _prIdController,
              //   ),
              // ),
              // const SizedBox(
              //   width: 50.0,
              // ),
              Expanded(
                child: _buildOfficeSuggestionField(),
              ),
              const SizedBox(
                width: 50.0,
              ),
              Expanded(
                child: _buildDateSelection(),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 15.0,
        ),
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildEntitySuggestionField(),
              ),
              const SizedBox(
                width: 50.0,
              ),
              Expanded(
                child: _buildFundClusterSelection(),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 15.0,
        ),
        CustomFormTextField(
          label: 'Purpose',
          controller: _purposeController,
          maxLines: 4,
          placeholderText: 'Enter request\'s purpose',
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        ),
      ],
    );
  }

  Widget _buildItemInformationFields() {
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
          'Requested Item Information.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
        ),
        const SizedBox(
          height: 15.0,
        ),
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
                  label: 'Unit Cost',
                  controller: _unitCostController,
                  placeholderText: 'Enter item\'s unit cost',
                  fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                      ? AppColor.lightCustomTextBox
                      : AppColor.darkCustomTextBox),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequestingOfficerInformationFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Associated Officers',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          'Officers involved with the request.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildRequestingOfficerOfficeSuggestionField(),
              ),
              const SizedBox(
                width: 50.0,
              ),
              Expanded(
                child: _buildRequestingOfficerPositionSuggestionField(),
              ),
              const SizedBox(
                width: 50.0,
              ),
              Expanded(child: _buildRequestingOfficerNameSuggestionField()),
            ],
          ),
        ),
      ],
    );
  }

  // todo loading, bloc, etc...
  Widget _buildApprovingOfficerInformationFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildApprovingOfficerOfficeSuggestionField(),
              ),
              const SizedBox(
                width: 50.0,
              ),
              Expanded(
                child: _buildApprovingOfficerPositionSuggestionField(),
              ),
              const SizedBox(
                width: 50.0,
              ),
              Expanded(
                child: _buildApprovingOfficerNameSuggestionField(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // final _officeScrollController = ScrollController();
  // final ValueNotifier<int> _currentOfficePage = ValueNotifier(1);
  //
  // Future<void> _loadMoreOffices() async {
  //   if (_officeScrollController.position.pixels == _officeScrollController.position.maxScrollExtent) {
  //     print('triggered!');
  //     _currentOfficePage.value++;
  //   }
  // }

  // Widget _buildOfficeSuggestionField() {
  //   return ValueListenableBuilder(
  //     valueListenable: _currentOfficePage,
  //     builder: (context, currentPage, child) {
  //       return CustomSearchField(
  //         suggestionsCallback: (officeName) async {
  //           return await _officerSuggestionsService.fetchOffices(
  //             page: currentPage,
  //             officeName: officeName,
  //           );
  //         },
  //         onSelected: (value) {
  //           _officeController.text = value;
  //         },
  //         controller: _officeController,
  //         label: 'Office',
  //         scrollController: _officeScrollController,
  //       );
  //     }
  //   );
  // }

  Widget _buildOfficeSuggestionField() {
    return CustomSearchField(
      suggestionsCallback: (officeName) async {
        return await _officerSuggestionsService.fetchOffices(
          // page: currentPage,
          officeName: officeName,
        );
      },
      onSelected: (value) {
        _officeController.text = value;
      },
      controller: _officeController,
      label: 'Office',
      placeHolderText: 'Enter purchase request\'s office',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildDateSelection() {
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
          label: 'Date',
          dateController: dateController,
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        );
      },
    );
  }

  Widget _buildEntitySuggestionField() {
    return CustomSearchField(
      suggestionsCallback: (entityName) async {
        final entityNames = await _entitySuggestionService.fetchEntities(
          entityName: entityName,
        );

        return entityNames;
      },
      onSelected: (value) {
        _entityNameController.text = value;
      },
      controller: _entityNameController,
      label: 'Entity',
      placeHolderText: 'Enter purchase request\'s entity',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildFundClusterSelection() {
    return ValueListenableBuilder(
      valueListenable: _selectedFundCluster,
      builder: (context, selectedFundCluster, child) {
        return CustomDropdownField(
          //value: selectedFundCluster.toString(),
          onChanged: (value) {
            if (value != null && value.isNotEmpty) {
              _selectedFundCluster.value = FundCluster.values.firstWhere(
                  (e) => e.toString().split('.').last == value.split('.').last);
            }
          },
          items: FundCluster.values
              .map(
                (fundCluster) => DropdownMenuItem(
                  value: fundCluster.toString(),
                  child: Text(
                    readableEnumConverter(fundCluster),
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
          label: 'Fund Cluster',
          placeholderText: 'Enter purchase request\'s fund cluster',
        );
      },
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
      label: 'Product Name',
      placeHolderText: 'Enter product name',
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
          label: 'Product Description',
          placeHolderText: 'Enter product description',
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
          label: 'Quantity',
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

  Widget _buildRequestingOfficerOfficeSuggestionField() {
    return CustomSearchField(
      suggestionsCallback: (officeName) async {
        final offices = await _officerSuggestionsService.fetchOffices(
          officeName: officeName,
        );

        if (offices == null) {
          _requestingOfficerPositionController.clear();
          _requestingOfficerNameController.clear();

          _selectedRequestingOfficerOffice.value = null;
          _selectedRequestingOfficerPosition.value = null;
        }

        return offices;
      },
      onSelected: (value) {
        _requestingOfficerOfficeController.text = value;
        _requestingOfficerPositionController.clear();
        _requestingOfficerNameController.clear();

        _selectedRequestingOfficerOffice.value = value;
        _selectedRequestingOfficerPosition.value = null;
      },
      controller: _requestingOfficerOfficeController,
      label: 'Requesting Officer Office',
      placeHolderText: 'Enter requesting officer\'s office',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildApprovingOfficerOfficeSuggestionField() {
    return CustomSearchField(
      suggestionsCallback: (officeName) async {
        final offices = await _officerSuggestionsService.fetchOffices(
          officeName: officeName,
        );

        if (offices == null) {
          _approvingOfficerPositionController.clear();
          _approvingOfficerNameController.clear();

          _selectedApprovingOfficerOffice.value = null;
          _selectedApprovingOfficerPosition.value = null;
        }

        return offices;
      },
      onSelected: (value) {
        _approvingOfficerOfficeController.text = value;
        _approvingOfficerPositionController.clear();
        _approvingOfficerNameController.clear();

        _selectedApprovingOfficerOffice.value = value;
        _selectedApprovingOfficerPosition.value = null;
      },
      controller: _approvingOfficerOfficeController,
      label: 'Approving Officer Office',
      placeHolderText: 'Enter approving officer\'s office',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildRequestingOfficerPositionSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedRequestingOfficerOffice,
      builder: (context, selectedOfficeName, child) {
        return CustomSearchField(
          key: ValueKey(selectedOfficeName),
          suggestionsCallback: (String? positionName) async {
            if (selectedOfficeName != null && selectedOfficeName.isNotEmpty) {
              final positions =
                  await _officerSuggestionsService.fetchOfficePositions(
                officeName: selectedOfficeName,
                positionName: positionName,
              );

              if (positions == null) {
                _requestingOfficerNameController.clear();
                _selectedRequestingOfficerPosition.value = null;
              }

              return positions;
            }
            return null;
          },
          onSelected: (value) {
            _requestingOfficerPositionController.text = value;
            _requestingOfficerNameController.clear();
            _selectedRequestingOfficerPosition.value = value;
          },
          controller: _requestingOfficerPositionController,
          label: 'Requesting Officer Position',
          placeHolderText: 'Enter requesting officer\'s position',
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        );
      },
    );
  }

  Widget _buildApprovingOfficerPositionSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedApprovingOfficerOffice,
      builder: (context, selectedOfficeName, child) {
        return CustomSearchField(
          key: ValueKey(selectedOfficeName),
          suggestionsCallback: (String? positionName) async {
            if (selectedOfficeName != null && selectedOfficeName.isNotEmpty) {
              final positions =
                  await _officerSuggestionsService.fetchOfficePositions(
                officeName: selectedOfficeName,
                positionName: positionName,
              );

              if (positions == null) {
                _approvingOfficerNameController.clear();
                _selectedApprovingOfficerPosition.value = null;
              }

              return positions;
            }
            return null;
          },
          onSelected: (value) {
            _approvingOfficerPositionController.text = value;
            _approvingOfficerNameController.clear();
            _selectedApprovingOfficerPosition.value = value;
          },
          controller: _approvingOfficerPositionController,
          label: 'Approving Officer Position',
          placeHolderText: 'Enter approving officer\'s position',
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        );
      },
    );
  }

  Widget _buildRequestingOfficerNameSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedRequestingOfficerOffice,
      builder: (context, selectedOfficeName, child) {
        return ValueListenableBuilder(
          valueListenable: _selectedRequestingOfficerPosition,
          builder: (context, selectedPositionName, child) {
            return CustomSearchField(
              key: ValueKey('$selectedOfficeName-$selectedPositionName'),
              suggestionsCallback: (String? officerName) async {
                if ((selectedOfficeName != null &&
                        selectedOfficeName.isNotEmpty) &&
                    (selectedPositionName != null &&
                        selectedPositionName.isNotEmpty)) {
                  final officers =
                      await _officerSuggestionsService.fetchOfficers(
                    officeName: selectedOfficeName,
                    positionName: selectedPositionName,
                    officerName: officerName,
                  );

                  return officers;
                }
                return null;
              },
              onSelected: (value) {
                _requestingOfficerNameController.text = value;
              },
              controller: _requestingOfficerNameController,
              label: 'Requesting Officer Name',
              placeHolderText: 'Enter requesting officer\'s name',
              fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                  ? AppColor.lightCustomTextBox
                  : AppColor.darkCustomTextBox),
            );
          },
        );
      },
    );
  }

  Widget _buildApprovingOfficerNameSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedApprovingOfficerOffice,
      builder: (context, selectedOfficeName, child) {
        return ValueListenableBuilder(
          valueListenable: _selectedApprovingOfficerPosition,
          builder: (context, selectedPositionName, child) {
            return CustomSearchField(
              key: ValueKey('$selectedOfficeName-$selectedPositionName'),
              suggestionsCallback: (String? officerName) async {
                if ((selectedOfficeName != null &&
                        selectedOfficeName.isNotEmpty) &&
                    (selectedPositionName != null &&
                        selectedPositionName.isNotEmpty)) {
                  final officers =
                      await _officerSuggestionsService.fetchOfficers(
                    officeName: selectedOfficeName,
                    positionName: selectedPositionName,
                    officerName: officerName,
                  );

                  return officers;
                }
                return null;
              },
              onSelected: (value) {
                _approvingOfficerNameController.text = value;
              },
              controller: _approvingOfficerNameController,
              label: 'Approving Officer Name',
              placeHolderText: 'Enter approving officer\'s name',
              fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                  ? AppColor.lightCustomTextBox
                  : AppColor.darkCustomTextBox),
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
          height: 40.0,
        ),
        const SizedBox(
          width: 10.0,
        ),
        CustomFilledButton(
          onTap: () {
            _savePurchaseRequest();
          },
          text: 'Save',
          width: 180.0,
          height: 40.0,
        ),
      ],
    );
  }
}
