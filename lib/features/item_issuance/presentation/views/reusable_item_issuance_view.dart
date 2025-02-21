import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';
import '../../../../core/common/components/custom_data_table.dart';
import '../../../../core/common/components/custom_date_picker.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_form_text_field.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/common/components/reusable_linear_progress_indicator.dart';
import '../../../../core/enums/issuance_purpose.dart';
import '../../../../core/enums/issuance_type.dart';
import '../../../../core/services/officer_suggestions_service.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../../core/utils/document_date_formatter.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../../../../core/utils/show_confirmation_dialog.dart';
import '../../../../init_dependencies.dart';
import '../../../purchase_request/presentation/components/custom_search_field.dart';
import '../bloc/issuances_bloc.dart';
import '../components/item_selection_modal.dart';

/// todo: add a manual search option if no items found
class ReusableItemIssuanceView extends StatefulWidget {
  const ReusableItemIssuanceView({
    super.key,
    required this.issuancePurpose,
    required this.issuanceType,
    required this.prId,
  });

  final IssuancePurpose issuancePurpose;
  final IssuanceType issuanceType;
  final String prId;

  @override
  State<ReusableItemIssuanceView> createState() =>
      _ReusableItemIssuanceViewState();
}

class _ReusableItemIssuanceViewState extends State<ReusableItemIssuanceView> {
  late IssuancesBloc _issuancesBloc;
  late OfficerSuggestionsService _officerSuggestionsService;

  final _formKey = GlobalKey<FormState>();

  final _prIdController = TextEditingController();
  final _prDateController = TextEditingController();
  final _prStatusController = TextEditingController();
  final _requestingOfficerController = TextEditingController();
  final _approvingOfficerController = TextEditingController();

  final _receivingOfficerOfficeNameController = TextEditingController();
  final _receivingOfficerPositionNameController = TextEditingController();
  final _receivingOfficerNameController = TextEditingController();

  final _sendingOfficerOfficeNameController = TextEditingController();
  final _sendingOfficerPositionNameController = TextEditingController();
  final _sendingOfficerNameController = TextEditingController();

  final _purposeController = TextEditingController();
  final _responsibilityCenterCode = TextEditingController();

  final _approvingOfficerOfficeNameController = TextEditingController();
  final _approvingOfficerPositionNameController = TextEditingController();
  final _approvingOfficerNameController = TextEditingController();

  final _issuingOfficerOfficeNameController = TextEditingController();
  final _issuingOfficerPositionNameController = TextEditingController();
  final _issuingOfficerNameController = TextEditingController();

  final ValueNotifier<String?> _selectedReceivingOfficerOffice =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedReceivingOfficerPosition =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedSendingOfficerOffice =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedSendingOfficerPosition =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedApprovingOfficerOffice =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedApprovingOfficerPosition =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedIssuingOfficerOffice =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedIssuingOfficerPosition =
      ValueNotifier(null);
  final ValueNotifier<DateTime> _pickedDate = ValueNotifier(DateTime.now());

  late TableConfig _prTableConfig;
  late TableConfig _issuedTableConfig;

  final List<String> _prTableHeaders = [
    'Item Name',
    'Description',
    'Requested Quantity',
    'Remaining Quantity',
    'Status',
  ];
  final List<String> _issuedTableHeaders = [
    'Item Id',
    'Inventory Quantity',
    'Issue Quantity',
  ];

