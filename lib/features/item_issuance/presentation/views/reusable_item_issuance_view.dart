import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';
import '../../../../core/common/components/custom_data_table.dart';
import '../../../../core/common/components/custom_date_picker.dart';
import '../../../../core/common/components/custom_dropdown_field.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_form_text_field.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/common/components/reusable_linear_progress_indicator.dart';
import '../../../../core/enums/fulfillment_status.dart';
import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/ics_type.dart';
import '../../../../core/enums/issuance_type.dart';
import '../../../../core/services/entity_suggestions_service.dart';
import '../../../../core/services/officer_suggestions_service.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/utils/confirmation_dialog.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../../core/utils/document_date_formatter.dart';
import '../../../../core/utils/fund_cluster_to_readable_string.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../../../../core/utils/standardize_position_name.dart';
import '../../../../init_dependencies.dart';
import '../../../purchase_request/presentation/components/custom_search_field.dart';
import '../bloc/issuances_bloc.dart';
import '../components/item_card.dart';
import '../components/item_selection_modal.dart';

/// todo: add a manual search option if no items found
class ReusableItemIssuanceView extends StatefulWidget {
  const ReusableItemIssuanceView({
    super.key,
    required this.issuanceType,
    this.prId,
  });

  final IssuanceType issuanceType;
  final String? prId;

  @override
  State<ReusableItemIssuanceView> createState() =>
      _ReusableItemIssuanceViewState();
}

class _ReusableItemIssuanceViewState extends State<ReusableItemIssuanceView> {
  late IssuancesBloc _issuancesBloc;
  late EntitySuggestionService _entitySuggestionService;
  late OfficerSuggestionsService _officerSuggestionsService;

  final _formKey = GlobalKey<FormState>();

  final _prIdController = TextEditingController();
  final _prDateController = TextEditingController();
  final _prStatusController = TextEditingController();
  final _requestingOfficerController = TextEditingController();
  final _approvingOfficerController = TextEditingController();

  final _entityNameController = TextEditingController();

  final _divisionController = TextEditingController();
  final _responsibilityCenterCodeController = TextEditingController();
  final _officeNameController = TextEditingController();
  final _purposeController = TextEditingController();

  final _supplierNameController = TextEditingController();
  final _deliveryReceiptIdController = TextEditingController();
  final _prReferenceIdController = TextEditingController();
  final _inventoryTransferReportIdController = TextEditingController();
  final _inspectionAndAcceptanceReportIdController = TextEditingController();
  final _contractNumberController = TextEditingController();
  final _purchaseOrderNumberController = TextEditingController();

  final _receivingOfficerOfficeNameController = TextEditingController();
  final _receivingOfficerPositionNameController = TextEditingController();
  final _receivingOfficerNameController = TextEditingController();

  final _issuingOfficerOfficeNameController = TextEditingController();
  final _issuingOfficerPositionNameController = TextEditingController();
  final _issuingOfficerNameController = TextEditingController();

  final _approvingOfficerOfficeNameController = TextEditingController();
  final _approvingOfficerPositionNameController = TextEditingController();
  final _approvingOfficerNameController = TextEditingController();

  final _requestingOfficerOfficeNameController = TextEditingController();
  final _requestingOfficerPositionNameController = TextEditingController();
  final _requestingOfficerNameController = TextEditingController();

  final ValueNotifier<IcsType?> _selectedIcsType = ValueNotifier(null);
  final ValueNotifier<FundCluster?> _selectedFundCluster = ValueNotifier(null);
  final ValueNotifier<String?> _selectedReceivingOfficerOffice =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedReceivingOfficerPosition =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedApprovingOfficerOffice =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedApprovingOfficerPosition =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedIssuingOfficerOffice =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedIssuingOfficerPosition =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedRequestingOfficerOffice =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedRequestingOfficerPosition =
      ValueNotifier(null);

  final ValueNotifier<DateTime> _pickedDate = ValueNotifier(DateTime.now());
  final ValueNotifier<DateTime?> _dateAcquired = ValueNotifier(null);

  final ValueNotifier<List<Map<String, dynamic>>> _items = ValueNotifier([]);

  late TableConfig _prTableConfig;
  late TableConfig _issuedTableConfig;

