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
import '../../../../core/common/components/custom_form_text_field.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/common/components/reusable_linear_progress_indicator.dart';
import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/ics_type.dart';
import '../../../../core/enums/issuance_type.dart';
import '../../../../core/services/entity_suggestions_service.dart';
import '../../../../core/services/officer_suggestions_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../../core/utils/fund_cluster_to_readable_string.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../../../../init_dependencies.dart';
import '../../../purchase_request/presentation/components/custom_search_field.dart';
import '../bloc/issuances_bloc.dart';
import '../components/accountable_officer_card.dart';
import '../components/add_receiving_officer_modal.dart';
import '../components/item_selection_modal.dart';

class RegisterMultipleIssuanceView extends StatefulWidget {
  const RegisterMultipleIssuanceView({
    super.key,
    required this.issuanceType,
  });

  final IssuanceType issuanceType;

  @override
  State<RegisterMultipleIssuanceView> createState() =>
      _RegisterMultipleIssuanceViewState();
}

class _RegisterMultipleIssuanceViewState
    extends State<RegisterMultipleIssuanceView> {
  late IssuancesBloc _issuancesBloc;
  late EntitySuggestionService _entitySuggestionService;
  late OfficerSuggestionsService _officerSuggestionsService;

  final _formKey = GlobalKey<FormState>();

  final _entityNameController = TextEditingController();
  final _divisionController = TextEditingController();
  final _officeNameController = TextEditingController();

  final _supplierNameController = TextEditingController();
  final _inspectionAndAcceptanceReportIdController = TextEditingController();
  final _contractNumberController = TextEditingController();
  final _purchaseOrderNumberController = TextEditingController();

  final _issuingOfficerOfficeNameController = TextEditingController();
  final _issuingOfficerPositionNameController = TextEditingController();
  final _issuingOfficerNameController = TextEditingController();

  final ValueNotifier<IcsType?> _selectedIcsType = ValueNotifier(null);
  final ValueNotifier<FundCluster?> _selectedFundCluster = ValueNotifier(null);
  final ValueNotifier<String?> _selectedIssuingOfficerOffice =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedIssuingOfficerPosition =
      ValueNotifier(null);

  final ValueNotifier<DateTime> _pickedDate = ValueNotifier(DateTime.now());

  final ValueNotifier<List<Map<String, dynamic>>> _officers = ValueNotifier([]);

  // Track global selected items
  final ValueNotifier<List<Map<String, dynamic>>> _globalSelectedItems =
      ValueNotifier([]);

  @override
  initState() {
    super.initState();
    _issuancesBloc = context.read<IssuancesBloc>();
    _entitySuggestionService = serviceLocator<EntitySuggestionService>();
    _officerSuggestionsService = serviceLocator<OfficerSuggestionsService>();
  }

  void _reorderOfficers(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    final updated = List<Map<String, dynamic>>.from(_officers.value);
    final moved = updated.removeAt(oldIndex);
    updated.insert(newIndex, moved);
    _officers.value = updated;
  }

  void _removeOfficer(int index) {
    final updated = List<Map<String, dynamic>>.from(_officers.value);
    updated.removeAt(index);
    _officers.value = updated;
  }

  void _removeOfficerItem(int officerIndex, int itemIndex) {
    final updated = List<Map<String, dynamic>>.from(_officers.value);
    final items =
        List<Map<String, dynamic>>.from(updated[officerIndex]['items']);
    items.removeAt(itemIndex);
    updated[officerIndex]['items'] = items;
    _officers.value = updated;
  }

  void _showAddItemModal(int officerIndex) {
    final currentOfficerItems = (_officers.value[officerIndex]['items'] as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    // Collect all assigned item IDs except for the current officer
    final assignedItemIds = _officers.value
        .asMap()
        .entries
        .where((entry) => entry.key != officerIndex)
        .expand((entry) => (entry.value['items'] as List)
            .map((e) => Map<String, dynamic>.from(e)))
        .map((item) => item['shareable_item_information']['base_item_id'])
        .toSet();

    // Also exclude items already selected for the current officer
    final currentOfficerItemIds = currentOfficerItems
        .map((item) => item['shareable_item_information']['base_item_id'])
        .toSet();

    final excludeItemIds = <dynamic>{
      ...assignedItemIds,
      ...currentOfficerItemIds
    };

    showDialog(
      context: context,
      builder: (context) => ItemSelectionModal(
        onSelectedItems: (List<Map<String, dynamic>>? selectedItems) {
          if (selectedItems == null) return;

          final updatedOfficers =
              List<Map<String, dynamic>>.from(_officers.value);
          updatedOfficers[officerIndex]
              ['items'] = [...currentOfficerItems, ...selectedItems];
          _officers.value = updatedOfficers;
        },
        preselectedItems: const [], // Always empty, since already-selected items are excluded
        excludeItemIds: excludeItemIds,
      ),
    );
  }

  void _saveIssuance() async {
    // Ensure each officer has at least 1 item
    final officersWithoutItems = _officers.value.where((officer) {
      final items = officer['items'] as List?;
      return items == null || items.isEmpty;
    }).toList();

    if (officersWithoutItems.isNotEmpty) {
      DelightfulToastUtils.showDelightfulToast(
        icon: Icons.error_outline,
        context: context,
        title: 'Issuance Error',
        subtitle: 'Each officer must have at least one item assigned.',
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (widget.issuanceType == IssuanceType.ics) {
        _issuancesBloc.add(
          CreateMultipleICSEvent(
            issuedDate: _pickedDate.value,
            type: _selectedIcsType.value,
            receivingOfficers: _officers.value,
            entityName: _entityNameController.text,
            fundCluster: _selectedFundCluster.value,
            supplierName: _supplierNameController.text,
            inspectionAndAcceptanceReportId:
                _inspectionAndAcceptanceReportIdController.text,
            contractNumber: _contractNumberController.text,
            purchaseOrderNumber: _purchaseOrderNumberController.text,
            issuingOfficerOffice: _issuingOfficerOfficeNameController.text,
            issuingOfficerPosition: _issuingOfficerPositionNameController.text,
            issuingOfficerName: _issuingOfficerNameController.text,
          ),
        );
      }

      if (widget.issuanceType == IssuanceType.par) {
        _issuancesBloc.add(
          CreateMultiplePAREvent(
            issuedDate: _pickedDate.value,
            receivingOfficers: _officers.value,
            entityName: _entityNameController.text,
            fundCluster: _selectedFundCluster.value,
            supplierName: _supplierNameController.text,
            inspectionAndAcceptanceReportId:
                _inspectionAndAcceptanceReportIdController.text,
            contractNumber: _contractNumberController.text,
            purchaseOrderNumber: _purchaseOrderNumberController.text,
            issuingOfficerOffice: _issuingOfficerOfficeNameController.text,
            issuingOfficerPosition: _issuingOfficerPositionNameController.text,
            issuingOfficerName: _issuingOfficerNameController.text,
          ),
        );
      }
    }
  }

  @override
  dispose() {
    _globalSelectedItems.dispose();
    _entityNameController.dispose();
    _divisionController.dispose();
    _officeNameController.dispose();

    _supplierNameController.dispose();
    _inspectionAndAcceptanceReportIdController.dispose();
    _contractNumberController.dispose();
    _purchaseOrderNumberController.dispose();

    _issuingOfficerOfficeNameController.dispose();
    _issuingOfficerPositionNameController.dispose();
    _issuingOfficerNameController.dispose();

    _selectedIcsType.dispose();
    _selectedFundCluster.dispose();

    _selectedIssuingOfficerOffice.dispose();
    _selectedIssuingOfficerPosition.dispose();

    _pickedDate.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<IssuancesBloc, IssuancesState>(
        listener: (context, state) async {
          if (state is MultipleICSRegistered) {
            DelightfulToastUtils.showDelightfulToast(
              icon: HugeIcons.strokeRoundedCheckmarkCircle02,
              context: context,
              title: 'Success',
              subtitle: '${state.icsItems.length} ICS created successfully.',
            );
            await Future.delayed(const Duration(seconds: 3));
            context.pop();
          }

          if (state is MultiplePARRegistered) {
            DelightfulToastUtils.showDelightfulToast(
              icon: HugeIcons.strokeRoundedCheckmarkCircle02,
              context: context,
              title: 'Success',
              subtitle: '${state.parItems.length} PAR created successfully.',
            );
            await Future.delayed(const Duration(seconds: 3));
            context.pop();
          }

          if (state is IssuancesError) {
            DelightfulToastUtils.showDelightfulToast(
              icon: Icons.error_outline,
              context: context,
              title: 'Error',
              subtitle: state.message,
            );
          }
        },
        child: BlocBuilder<IssuancesBloc, IssuancesState>(
          builder: (context, state) {
            return Column(
              children: [
                if (state is IssuancesLoading)
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
          _buildInitialInformationSection(),
          const SizedBox(
            height: 50.0,
          ),
          _buildRelatedOfficersSection(),
          const SizedBox(
            height: 50.0,
          ),
          if (widget.issuanceType != IssuanceType.ris)
            _buildAdditionalInformationSection(),
          const SizedBox(
            height: 50.0,
          ),
          _buildReceivingOfficersSection(),
          _buildActionsRow(),
        ],
      ),
    );
  }

  Widget _buildInitialInformationSection() {
    return Column(
      children: [
        if (widget.issuanceType == IssuanceType.ics)
          Row(
            children: [
              Expanded(
                child: _buildDateSelection(),
              ),
              const SizedBox(
                width: 20.0,
              ),
              Expanded(
                child: _buildIcsTypeSelection(),
              ),
            ],
          ),
        const SizedBox(
          height: 20.0,
        ),
        Row(
          spacing: 20.0,
          children: [
            Expanded(
              child: _buildEntitySuggestionField(),
            ),
            Expanded(
              child: _buildFundClusterSelection(),
            ),
            if (widget.issuanceType != IssuanceType.ics)
              Expanded(
                child: _buildDateSelection(),
              ),
          ],
        ),
        if (widget.issuanceType == IssuanceType.ris)
          Column(
            children: [
              const SizedBox(
                height: 20.0,
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomFormTextField(
                      label: 'Division',
                      controller: _divisionController,
                      placeholderText: 'Enter division',
                      fillColor:
                          (context.watch<ThemeBloc>().state == AppTheme.light
                              ? AppColor.lightCustomTextBox
                              : AppColor.darkCustomTextBox),
                    ),
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    child: _buildOfficeSuggestionField(),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildRelatedOfficersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '**🧑‍💼 Issuing Officer**',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          'Issuing officer involved to this issuance.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Row(
          spacing: 20.0,
          children: [
            Expanded(
              child: _buildIssuingOfficerOfficeSuggestionField(),
            ),
            Expanded(
              child: _buildIssuingOfficerPositionSuggestionField(),
            ),
            Expanded(
              child: _buildIssuingOfficerNameSuggestionField(),
            ),
          ],
        ),
        const SizedBox(
          height: 50.0,
        ),
      ],
    );
  }

  Widget _buildAdditionalInformationSection() {
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
          'Optional information to be included in the document.',
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
              child: CustomFormTextField(
                controller: _supplierNameController,
                label: 'Supplier Name',
                placeholderText: 'Enter supplier name',
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
                hasValidation: false,
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: CustomFormTextField(
                controller: _inspectionAndAcceptanceReportIdController,
                label: 'Inspection and Acceptance Report ID',
                placeholderText: 'Enter inspection and acceptance report ID',
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
                hasValidation: false,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            Expanded(
              child: CustomFormTextField(
                controller: _contractNumberController,
                label: 'Contract Number',
                placeholderText: 'Enter contract number',
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
                hasValidation: false,
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: CustomFormTextField(
                controller: _purchaseOrderNumberController,
                label: 'Purchase Order Number',
                placeholderText: 'Enter purchase order number',
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
                hasValidation: false,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 50.0,
        ),
      ],
    );
  }

  Widget _buildReceivingOfficersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              children: [
                Text(
                  '**👨‍💼 Accountable Officers**',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Text(
                  'Accountable officers involved to this issuance.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ],
            ),
            CustomFilledButton(
              text: 'Add Accountable',
              onTap: () async {
                final newOfficer = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (context) => const AddReceivingOfficerModal(),
                );
                if (newOfficer != null) {
                  _officers.value = [..._officers.value, newOfficer];
                }
              },
              width: 150.0,
              height: 40.0,
            ),
          ],
        ),
        const SizedBox(
          height: 20.0,
        ),
        ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: _officers,
          builder: (context, value, _) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(value.length, (index) {
                  return DragTarget<int>(
                    onAccept: (fromIndex) => _reorderOfficers(fromIndex, index),
                    builder: (context, candidateData, rejectedData) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Draggable<int>(
                          data: index,
                          feedback: SizedBox(
                            width: 250.0,
                            child: Material(
                              color: Colors.transparent,
                              child: AccountableOfficerCard(
                                officer: value[index],
                                isDragging: true,
                                onRemoveItem:
                                    null, // No remove in drag feedback
                              ),
                            ),
                          ),
                          childWhenDragging: const SizedBox(
                            width: 250.0,
                          ),
                          child: SizedBox(
                            width: 250,
                            child: AccountableOfficerCard(
                              officer: value[index],
                              onRemove: () => _removeOfficer(index),
                              onAddItem: () => _showAddItemModal(index),
                              onRemoveItem: (itemIdx) =>
                                  _removeOfficerItem(index, itemIdx),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            );
          },
        ),
      ],
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
          label: 'Issued Date',
          dateController: dateController,
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        );
      },
    );
  }

  Widget _buildIcsTypeSelection() {
    return ValueListenableBuilder(
      valueListenable: _selectedIcsType,
      builder: (context, selectedIcsType, child) {
        return CustomDropdownField(
          //value: selectedIcsType.toString(),
          onChanged: (value) {
            if (value != null && value.isNotEmpty) {
              _selectedIcsType.value = IcsType.values.firstWhere(
                  (e) => e.toString().split('.').last == value.split('.').last);
            }
          },
          items: IcsType.values
              .map(
                (type) => DropdownMenuItem(
                  value: type.toString(),
                  child: Text(
                    readableEnumConverter(type).toUpperCase(),
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
          label: 'Type',
          placeholderText: 'Enter ICS\'s type',
        );
      },
    );
  }

  Widget _buildOfficeSuggestionField() {
    return CustomSearchField(
      suggestionsCallback: (officeName) async {
        return await _officerSuggestionsService.fetchOffices(
          // page: currentPage,
          officeName: officeName,
        );
      },
      onSelected: (value) {
        _officeNameController.text = value;
      },
      controller: _officeNameController,
      label: 'Office',
      placeHolderText: 'Enter office',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
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
      placeHolderText: 'Enter entity',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildFundClusterSelection() {
    return ValueListenableBuilder(
      valueListenable: _selectedFundCluster,
      builder: (context, selectedFundCluster, child) {
        return CustomDropdownField<FundCluster>(
          value: selectedFundCluster,
          onChanged: (value) => _selectedFundCluster.value = value,
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
        );
      },
    );
  }

  Widget _buildIssuingOfficerOfficeSuggestionField() {
    return CustomSearchField(
      suggestionsCallback: (officeName) async {
        final offices = await _officerSuggestionsService.fetchOffices(
          officeName: officeName,
        );

        if (offices == null) {
          _issuingOfficerPositionNameController.clear();
          _issuingOfficerNameController.clear();

          _selectedIssuingOfficerOffice.value = null;
          _selectedIssuingOfficerPosition.value = null;
        }

        return offices;
      },
      onSelected: (value) {
        _issuingOfficerOfficeNameController.text = value;
        _issuingOfficerPositionNameController.clear();
        _issuingOfficerNameController.clear();

        _selectedIssuingOfficerOffice.value = value;
        _selectedIssuingOfficerPosition.value = null;
      },
      controller: _issuingOfficerOfficeNameController,
      label: 'Issuing Officer Office',
      placeHolderText: 'Enter issuing officer\'s office',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildIssuingOfficerPositionSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedIssuingOfficerOffice,
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
                _issuingOfficerNameController.clear();
                _selectedIssuingOfficerPosition.value = null;
              }

              return positions;
            }
            return null;
          },
          onSelected: (value) {
            _issuingOfficerPositionNameController.text = value;
            _issuingOfficerNameController.clear();
            _selectedIssuingOfficerPosition.value = value;
          },
          controller: _issuingOfficerPositionNameController,
          label: 'Issuing Officer Position',
          placeHolderText: 'Enter issuing officer\'s position',
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        );
      },
    );
  }

  Widget _buildIssuingOfficerNameSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedIssuingOfficerOffice,
      builder: (context, selectedOfficeName, child) {
        return ValueListenableBuilder(
          valueListenable: _selectedIssuingOfficerPosition,
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
                _issuingOfficerNameController.text = value;
              },
              controller: _issuingOfficerNameController,
              label: 'Issuing Officer Name',
              placeHolderText: 'Enter issuing officer\'s name',
              fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                  ? AppColor.lightCustomTextBox
                  : AppColor.darkCustomTextBox),
            );
          },
        );
      },
    );
  }

  //Widget _buildReceivingOfficers

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
          onTap: _saveIssuance,
          text: 'Create',
          width: 180.0,
          height: 40.0,
        ),
      ],
    );
  }
}
