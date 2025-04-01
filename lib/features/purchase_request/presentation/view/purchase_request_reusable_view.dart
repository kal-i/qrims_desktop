import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';
import '../../../../core/common/components/custom_data_table.dart';
import '../../../../core/common/components/custom_date_picker.dart';
import '../../../../core/common/components/custom_dropdown_field.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/common/components/reusable_linear_progress_indicator.dart';
import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/services/entity_suggestions_service.dart';
import '../../../../core/services/officer_suggestions_service.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../../core/utils/fund_cluster_to_readable_string.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../../../../core/common/components/custom_form_text_field.dart';
import '../../../../core/utils/show_confirmation_dialog.dart';
import '../../../../init_dependencies.dart';
import '../../../navigation/domain/domain/entities/notification.dart';
import '../../../purchase_order/presentation/components/request_time_line_tile.dart';
import '../bloc/purchase_requests_bloc.dart';
import '../components/add_requested_item_modal.dart';
import '../components/custom_search_field.dart';

class PurchaseRequestReusableView extends StatefulWidget {
  const PurchaseRequestReusableView({
    super.key,
    this.prId,
  });

  final String? prId;

  @override
  State<PurchaseRequestReusableView> createState() =>
      _PurchaseRequestReusableViewState();
}

class _PurchaseRequestReusableViewState
    extends State<PurchaseRequestReusableView> {
  late EntitySuggestionService _entitySuggestionService;
  late OfficerSuggestionsService _officerSuggestionsService;

  final _formKey = GlobalKey<FormState>();

  final _prIdController = TextEditingController();
  final _responsibilityCenterCodeController = TextEditingController();
  final _officeController = TextEditingController();
  final _dateController = TextEditingController();
  final _entityNameController = TextEditingController();
  final _purposeController = TextEditingController();

  final _requestingOfficerOfficeController = TextEditingController();
  final _requestingOfficerPositionController = TextEditingController();
  final _requestingOfficerNameController = TextEditingController();

  final _approvingOfficerOfficeController = TextEditingController();
  final _approvingOfficerPositionController = TextEditingController();
  final _approvingOfficerNameController = TextEditingController();

  final ValueNotifier<FundCluster?> _selectedFundCluster =
      ValueNotifier(FundCluster.unknown);
  final ValueNotifier<String?> _selectedRequestingOfficerOffice =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedRequestingOfficerPosition =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedApprovingOfficerOffice =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedApprovingOfficerPosition =
      ValueNotifier(null);

  final ValueNotifier<DateTime> _pickedDate = ValueNotifier(DateTime.now());

  final ValueNotifier<List<NotificationEntity>> _notificationEntities =
      ValueNotifier([]);

  bool _isViewOnlyMode() => widget.prId != null;

  late TableConfig _tableConfig;
  final List<String> _tableHeaders = [
    'Item Name',
    'Description',
    'Unit',
    'Quantity',
    'Unit Cost',
  ];
  final ValueNotifier<List<TableData>> _tableRows = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    if (widget.prId != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          context.read<PurchaseRequestsBloc>().add(
                GetPurchaseRequestByIdEvent(
                  prId: widget.prId!,
                ),
              );
        },
      );
    } else {
      _entitySuggestionService = serviceLocator<EntitySuggestionService>();
      _officerSuggestionsService = serviceLocator<OfficerSuggestionsService>();
    }

    _initializeTableConfig();
  }

  void _initializeTableConfig() {
    _tableConfig = TableConfig(
      headers: _tableHeaders,
      rows: _tableRows.value,
      columnFlex: [
        2,
        3,
        1,
        1,
        1,
      ],
    );
  }

  void _savePurchaseRequest() async {
    if (_formKey.currentState!.validate()) {
      if (_tableRows.value.isEmpty) {
        DelightfulToastUtils.showDelightfulToast(
          context: context,
          icon: Icons.error_outline,
          title: 'Error',
          subtitle: 'Requested Item(s) cannot be empty.',
        );
        return;
      }

      // Show confirmation dialog before proceeding
      final shouldProceed = await showConfirmationDialog(
        context: context,
        confirmationTitle: 'Register Purchase Request',
        confirmationMessage:
            'Are you sure you want to register the purchase request?',
      );

      if (shouldProceed) {
        context.read<PurchaseRequestsBloc>().add(
              RegisterPurchaseRequestEvent(
                entityName: _entityNameController.text,
                fundCluster: _selectedFundCluster.value!,
                officeName: _officeController.text,
                date: _pickedDate.value,
                requestedItems: _tableRows.value
                    .map((e) => e.object as Map<String, dynamic>)
                    .toList(),
                purpose: _purposeController.text,
                requestingOfficerOffice:
                    _requestingOfficerOfficeController.text,
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
  }

  void _onTrackingIdTapped(BuildContext context, String trackingId) {
    print('tracking id: $trackingId');
    final Map<String, dynamic> extra = {
      'issuance_id': trackingId.toString().split(' ').last,
    };

    // if (widget.initLocation ==
    //     RoutingConstants.nestedHomePurchaseRequestViewRoutePath) {
    //   context.go(RoutingConstants.nestedHomeIssuanceViewRoutePath,
    //       extra: extra);
    // }
    //
    // if (widget.initLocation ==
    //     RoutingConstants.nestedHistoryPurchaseRequestViewRoutePath) {
    //   context.go(RoutingConstants.nestedHistoryIssuanceViewRoutePath,
    //       extra: extra);
    // }
  }

  @override
  void dispose() {
    _prIdController.dispose();
    _responsibilityCenterCodeController.dispose();
    _officeController.dispose();
    _dateController.dispose();
    _entityNameController.dispose();
    _purposeController.dispose();

    _requestingOfficerOfficeController.dispose();
    _requestingOfficerPositionController.dispose();
    _requestingOfficerNameController.dispose();

    _approvingOfficerOfficeController.dispose();
    _approvingOfficerPositionController.dispose();
    _approvingOfficerNameController.dispose();

    _selectedFundCluster.dispose();

    _selectedRequestingOfficerOffice.dispose();
    _selectedRequestingOfficerPosition.dispose();
    _selectedApprovingOfficerOffice.dispose();
    _selectedApprovingOfficerPosition.dispose();

    _notificationEntities.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<PurchaseRequestsBloc, PurchaseRequestsState>(
        listener: (context, state) async {
          if (state is PurchaseRequestLoaded) {
            final purchaseRequestWithNotificationTrailEntity =
                state.purchaseRequestWithNotificationTrailEntity;
            final purchaseRequestEntity =
                purchaseRequestWithNotificationTrailEntity
                    .purchaseRequestEntity;
            final notificationEntities =
                purchaseRequestWithNotificationTrailEntity.notificationEntities;
            final requestingOfficerEntity =
                purchaseRequestEntity.requestingOfficerEntity;
            final approvingOfficerEntity =
                purchaseRequestEntity.approvingOfficerEntity;

            _prIdController.text = purchaseRequestEntity.id;
            _responsibilityCenterCodeController.text =
                purchaseRequestEntity.responsibilityCenterCode ?? 'N/A';

            _officeController.text =
                purchaseRequestEntity.officeEntity.officeName;
            _entityNameController.text = purchaseRequestEntity.entity.name;
            _purposeController.text = purchaseRequestEntity.purpose;

            _requestingOfficerOfficeController.text =
                requestingOfficerEntity.officeName;
            _requestingOfficerPositionController.text =
                requestingOfficerEntity.officeName;
            _requestingOfficerNameController.text =
                requestingOfficerEntity.name;

            _approvingOfficerOfficeController.text =
                approvingOfficerEntity.officeName;
            _approvingOfficerPositionController.text =
                approvingOfficerEntity.positionName;
            _approvingOfficerNameController.text = approvingOfficerEntity.name;

            _tableRows.value.clear();
            _tableRows.value.addAll(
              purchaseRequestEntity.requestedItemEntities
                  .map(
                    (requestedItem) => TableData(
                      id: requestedItem.id.toString(),
                      columns: [
                        Text(
                          capitalizeWord(requestedItem.productNameEntity.name),
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        Text(
                          capitalizeWord(
                              '${requestedItem.productDescriptionEntity.description}${requestedItem.specification != null ? ', ${requestedItem.specification}' : ''}'),
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        Text(
                          readableEnumConverter(requestedItem.unit),
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        Text(
                          capitalizeWord(requestedItem.quantity.toString()),
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        Text(
                          capitalizeWord(requestedItem.unitCost.toString()),
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

            _selectedFundCluster.value = FundCluster.values.firstWhere(
              (e) =>
                  e.toString().split('.').last ==
                  purchaseRequestEntity.fundCluster.toString().split('.').last,
              orElse: () => FundCluster.unknown,
            );
            _pickedDate.value = purchaseRequestEntity.date;

            _notificationEntities.value = notificationEntities;
          }

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
          if (_isViewOnlyMode()) _buildViewOnlyWidgets(),
          _buildPurchaseRequestInitialInformationFields(),
          const SizedBox(
            height: 20.0,
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

  Widget _buildViewOnlyWidgets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Purchase Request QR Code',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 20.0),
        ValueListenableBuilder(
          valueListenable: _notificationEntities,
          builder: (contet, notifications, child) {
            return _buildTimeline(notifications);
          },
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
                    label: 'PR Id',
                    controller: _prIdController,
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
                    label: 'Responsibility Center Code',
                    controller: _responsibilityCenterCodeController,
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
          height: 20.0,
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
        data: _prIdController.text,
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
        const SizedBox(
          height: 20.0,
        ),
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
        Row(
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
        const SizedBox(
          height: 15.0,
        ),
        CustomFormTextField(
          label: 'Purpose',
          controller: _purposeController,
          enabled: !_isViewOnlyMode(),
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
                  'Requested Item(s) Information.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ],
            ),
            if (!_isViewOnlyMode())
              CustomFilledButton(
                width: 160.0,
                height: 40.0,
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => AddRequestedItemModal(
                    onAdd: (Map<String, dynamic> requestedItem) {
                      // Ensure existing rows are not null
                      final existingRows = _tableRows.value ?? [];
                      final requestedItemSpecification =
                          requestedItem['product_specification'] as String?;

                      // Create a new TableData object
                      final newRow = TableData(
                        id: '',
                        object: requestedItem,
                        columns: [
                          Text(
                            capitalizeWord(requestedItem['product_name']),
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          Text(
                            (requestedItemSpecification == null ||
                                    requestedItemSpecification.isEmpty ||
                                    requestedItemSpecification.toLowerCase() ==
                                        'na' ||
                                    requestedItemSpecification.toLowerCase() ==
                                        'n/a')
                                ? capitalizeWord(
                                    requestedItem['product_description'])
                                : capitalizeWord(
                                    '${requestedItem['product_description']}, ${requestedItem['specification']}'),
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            readableEnumConverter(requestedItem['unit']),
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          Text(
                            capitalizeWord(
                                requestedItem['quantity'].toString()),
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          Text(
                            formatCurrency(requestedItem['unit_cost']),
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ],
                        menuItems: [
                          {
                            'text': 'Remove',
                            'icon': HugeIcons.strokeRoundedDelete02,
                          },
                        ],
                      );

                      // Append new row while keeping old ones
                      _tableRows.value = [...existingRows, newRow];

                      print(_tableRows.value.map((e) => e.object).toList());
                    },
                  ),
                ),
                prefixWidget: const Icon(
                  HugeIcons.strokeRoundedAddSquare,
                  size: 15.0,
                  color: AppColor.lightPrimary,
                ),
                text: 'Add Item',
              ),
          ],
        ),
        const SizedBox(
          height: 15.0,
        ),
        SizedBox(
          height: 250.0,
          child: ValueListenableBuilder(
              valueListenable: _tableRows,
              builder: (context, tableRows, child) {
                return CustomDataTable(
                  config: _tableConfig.copyWith(
                    rows: tableRows,
                  ),
                  onActionSelected: (index, action) {
                    if (action.contains('Remove')) {
                      final updatedRows =
                          List<TableData>.from(_tableRows.value);
                      updatedRows.removeAt(index);

                      // Update _tableRows with the modified list
                      _tableRows.value = updatedRows;

                      print(_tableRows.value.map((e) => e.object).toList());
                    }
                  },
                );
              }),
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
      enabled: !_isViewOnlyMode(),
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
      enabled: !_isViewOnlyMode(),
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
          value: selectedFundCluster.toString(),
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
                    fundCluster.toReadableString(),
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
      enabled: !_isViewOnlyMode(),
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
      enabled: !_isViewOnlyMode(),
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
          enabled: !_isViewOnlyMode(),
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
          enabled: !_isViewOnlyMode(),
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
              enabled: !_isViewOnlyMode(),
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
              enabled: !_isViewOnlyMode(),
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

  Widget _buildTimeline(List<NotificationEntity> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 200.0,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: notifications.map((notification) {
                final index = notifications.indexOf(notification);
                final isFirst = index == 0;
                final isLast = index == notifications.length - 1;

                return SizedBox(
                  width: 300.0,
                  height: 200.0,
                  child: RequestTimeLineTile(
                    isFirst: isFirst,
                    isLast: isLast,
                    isPast: true,
                    title: readableEnumConverter(notification.type),
                    message: notification.message,
                    date: notification.createdAt!,
                    onTrackingIdTapped: (trackingId) =>
                        _onTrackingIdTapped(context, trackingId),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsRow() {
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