  final List<String> _prTableHeaders = [
    'Item Name',
    'Description',
    'Remaining Quantity To Fulfill',
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
    _entitySuggestionService = serviceLocator<EntitySuggestionService>();
    _officerSuggestionsService = serviceLocator<OfficerSuggestionsService>();

    if (widget.prId != null && widget.prId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _issuancesBloc.add(
          MatchItemWithPrEvent(
            prId: widget.prId!,
          ),
        );
      });
    }

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

  void _removeItem(int index) {
    final updated = List<Map<String, dynamic>>.from(_items.value);
    updated.removeAt(index);
    _items.value = updated;
  }

  void _editItemQuantity(int index) async {
    final currentItem = _items.value[index];
    final currentQuantity = currentItem['issued_quantity'] ?? 1;
    final maxQuantity = currentItem['shareable_item_information']['quantity'];

    final controller = TextEditingController(text: currentQuantity.toString());
    String? errorText; // <-- For showing the live error message

    final newQuantity = await showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: Text(
                'Edit Quantity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter quantity (1 to $maxQuantity)',
                      errorText: errorText, // <-- Show the error here
                    ),
                    onChanged: (text) {
                      final value = int.tryParse(text);
                      setState(() {
                        if (value == null || value < 1) {
                          errorText = 'Minimum quantity is 1.';
                        } else if (value > maxQuantity) {
                          errorText = 'Cannot exceed $maxQuantity.';
                        } else {
                          errorText = null; // valid input
                        }
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final value = int.tryParse(controller.text);
                    if (value != null && value >= 1 && value <= maxQuantity) {
                      Navigator.pop(context, value);
                    } else {
                      // do nothing, because the error message is already shown
                    }
                  },
                  child: Text(
                    'Save',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (newQuantity != null) {
      final updated = List<Map<String, dynamic>>.from(_items.value);
      updated[index]['issued_quantity'] = newQuantity;
      _items.value = updated;
    }
  }

  void _saveIssuance() async {
    print('items: ${_items.value}');
    if (_items.value.isEmpty) {
      DelightfulToastUtils.showDelightfulToast(
        context: context,
        icon: Icons.error_outline,
        title: 'Error',
        subtitle: 'Item(s) to issue cannot be empty.',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    confirmationDialog(
      context: context,
      title: 'Register Issuance?',
      content: 'Are you sure you want to register this issuance?',
      onConfirmed: () {
        if (widget.issuanceType == IssuanceType.ics) {
          _issuancesBloc.add(
            CreateICSEvent(
              issuedDate: _pickedDate.value,
              type: _selectedIcsType.value,
              issuanceItems: _items.value,
              prId: _prIdController.text,
              entityName: _entityNameController.text,
              fundCluster: _selectedFundCluster.value,
              supplierName: _supplierNameController.text,
              deliveryReceiptId: _deliveryReceiptIdController.text,
              prReferenceId: _prReferenceIdController.text,
              inventoryTransferReportId:
                  _inventoryTransferReportIdController.text,
              inspectionAndAcceptanceReportId:
                  _inspectionAndAcceptanceReportIdController.text,
              contractNumber: _contractNumberController.text,
              purchaseOrderNumber: _purchaseOrderNumberController.text,
              dateAcquired: _dateAcquired.value,
              receivingOfficerOffice:
                  _receivingOfficerOfficeNameController.text,
              receivingOfficerPosition:
                  _receivingOfficerPositionNameController.text,
              receivingOfficerName: _receivingOfficerNameController.text,
              issuingOfficerOffice: _issuingOfficerOfficeNameController.text,
              issuingOfficerPosition:
                  _issuingOfficerPositionNameController.text,
              issuingOfficerName: _issuingOfficerNameController.text,
            ),
          );
        }

        if (widget.issuanceType == IssuanceType.par) {
          _issuancesBloc.add(
            CreatePAREvent(
              issuedDate: _pickedDate.value,
              issuanceItems: _items.value,
              prId: _prIdController.text,
              entityName: _entityNameController.text,
              fundCluster: _selectedFundCluster.value,
              supplierName: _supplierNameController.text,
              deliveryReceiptId: _deliveryReceiptIdController.text,
              prReferenceId: _prReferenceIdController.text,
              inventoryTransferReportId:
                  _inventoryTransferReportIdController.text,
              inspectionAndAcceptanceReportId:
                  _inspectionAndAcceptanceReportIdController.text,
              contractNumber: _contractNumberController.text,
              purchaseOrderNumber: _purchaseOrderNumberController.text,
              dateAcquired: _dateAcquired.value,
              receivingOfficerOffice:
                  _receivingOfficerOfficeNameController.text,
              receivingOfficerPosition:
                  _receivingOfficerPositionNameController.text,
              receivingOfficerName: _receivingOfficerNameController.text,
              issuingOfficerOffice: _issuingOfficerOfficeNameController.text,
              issuingOfficerPosition:
                  _issuingOfficerPositionNameController.text,
              issuingOfficerName: _issuingOfficerNameController.text,
            ),
          );
        }

        if (widget.issuanceType == IssuanceType.ris) {
          _issuancesBloc.add(
            CreateRISEvent(
              issuedDate: _pickedDate.value,
              issuanceItems: _items.value,
              prId: _prIdController.text,
              entityName: _entityNameController.text,
              fundCluster: _selectedFundCluster.value,
              division: _divisionController.text,
              responsibilityCenterCode:
                  _responsibilityCenterCodeController.text,
              officeName: _officeNameController.text,
              purpose: _purposeController.text,
              receivingOfficerOffice:
                  _receivingOfficerOfficeNameController.text,
              receivingOfficerPosition:
                  _receivingOfficerPositionNameController.text,
              receivingOfficerName: _receivingOfficerNameController.text,
              issuingOfficerOffice: _issuingOfficerOfficeNameController.text,
              issuingOfficerPosition:
                  _issuingOfficerPositionNameController.text,
              issuingOfficerName: _issuingOfficerNameController.text,
              approvingOfficerOffice:
                  _approvingOfficerOfficeNameController.text,
              approvingOfficerPosition:
                  _approvingOfficerPositionNameController.text,
              approvingOfficerName: _approvingOfficerNameController.text,
              requestingOfficerOffice:
                  _requestingOfficerOfficeNameController.text,
              requestingOfficerPosition:
                  _requestingOfficerPositionNameController.text,
              requestingOfficerName: _requestingOfficerNameController.text,
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _prIdController.dispose();
    _prDateController.dispose();
    _prStatusController.dispose();
    _requestingOfficerController.dispose();
    _approvingOfficerController.dispose();

    _entityNameController.dispose();

    _divisionController.dispose();
    _responsibilityCenterCodeController.dispose();
    _officeNameController.dispose();
    _purposeController.dispose();

    _supplierNameController.dispose();
    _deliveryReceiptIdController.dispose();
    _prReferenceIdController.dispose();
    _inventoryTransferReportIdController.dispose();
    _inspectionAndAcceptanceReportIdController.dispose();
    _contractNumberController.dispose();
    _purchaseOrderNumberController.dispose();

    _receivingOfficerOfficeNameController.dispose();
    _receivingOfficerPositionNameController.dispose();
    _receivingOfficerNameController.dispose();

    _issuingOfficerOfficeNameController.dispose();
    _issuingOfficerPositionNameController.dispose();
    _issuingOfficerNameController.dispose();

    _approvingOfficerOfficeNameController.dispose();
    _approvingOfficerPositionNameController.dispose();
    _approvingOfficerNameController.dispose();

    _requestingOfficerOfficeNameController.dispose();
    _requestingOfficerPositionNameController.dispose();
    _requestingOfficerNameController.dispose();

    _selectedIcsType.dispose();
    _selectedFundCluster.dispose();
    _selectedReceivingOfficerOffice.dispose();
    _selectedReceivingOfficerPosition.dispose();
    _selectedRequestingOfficerOffice.dispose();
    _selectedRequestingOfficerPosition.dispose();
    _selectedApprovingOfficerOffice.dispose();
    _selectedApprovingOfficerPosition.dispose();
    _selectedIssuingOfficerOffice.dispose();
    _selectedIssuingOfficerPosition.dispose();

    _pickedDate.dispose();
    _dateAcquired.dispose();

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
                '${capitalizeWord(prData.requestingOfficerEntity.name)} (${capitalizeWord(prData.requestingOfficerEntity.officeName)} - ${standardizePositionName(prData.requestingOfficerEntity.positionName)})';
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
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                        ),
                        Text(
                          requestedItem.productDescriptionEntity.description ??
                              'No description specified.',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                        ),
                        Text(
                          requestedItem.status == FulfillmentStatus.fulfilled ||
                                  requestedItem.status ==
                                      FulfillmentStatus.partiallyFulfilled
                              ? requestedItem.remainingQuantity.toString()
                              : requestedItem.quantity.toString(),
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                        ),
                        Text(
                          readableEnumConverter(requestedItem.status),
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ],
                    ),
                  )
                  .toList(),
            );
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
          if (widget.prId != null && widget.prId!.isNotEmpty)
            Column(
              children: [
                _buildPreviewPurchaseRequestSummary(),
                const SizedBox(
                  height: 50.0,
                ),
              ],
            ),
          _buildRelatedOfficersSection(),
          const SizedBox(
            height: 80.0,
          ),
          if (widget.issuanceType != IssuanceType.ris)
            _buildAdditionalInformationSection(),
          _buildItemIssuanceSection(),
          // const SizedBox(
          //   height: 50.0,
          // ),
          _buildActionsRow(),
        ],
      ),
    );
  }

  Widget _buildInitialInformationSection() {
    return Column(
      children: [
        if (widget.issuanceType == IssuanceType.ics)
          IntrinsicHeight(
            child: Row(
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
          ),
        const SizedBox(
          height: 20.0,
        ),
        IntrinsicHeight(
          child: Row(
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
                      hasValidation: false,
                    ),
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    child: _buildOfficeSuggestionField(),
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    child: CustomFormTextField(
                      label: 'Responsibility Center Code',
                      controller: _responsibilityCenterCodeController,
                      placeholderText: 'Enter responsibility center code',
                      fillColor:
                          (context.watch<ThemeBloc>().state == AppTheme.light
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
              CustomFormTextField(
                label: 'Purpose',
                controller: _purposeController,
                maxLines: 4,
                placeholderText: 'Enter purpose',
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPreviewPurchaseRequestSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '**🧾 Purchase Request**',
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
                label: 'Request Date',
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
                controller: _requestingOfficerController,
                enabled: false,
                label: 'Requesting Officer',
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '**📦 Item(s) Information**',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    'Item(s) to be issued. If no quantity is defined, the available quantity will be issued by default. To edit the quantity to be issued, click the edit (✏️) icon.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                ],
              ),
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
                    // final existingRows = _issuedTableRows.value ?? [];
                    final existingRows = _items.value;

                    // Create a set to keep unique items based on a unique property (e.g., baseItemId)
                    // final existingItemIds = existingRows
                    //     .map((row) => row.object['shareable_item_information']
                    //         ['base_item_id'])
                    //     .toSet();
                    final existingItemIds = existingRows
                        .map(
                          (item) => item['shareable_item_information']
                              ['base_item_id'],
                        )
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
                      // _quantityNotifiers[baseItemId] =
                      //     ValueNotifier<int>(quantity);
                      // _quantityControllers[baseItemId] =
                      //     TextEditingController(text: quantity.toString());

                      // add the issued quantity field to selectedItem
                      // selectedItem['issued_quantity'] =
                      //     _quantityControllers[baseItemId]!.text;

                      print('updated selected item map: $selectedItem');

                      // return TableData(
                      //   id: '',
                      //   object: selectedItem, // Assign selectedItem to object
                      //   columns: [
                      //     Text(
                      //       baseItemId,
                      //       style:
                      //           Theme.of(context).textTheme.bodyLarge?.copyWith(
                      //                 fontSize: 14.0,
                      //                 fontWeight: FontWeight.w500,
                      //               ),
                      //     ),
                      //     Text(
                      //       quantity.toString(),
                      //       style:
                      //           Theme.of(context).textTheme.bodyLarge?.copyWith(
                      //                 fontSize: 14.0,
                      //                 fontWeight: FontWeight.w500,
                      //               ),
                      //     ),
                      //     _buildQuantityCounterField(
                      //       baseItemId, // Pass unique ID to fetch the right notifier/controller
                      //     ),
                      //   ],
                      //   menuItems: [
                      //     {
                      //       'text': 'Remove',
                      //       'icon': HugeIcons.strokeRoundedDelete02,
                      //     },
                      //   ],
                      // );
                      return selectedItem;
                    }).toList();

                    // Update _issuedTableRows without duplicates
                    // _issuedTableRows.value = [...existingRows, ...newRows];
                    _items.value = [...existingRows, ...newRows];
                  },
                  excludeItemIds: _items.value
                      .map((item) =>
                          item['shareable_item_information']['base_item_id'])
                      .toSet(),

                  // preselectedItems: (_issuedTableRows.value ?? [])
                  //     .map((issuedTableRow) =>
                  //         issuedTableRow.object as Map<String, dynamic>)
                  //     .toList(),
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
        ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: _items,
          builder: (context, value, child) {
            final ScrollController scrollController = ScrollController();

            return Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SingleChildScrollView(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(value.length, (index) {
                      return DragTarget(
                        builder: (context, candidatedDate, rejectedDate) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Draggable<int>(
                              data: index,
                              feedback: SizedBox(
                                width: 250.0,
                                child: Material(
                                  color: Colors.transparent,
                                  child: ItemCard(
                                    data: value[index],
                                    isDragging: true,
                                  ),
                                ),
                              ),
                              childWhenDragging: const SizedBox(
                                width: 250.0,
                              ),
                              child: SizedBox(
                                width: 250,
                                child: ItemCard(
                                  data: value[index],
                                  onRemove: () => _removeItem(index),
                                  onEditQuantity: () =>
                                      _editItemQuantity(index),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRelatedOfficersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '**🧑‍💼 Associated Officers**',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          'Officers involved to this issuance.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        if (widget.prId == null || widget.issuanceType == IssuanceType.ris)
          Column(
            children: [
              IntrinsicHeight(
                child: Row(
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
              ),
              const SizedBox(
                height: 30.0,
              ),
            ],
          ),
        if (widget.issuanceType == IssuanceType.ris)
          Column(
            children: [
              IntrinsicHeight(
                child: Row(
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
              ),
              const SizedBox(
                height: 30.0,
              ),
            ],
          ),
        IntrinsicHeight(
          child: Row(
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
        ),
        const SizedBox(
          height: 30.0,
        ),
        Row(
          children: [
            Expanded(
              child: _buildReceivingOfficerOfficeSuggestionField(),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: _buildReceivingOfficerPositionSuggestionField(),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: _buildReceivingOfficerNameSuggestionField(),
            ),
          ],
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
              child: _buildDateAcquiredSelection(),
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
                controller: _deliveryReceiptIdController,
                label: 'Delivery Receipt ID',
                placeholderText: 'Enter delivery receipt ID',
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
                controller: _contractNumberController,
                label: 'Contract Number',
                placeholderText: 'Enter contract number',
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
                controller: _prReferenceIdController,
                label: 'Purchase Request Number',
                placeholderText: 'Enter purchase request number',
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
          height: 20.0,
        ),
        Row(
          children: [
            Expanded(
              child: CustomFormTextField(
                controller: _inventoryTransferReportIdController,
                label: 'Inventory Transfer Report ID',
                placeholderText: 'Enter inventory transfer report ID',
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
          height: 50.0,
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
      hasValidation: false,
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

  Widget _buildRequestingOfficerOfficeSuggestionField() {
    return CustomSearchField(
      suggestionsCallback: (officeName) async {
        final offices = await _officerSuggestionsService.fetchOffices(
          officeName: officeName,
        );

        if (offices == null) {
          _requestingOfficerPositionNameController.clear();
          _requestingOfficerNameController.clear();

          _selectedRequestingOfficerOffice.value = null;
          _selectedRequestingOfficerPosition.value = null;
        }

        return offices;
      },
      onSelected: (value) {
        _requestingOfficerOfficeNameController.text = value;
        _requestingOfficerPositionNameController.clear();
        _requestingOfficerNameController.clear();

        _selectedRequestingOfficerOffice.value = value;
        _selectedRequestingOfficerPosition.value = null;
      },
      controller: _requestingOfficerOfficeNameController,
      label: 'Requesting Officer Office',
      placeHolderText: 'Enter requesting officer\'s office',
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

  Widget _buildReceivingOfficerOfficeSuggestionField() {
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
      placeHolderText: 'Enter receiving officer\'s office',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
      hasValidation: false,
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
            _requestingOfficerPositionNameController.text = value;
            _requestingOfficerNameController.clear();
            _selectedRequestingOfficerPosition.value = value;
          },
          controller: _requestingOfficerPositionNameController,
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

  Widget _buildReceivingOfficerPositionSuggestionField() {
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
          placeHolderText: 'Enter receiving officer\'s position',
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
          hasValidation: false,
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

  Widget _buildReceivingOfficerNameSuggestionField() {
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
              placeHolderText: 'Enter receiving officer\'s name',
              fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                  ? AppColor.lightCustomTextBox
                  : AppColor.darkCustomTextBox),
              hasValidation: false,
            );
          },
        );
      },
    );
  }

  Widget _buildDateAcquiredSelection() {
    return ValueListenableBuilder(
      valueListenable: _dateAcquired,
      builder: (context, dateAcquired, child) {
        final dateController = TextEditingController(
          text: dateAcquired != null ? dateFormatter(dateAcquired) : '',
        );

        return CustomDatePicker(
          onDateChanged: (DateTime? date) {
            if (date != null) {
              _dateAcquired.value = date;
            }
          },
          label: 'Date Acquired',
          dateController: dateController,
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
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