  late List<TableData> _prTableRows;
  final ValueNotifier<List<TableData>> _issuedTableRows = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _issuancesBloc = context.read<IssuancesBloc>();
    _officerSuggestionsService = serviceLocator<OfficerSuggestionsService>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _issuancesBloc.add(
        MatchItemWithPrEvent(
          prId: widget.prId,
        ),
      );
    });

    _prTableRows = [];
    _initializeTableConfig();
  }

  void _initializeTableConfig() {
    _prTableConfig = TableConfig(
      headers: _prTableHeaders,
      rows: _prTableRows,
      columnFlex: [
        1,
        2,
        1,
        1,
        1,
      ],
    );

    _issuedTableConfig = TableConfig(
      headers: _issuedTableHeaders,
      rows: _issuedTableRows.value,
      columnFlex: [
        2,
        1,
        1,
      ],
    );
  }

  void _saveIssuance() async {
    if (_issuedTableRows.value.isEmpty) {
      DelightfulToastUtils.showDelightfulToast(
        context: context,
        icon: Icons.error_outline,
        title: 'Error',
        subtitle: 'Item(s) to issue cannot be empty.',
      );
      return;
    }

    final shouldProceed = await showConfirmationDialog(
      context: context,
      confirmationTitle: 'Register Issuance',
      confirmationMessage: 'Are you sure you want to register the issuance?',
    );

    if (shouldProceed) {
      if (widget.issuanceType == IssuanceType.ics) {
        _issuancesBloc.add(
          CreateICSEvent(
            prId: _prIdController.text,
            issuanceItems: (_issuedTableRows.value)
                .map((issuedTableRow) =>
                    issuedTableRow.object as Map<String, dynamic>)
                .toList(),
            receivingOfficerOffice: _receivingOfficerOfficeNameController.text,
            receivingOfficerPosition:
                _receivingOfficerPositionNameController.text,
            receivingOfficerName: _receivingOfficerNameController.text,
            sendingOfficerOffice: _sendingOfficerOfficeNameController.text,
            sendingOfficerPosition: _sendingOfficerPositionNameController.text,
            sendingOfficerName: _sendingOfficerNameController.text,
          ),
        );
      }

      if (widget.issuanceType == IssuanceType.par) {
        _issuancesBloc.add(
          CreatePAREvent(
            prId: _prIdController.text,
            issuanceItems: (_issuedTableRows.value)
                .map((issuedTableRow) =>
                    issuedTableRow.object as Map<String, dynamic>)
                .toList(),
            receivingOfficerOffice: _receivingOfficerOfficeNameController.text,
            receivingOfficerPosition:
                _receivingOfficerPositionNameController.text,
            receivingOfficerName: _receivingOfficerNameController.text,
            sendingOfficerOffice: _sendingOfficerOfficeNameController.text,
            sendingOfficerPosition: _sendingOfficerPositionNameController.text,
            sendingOfficerName: _sendingOfficerNameController.text,
          ),
        );
      }

      if (widget.issuanceType == IssuanceType.ris) {
        _issuancesBloc.add(
          CreateRISEvent(
            prId: _prIdController.text,
            issuanceItems: (_issuedTableRows.value)
                .map((issuedTableRow) =>
                    issuedTableRow.object as Map<String, dynamic>)
                .toList(),
            purpose: _purposeController.text,
            responsibilityCenterCode: _responsibilityCenterCode.text,
            receivingOfficerOffice: _receivingOfficerOfficeNameController.text,
            receivingOfficerPosition:
                _receivingOfficerPositionNameController.text,
            receivingOfficerName: _receivingOfficerNameController.text,
            approvingOfficerOffice: _approvingOfficerOfficeNameController.text,
            approvingOfficerPosition:
                _approvingOfficerPositionNameController.text,
            approvingOfficerName: _approvingOfficerNameController.text,
            issuingOfficerOffice: _issuingOfficerOfficeNameController.text,
            issuingOfficerPosition: _issuingOfficerPositionNameController.text,
            issuingOfficerName: _issuingOfficerNameController.text,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _prIdController.dispose();
    _prDateController.dispose();
    _prStatusController.dispose();
    _requestingOfficerController.dispose();
    _approvingOfficerController.dispose();

    _receivingOfficerOfficeNameController.dispose();
    _receivingOfficerPositionNameController.dispose();
    _receivingOfficerNameController.dispose();

    _sendingOfficerOfficeNameController.dispose();
    _sendingOfficerPositionNameController.dispose();
    _sendingOfficerNameController.dispose();

    _selectedReceivingOfficerOffice.dispose();
    _selectedReceivingOfficerPosition.dispose();
    _selectedSendingOfficerOffice.dispose();
    _selectedSendingOfficerPosition.dispose();
    _selectedApprovingOfficerOffice.dispose();
    _selectedApprovingOfficerPosition.dispose();
    _selectedIssuingOfficerOffice.dispose();
    _selectedIssuingOfficerPosition.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<IssuancesBloc, IssuancesState>(
        listener: (context, state) async {
          if (state is MatchedItemWithPr) {
            final initData = state.matchedItemWithPrEntity;
            final prData = initData.purchaseRequestEntity;

            _prIdController.text = prData.id;
            _prDateController.text = documentDateFormatter(prData.date);
            _prStatusController.text =
                readableEnumConverter(prData.purchaseRequestStatus);
            _requestingOfficerController.text =
                '${capitalizeWord(prData.requestingOfficerEntity.name)} (${capitalizeWord(prData.requestingOfficerEntity.officeName)} - ${capitalizeWord(prData.requestingOfficerEntity.positionName)})';
            _approvingOfficerController.text =
                '${capitalizeWord(prData.approvingOfficerEntity.name)} (${capitalizeWord(prData.approvingOfficerEntity.officeName)} - ${capitalizeWord(prData.approvingOfficerEntity.positionName)})';

            _prTableRows.clear();
            _prTableRows.addAll(
              prData.requestedItemEntities
                  .map(
                    (requestedItem) => TableData(
                      id: '',
                      columns: [
                        Text(
                          requestedItem.productNameEntity.name,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        Text(
                          requestedItem.productDescriptionEntity.description ??
                              'No description specified.',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        Text(
                          requestedItem.quantity.toString(),
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        Text(
                          requestedItem.remainingQuantity.toString(),
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        Text(
                          'Not complete',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            );
            //_itemNameController.text = prData.productNameEntity.name;
            //_quantityController.text = prData.quantity.toString();

            // _issuanceItems = initData.matchedItemEntity!
            //     .map(
            //       (matchedItem) => {
            //         'item_id': matchedItem.itemId,
            //         'issued_quantity': matchedItem.issuedQuantity,
            //       },
            //     )
            //     .toList();
            // print(_issuanceItems);

            // _tableRows.clear();
            // _tableRows.addAll(initData.matchedItemEntity!
            //     .map(
            //       (matchedItem) => TableData(
            //         id: matchedItem.itemId,
            //         columns: [
            //           Text(
            //             matchedItem.itemId,
            //             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            //                   fontSize: 14.0,
            //                   fontWeight: FontWeight.w500,
            //                 ),
            //           ),
            //           Text(
            //             matchedItem.issuedQuantity.toString(),
            //             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            //                   fontSize: 14.0,
            //                   fontWeight: FontWeight.w500,
            //                 ),
            //           ),
            //         ],
            //       ),
            //     )
            //     .toList());
          }

          if (state is ICSRegistered) {
            DelightfulToastUtils.showDelightfulToast(
              icon: HugeIcons.strokeRoundedCheckmarkCircle02,
              context: context,
              title: 'Success',
              subtitle: 'ICS created successfully.',
            );
            await Future.delayed(const Duration(seconds: 3));
            context.pop();
          }

          if (state is PARRegistered) {
            DelightfulToastUtils.showDelightfulToast(
              icon: HugeIcons.strokeRoundedCheckmarkCircle02,
              context: context,
              title: 'Success',
              subtitle: 'PAR created successfully.',
            );
            await Future.delayed(const Duration(seconds: 3));
            context.pop();
          }

          if (state is RISRegistered) {
            DelightfulToastUtils.showDelightfulToast(
              icon: HugeIcons.strokeRoundedCheckmarkCircle02,
              context: context,
              title: 'Success',
              subtitle: 'RIS created successfully.',
            );
            await Future.delayed(const Duration(seconds: 3));
            context.pop();
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
          _buildPreviewPurchaseRequestSummary(),
          const SizedBox(
            height: 50.0,
          ),
          _buildItemIssuanceSection(),
          const SizedBox(
            height: 50.0,
          ),
          _buildRelatedOfficersSection(),
          const SizedBox(
            height: 80.0,
          ),
          _buildActionsRow(),
        ],
      ),
    );
  }

  Widget _buildPreviewPurchaseRequestSummary() {
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
          'Summarize information of the Purchase Request.',
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
              flex: 2,
              child: CustomFormTextField(
                controller: _prIdController,
                enabled: false,
                label: 'PR No.',
                placeholderText: 'Ex.',
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: CustomFormTextField(
                controller: _prDateController,
                enabled: false,
                label: 'Date',
                placeholderText: '0000/00/00',
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: CustomFormTextField(
                controller: _prStatusController,
                enabled: false,
                label: 'Status',
                placeholderText: 'Unknown',
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
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
                controller: _requestingOfficerController,
                enabled: false,
                label: 'Requesting Officer',
                placeholderText: 'Name (Office - Position)',
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: CustomFormTextField(
                controller: _approvingOfficerController,
                enabled: false,
                label: 'Approving Officer',
                placeholderText: 'Name (Office - Position)',
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20.0,
        ),
        SizedBox(
          height: 250.0,
          child: CustomDataTable(
            config: _prTableConfig.copyWith(
              rows: _prTableRows,
            ),
            onActionSelected: (id, action) {},
          ),
        ),
      ],
    );
  }

  Widget _buildItemIssuanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Item(s) Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Text(
                  'Item(s) to be issued.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ],
            ),
            CustomFilledButton(
              width: 160.0,
              height: 40.0,
              onTap: () => showDialog(
                context: context,
                builder: (context) => ItemSelectionModal(
                  onSelectedItems: (
                    List<Map<String, dynamic>>? selectedItems,
                  ) {
                    print('main view: $selectedItems');

                    if (selectedItems == null || selectedItems.isEmpty) return;

                    // Ensure _issuedTableRows is not null
                    final existingRows = _issuedTableRows.value ?? [];

                    // Create a set to keep unique items based on a unique property (e.g., baseItemId)
                    final existingItemIds = existingRows
                        .map((row) => row.object['shareable_item_information']
                            ['base_item_id'])
                        .toSet();

                    final newRows = selectedItems.where((selectedItem) {
                      final baseItemId =
                          selectedItem['shareable_item_information']
                              ['base_item_id'];
                      // Only include the item if it's not already in the existing set
                      return !existingItemIds.contains(baseItemId);
                    }).map((selectedItem) {
                      final baseItemId =
                          selectedItem['shareable_item_information']
                                  ['base_item_id']
                              .toString();
                      final quantity = int.tryParse(
                              selectedItem['shareable_item_information']
                                      ['quantity']
                                  .toString()) ??
                          0;

                      // Create new notifiers and controllers for each unique item
                      _quantityNotifiers[baseItemId] =
                          ValueNotifier<int>(quantity);
                      _quantityControllers[baseItemId] =
                          TextEditingController(text: quantity.toString());

                      // add the issued quantity field to selectedItem
                      selectedItem['issued_quantity'] =
                          _quantityControllers[baseItemId]!.text;

                      print('updated selected item map: $selectedItem');

                      return TableData(
                        id: '',
                        object: selectedItem, // Assign selectedItem to object
                        columns: [
                          Text(
                            baseItemId,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          Text(
                            quantity.toString(),
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          _buildQuantityCounterField(
                            baseItemId, // Pass unique ID to fetch the right notifier/controller
                          ),
                        ],
                        menuItems: [
                          {
                            'text': 'Remove',
                            'icon': HugeIcons.strokeRoundedDelete02,
                          },
                        ],
                      );
                    }).toList();

                    // Update _issuedTableRows without duplicates
                    _issuedTableRows.value = [...existingRows, ...newRows];
                  },
                  preselectedItems: (_issuedTableRows.value ?? [])
                      .map((issuedTableRow) =>
                          issuedTableRow.object as Map<String, dynamic>)
                      .toList(),
                ),
              ),
              prefixWidget: const Icon(
                HugeIcons.strokeRoundedAddSquare,
                size: 15.0,
                color: AppColor.lightPrimary,
              ),
              text: 'Select Item(s)',
            ),
          ],
        ),
        const SizedBox(
          height: 20.0,
        ),
        SizedBox(
          height: 250.0,
          child: ValueListenableBuilder(
            valueListenable: _issuedTableRows,
            builder: (context, issuedTableRows, child) {
              return CustomDataTable(
                config: _issuedTableConfig.copyWith(
                  rows: issuedTableRows,
                ),
                onActionSelected: (index, action) {
                  if (action.contains('Remove')) {
                    final removedItemId = _issuedTableRows.value[index]
                        .object['shareable_item_information']['base_item_id'];

                    // Remove the associated notifier and controller
                    _quantityNotifiers.remove(removedItemId);
                    _quantityControllers.remove(removedItemId);

                    final updatedRows =
                        List<TableData>.from(_issuedTableRows.value);
                    updatedRows.removeAt(index);
                    _issuedTableRows.value = updatedRows;
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  final Map<String, ValueNotifier<int>> _quantityNotifiers = {};
  final Map<String, TextEditingController> _quantityControllers = {};

  Widget _buildQuantityCounterField(String baseItemId) {
    final ValueNotifier<int> quantityNotifier = _quantityNotifiers[baseItemId]!;
    final TextEditingController quantityController =
        _quantityControllers[baseItemId]!;

    return ValueListenableBuilder<int>(
      valueListenable: quantityNotifier,
      builder: (BuildContext context, int value, Widget? child) {
        return CustomFormTextField(
          controller: quantityController,
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
          isNumeric: true,
          suffixWidget: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  quantityNotifier.value++;
                  quantityController.text = quantityNotifier.value.toString();
                },
                child: const Icon(
                  Icons.keyboard_arrow_up,
                  size: 18.0,
                ),
              ),
              InkWell(
                onTap: () {
                  if (quantityNotifier.value > 0) {
                    quantityNotifier.value--;
                    quantityController.text = quantityNotifier.value.toString();
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

  Widget _buildRelatedOfficersSection() {
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
          'Officers involved to this request.',
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
              child: _buildRequestingOfficerOfficeSuggestionField(),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: _buildRequestingOfficerPositionSuggestionField(),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: _buildRequestingOfficerNameSuggestionField(),
            ),
          ],
        ),
        const SizedBox(
          height: 30.0,
        ),
        if (widget.issuanceType != IssuanceType.ris)
          Row(
            children: [
              Expanded(
                child: _buildSendingOfficerOfficeSuggestionField(),
              ),
              const SizedBox(
                width: 20.0,
              ),
              Expanded(
                child: _buildSendingOfficerPositionSuggestionField(),
              ),
              const SizedBox(
                width: 20.0,
              ),
              Expanded(
                child: _buildSendingOfficerNameSuggestionField(),
              ),
            ],
          ),
        if (widget.issuanceType == IssuanceType.ris)
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildApprovingOfficerOfficeSuggestionField(),
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    child: _buildApprovingOfficerPositionSuggestionField(),
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    child: _buildApprovingOfficerNameSuggestionField(),
                  ),
                ],
              ),
              const SizedBox(
                height: 30.0,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildIssuingOfficerOfficeSuggestionField(),
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    child: _buildIssuingOfficerPositionSuggestionField(),
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    child: _buildIssuingOfficerNameSuggestionField(),
                  ),
                ],
              ),
            ],
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
          label: 'Acquired Date',
          dateController: dateController,
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
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
          _receivingOfficerPositionNameController.clear();
          _receivingOfficerNameController.clear();

          _selectedReceivingOfficerOffice.value = null;
          _selectedReceivingOfficerPosition.value = null;
        }

        return offices;
      },
      onSelected: (value) {
        _receivingOfficerOfficeNameController.text = value;
        _receivingOfficerPositionNameController.clear();
        _receivingOfficerNameController.clear();

        _selectedReceivingOfficerOffice.value = value;
        _selectedReceivingOfficerPosition.value = null;
      },
      controller: _receivingOfficerOfficeNameController,
      label: 'Receiving Officer Office',
      placeHolderText: 'Enter requesting officer\'s office',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildSendingOfficerOfficeSuggestionField() {
    return CustomSearchField(
      suggestionsCallback: (officeName) async {
        final offices = await _officerSuggestionsService.fetchOffices(
          officeName: officeName,
        );

        if (offices == null) {
          _sendingOfficerPositionNameController.clear();
          _sendingOfficerNameController.clear();

          _selectedSendingOfficerOffice.value = null;
          _selectedSendingOfficerPosition.value = null;
        }

        return offices;
      },
      onSelected: (value) {
        _sendingOfficerOfficeNameController.text = value;
        _sendingOfficerPositionNameController.clear();
        _sendingOfficerNameController.clear();

        _selectedSendingOfficerOffice.value = value;
        _selectedSendingOfficerPosition.value = null;
      },
      controller: _sendingOfficerOfficeNameController,
      label: 'Sending Officer Office',
      placeHolderText: 'Enter sending officer\'s office',
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
          _approvingOfficerPositionNameController.clear();
          _approvingOfficerNameController.clear();

          _selectedApprovingOfficerOffice.value = null;
          _selectedApprovingOfficerPosition.value = null;
        }

        return offices;
      },
      onSelected: (value) {
        _approvingOfficerOfficeNameController.text = value;
        _approvingOfficerPositionNameController.clear();
        _approvingOfficerNameController.clear();

        _selectedApprovingOfficerOffice.value = value;
        _selectedApprovingOfficerPosition.value = null;
      },
      controller: _approvingOfficerOfficeNameController,
      label: 'Approving Officer Office',
      placeHolderText: 'Enter approving officer\'s office',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
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

  Widget _buildRequestingOfficerPositionSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedReceivingOfficerOffice,
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
                _receivingOfficerNameController.clear();
                _selectedReceivingOfficerPosition.value = null;
              }

              return positions;
            }
            return null;
          },
          onSelected: (value) {
            _receivingOfficerPositionNameController.text = value;
            _receivingOfficerNameController.clear();
            _selectedReceivingOfficerPosition.value = value;
          },
          controller: _receivingOfficerPositionNameController,
          label: 'Receiving Officer Position',
          placeHolderText: 'Enter requesting officer\'s position',
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        );
      },
    );
  }

  Widget _buildSendingOfficerPositionSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedSendingOfficerOffice,
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
                _sendingOfficerNameController.clear();
                _selectedSendingOfficerPosition.value = null;
              }

              return positions;
            }
            return null;
          },
          onSelected: (value) {
            _sendingOfficerPositionNameController.text = value;
            _sendingOfficerNameController.clear();
            _selectedSendingOfficerPosition.value = value;
          },
          controller: _sendingOfficerPositionNameController,
          label: 'Sending Officer Position',
          placeHolderText: 'Enter sending officer\'s position',
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
            _approvingOfficerPositionNameController.text = value;
            _approvingOfficerNameController.clear();
            _selectedApprovingOfficerPosition.value = value;
          },
          controller: _approvingOfficerPositionNameController,
          label: 'Approving Officer Position',
          placeHolderText: 'Enter approving officer\'s position',
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        );
      },
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

  Widget _buildRequestingOfficerNameSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedReceivingOfficerOffice,
      builder: (context, selectedOfficeName, child) {
        return ValueListenableBuilder(
          valueListenable: _selectedReceivingOfficerPosition,
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
                _receivingOfficerNameController.text = value;
              },
              controller: _receivingOfficerNameController,
              label: 'Receiving Officer Name',
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

  Widget _buildSendingOfficerNameSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedSendingOfficerOffice,
      builder: (context, selectedOfficeName, child) {
        return ValueListenableBuilder(
          valueListenable: _selectedSendingOfficerPosition,
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
                _sendingOfficerNameController.text = value;
              },
              controller: _sendingOfficerNameController,
              label: 'Sending Officer Name',
              placeHolderText: 'Enter sending officer\'s name',
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
