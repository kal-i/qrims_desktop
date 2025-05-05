import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/app_routing_constants.dart';
import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_icon_button.dart';
import '../../../../core/common/components/custom_message_box.dart';
import '../../../../core/common/components/filter_by_date_modal.dart';
import '../../../../core/common/components/filter_table_row.dart';
import '../../../../core/common/components/highlight_status_container.dart';
import '../../../../core/common/components/pagination_controls.dart';
import '../../../../core/common/components/reusable_custom_refresh_outline_button.dart';
import '../../../../core/common/components/search_button/expandable_search_button.dart';
import '../../../../core/enums/document_type.dart';
import '../../../../core/enums/generate_inventory_report.dart';
import '../../../../core/enums/issuance_status.dart';
import '../../../../core/enums/issuance_type.dart';
import '../../../../core/enums/role.dart';
import '../../../../core/models/supply_department_employee.dart';
import '../../../../core/services/excel_document_service/excel_document_service.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/common/components/custom_data_table.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../../core/utils/document_date_formatter.dart';
import '../../../../init_dependencies.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../item_inventory/domain/entities/supply.dart';
import '../../domain/entities/inventory_custodian_slip.dart';
import '../../domain/entities/issuance.dart';
import '../../domain/entities/property_acknowledgement_receipt.dart';
import '../../domain/entities/requisition_and_issue_slip.dart';
import '../bloc/issuances_bloc.dart';
import '../components/create_existing_issuance_to_ris_modal.dart';
import '../components/create_issuance_modal.dart';
import '../components/custom_document_preview.dart';
import '../components/custom_interactable_card.dart';
import '../components/document_card.dart';
import '../components/generate_inventory_report_modal.dart';
import '../components/generate_semi_expendable_property_card_modal.dart.dart';
import '../components/receive_issuance_modal.dart';

class ItemIssuanceView extends StatefulWidget {
  const ItemIssuanceView({super.key});

  @override
  State<ItemIssuanceView> createState() => _ItemIssuanceViewState();
}

class _ItemIssuanceViewState extends State<ItemIssuanceView> {
  late IssuancesBloc _issuancesBloc;
  late ExcelDocumentService _excelDocumentService;

  late DateTime? _selectedStartDate;
  late DateTime? _selectedEndDate;

  final _searchController = TextEditingController();
  final _searchDelay = const Duration(milliseconds: 500);
  Timer? _debounce;

  late TableConfig _tableConfig;
  final List<String> _tableHeaders = [
    'Issuance ID',
    'Accountable Officer', // Receiving Officer Name
    'Date Issued',
    'Status',
  ];
  late List<TableData> _tableRows;

  final ValueNotifier<String> _selectedFilterNotifier = ValueNotifier('');

  int _currentPage = 1;
  int _pageSize = 10;
  int _totalRecords = 0;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _issuancesBloc = context.read<IssuancesBloc>();
    _excelDocumentService = serviceLocator<ExcelDocumentService>();

    _searchController.addListener(_onSearchChanged);
    _selectedFilterNotifier.addListener(_fetchIssuances);

    _selectedStartDate = null;
    _selectedEndDate = null;

    _tableRows = [];
    _initializeTableConfig();
    _fetchIssuances();
  }

  void _initializeTableConfig() {
    _tableConfig = TableConfig(
      headers: _tableHeaders,
      rows: _tableRows,
      columnFlex: [2, 2, 2, 2],
    );
  }

  void _fetchIssuances() {
    _issuancesBloc.add(
      GetPaginatedIssuancesEvent(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: _searchController.text,
        issueDateStart: _selectedStartDate,
        issueDateEnd: _selectedEndDate,
        type: _selectedFilterNotifier.value,
        //isArchived: isArchived,
      ),
    );
  }

  void _refreshIssuanceList() {
    _searchController.clear();
    _currentPage = 1;
    _selectedStartDate = null;
    _selectedEndDate = null;
    _selectedFilterNotifier.value = '';
    _fetchIssuances();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(_searchDelay, () {
      _currentPage = 1;
      _fetchIssuances();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();

    _selectedFilterNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          bool isAdmin = false;

          if (state is AuthSuccess) {
            isAdmin =
                SupplyDepartmentEmployeeModel.fromEntity(state.data).role ==
                    Role.admin;
          }

          return Column(
            children: [
              _buildClickableCardsRow(isAdmin),
              const SizedBox(
                height: 50.0,
              ),
              _buildPredefinedDocumentTemplatesRow(),
              const SizedBox(
                height: 50.0,
              ),
              _buildActionsRow(),
              const SizedBox(
                height: 20.0,
              ),
              Expanded(
                child: _buildDataTable(isAdmin),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildClickableCardsRow(bool isAdmin) {
    return Row(
      children: [
        Expanded(
          child: CustomInteractableCard(
            name: 'New RIS',
            icon: CupertinoIcons.folder,
            onTap: () => isAdmin
                ? DelightfulToastUtils.showDelightfulToast(
                    context: context,
                    title: 'Information',
                    subtitle: 'You cannot perform this activity.')
                : showDialog(
                    context: context,
                    builder: (context) => const CreateIssuanceModal(
                      issuanceType: IssuanceType.ris,
                    ),
                  ),
          ),
        ),
        const SizedBox(
          width: 15.0,
        ),
        Expanded(
          child: CustomInteractableCard(
            name: 'New ICS',
            icon: Icons.note_outlined,
            onTap: () => isAdmin
                ? DelightfulToastUtils.showDelightfulToast(
                    context: context,
                    title: 'Information',
                    subtitle: 'You cannot perform this activity.')
                : showDialog(
                    context: context,
                    builder: (context) => const CreateIssuanceModal(
                      issuanceType: IssuanceType.ics,
                    ),
                  ),
          ),
        ),
        const SizedBox(
          width: 15.0,
        ),
        Expanded(
          child: CustomInteractableCard(
            name: 'New PAR',
            icon: CupertinoIcons.folder,
            onTap: () => isAdmin
                ? DelightfulToastUtils.showDelightfulToast(
                    context: context,
                    title: 'Information',
                    subtitle: 'You cannot perform this activity.')
                : showDialog(
                    context: context,
                    builder: (context) => const CreateIssuanceModal(
                      issuanceType: IssuanceType.par,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // final predefinedTemplates = [
  //   {
  //     'title': 'RCPI',
  //     'type': DocumentType.rpci,
  //   },
  //   {
  //     'title': 'Annex A.8',
  //     'type': DocumentType.annexA8,
  //   },
  //   {
  //     'title': 'A73',
  //     'type': DocumentType.a73,
  //   },
  // {
  //   'title': 'Property Card',
  //   'type': DocumentType.propertyCard,
  // },
  // {
  //   'title': 'SPC',
  //   'type': DocumentType.spc,
  // },
  // {
  //   'title': 'RSPI',
  //   'type': DocumentType.rspi,
  // },
  // {
  //   'title': 'RSMI',
  //   'type': DocumentType.rsmi,
  // },
  // {
  //   'title': 'Stock Card',
  //   'type': DocumentType.stockCard,
  // },
  // ];

  // Widget _buildPredefinedDocumentTemplatesRow() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.stretch,
  //     children: [
  //       Text(
  //         'Predefined templates',
  //         style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //               fontSize: 18.0,
  //             ),
  //       ),
  //       const SizedBox(
  //         height: 20.0,
  //       ),
  //       SizedBox(
  //         height: 100.0, // Adjust the height as per your design
  //         child: ListView.separated(
  //           scrollDirection: Axis.horizontal,
  //           itemCount: predefinedTemplates.length,
  //           separatorBuilder: (context, index) => const SizedBox(width: 15.0),
  //           itemBuilder: (context, index) {
  //             final template = predefinedTemplates[index];
  //             return SizedBox(
  //               width: 200.0, // Adjust the width of each card as needed
  //               child: DocumentCard(
  //                 onTap: () => template['title'] == 'RCPI'
  //                     ? showDialog(
  //                         context: context,
  //                         builder: (context) =>
  //                             const GenerateInventoryReportModal(
  //                           generateInventoryReportType:
  //                               GenerateInventoryReportType.rcpi,
  //                           modalTitle: 'RPCI',
  //                         ),
  //                       )
  //                     : template['title'] == 'Annex A.8'
  //                         ? showDialog(
  //                             context: context,
  //                             builder: (context) =>
  //                                 const GenerateInventoryReportModal(
  //                               generateInventoryReportType:
  //                                   GenerateInventoryReportType.rcsep,
  //                               modalTitle: 'RCSEP',
  //                             ),
  //                           )
  //                         : template['title'] == 'A73'
  //                             ? showDialog(
  //                                 context: context,
  //                                 builder: (context) =>
  //                                     const GenerateInventoryReportModal(
  //                                   generateInventoryReportType:
  //                                       GenerateInventoryReportType.rcppe,
  //                                   modalTitle: 'RCPPE',
  //                                 ),
  //                               )
  //                             : showCustomDocumentPreview(
  //                                 context: context,
  //                                 documentObject: null,
  //                                 docType: template['type'] as DocumentType,
  //                               ),
  //                 title: template['title'] as String,
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildPredefinedDocumentTemplatesRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Predefined templates',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 18.0,
              ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            Expanded(
              child: DocumentCard(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => const GenerateInventoryReportModal(
                    generateInventoryReportType:
                        GenerateInventoryReportType.rcpi,
                    modalTitle: 'RPCI',
                  ),
                ),
                title: 'RPCI',
              ),
            ),
            const SizedBox(
              width: 15.0,
            ),
            Expanded(
              child: DocumentCard(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => const GenerateInventoryReportModal(
                    generateInventoryReportType:
                        GenerateInventoryReportType.rcsep,
                    modalTitle: 'RSEP',
                  ),
                ),
                title: 'RSEP',
              ),
            ),
            const SizedBox(
              width: 15.0,
            ),
            Expanded(
              child: DocumentCard(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => const GenerateInventoryReportModal(
                    generateInventoryReportType:
                        GenerateInventoryReportType.rcppe,
                    modalTitle: 'RPPE',
                  ),
                ),
                title: 'RPPE',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'All Items Issued',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 18.0,
              ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFilterTableRow(),
            _buildActionButtons(),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      spacing: 10.0,
      children: [
        ExpandableSearchButton(controller: _searchController),
        _buildRefreshButton(),
        _buildFilterButton(),
        CustomFilledButton(
          onTap: () => context.go(
            RoutingConstants.nestedViewOfficerAccountabilityRoutePath,
          ),
          prefixWidget: const Icon(
            HugeIcons.strokeRoundedSearch01,
            size: 15.0,
            color: AppColor.lightPrimary,
          ),
          text: 'Find Accountability',
        ),
      ],
    );
  }

  Widget _buildFilterTableRow() {
    final Map<String, String> filterMapping = {
      'View All': '',
      'RIS': 'ris',
      'ICS': 'ics',
      'PAR': 'par',
    };
    return FilterTableRow(
      selectedFilterNotifier: _selectedFilterNotifier,
      filterMapping: filterMapping,
    );
  }

  Widget _buildRefreshButton() {
    return ReusableCustomRefreshOutlineButton(
      onTap: _refreshIssuanceList,
    );
  }

  Widget _buildFilterButton() {
    return CustomIconButton(
      tooltip: 'Filter',
      onTap: () => showDialog(
        context: context,
        builder: (context) => FilterByDateModal(
          title: 'Filter Issuance',
          subtitle: 'Filter issuances by the following parameters.',
          onApplyFilters: (
            DateTime? startDate,
            DateTime? endDate,
          ) {
            _selectedStartDate = startDate;
            _selectedEndDate = endDate;
            _fetchIssuances();
          },
          startDate: _selectedStartDate,
          endDate: _selectedEndDate,
        ),
      ),
      isOutlined: true,
      icon: FluentIcons.filter_add_20_regular,
    );
  }

  Widget _buildDataTable(bool isAdmin) {
    return BlocConsumer<IssuancesBloc, IssuancesState>(
      listener: (context, state) {
        if (state is IssuancesLoading) {
          _isLoading = true;
          _errorMessage = null;
        }

        if (state is MatchedItemWithPr || state is IssuanceLoaded) {
          _isLoading = false;
          _errorMessage = null;
        }

        if (state is ICSRegistered ||
            state is MultipleICSRegistered ||
            state is PARRegistered ||
            state is MultiplePARRegistered ||
            state is RISRegistered ||
            state is FetchedInventoryReport ||
            state is GeneratedSemiExpendablePropertyCardData ||
            state is ReceivedIssuance ||
            state is FetchedAccountableOfficerId ||
            state is FetchedOfficerAccountability ||
            state is ResolvedIssuanceItem) {
          _isLoading = false;
          _errorMessage = null;
          _refreshIssuanceList();
        }

        // if (state is IssuanceArchiveStatusUpdated &&
        //     state.isSuccessful == true) {
        //   _isLoading = false;
        //   _errorMessage = null;
        //   _refreshIssuanceList();
        //   DelightfulToastUtils.showDelightfulToast(
        //     context: context,
        //     title: 'Issuance Archived!',
        //     subtitle: 'Issuance was archived successfully.',
        //   );
        // }

        if (state is IssuanceArchiveStatusUpdated) {
          if (state.isSuccessful == true) {
            DelightfulToastUtils.showDelightfulToast(
              context: context,
              icon: Icons.check_circle_outline,
              title: 'Success',
              subtitle: 'Issuance archive status updated successfully.',
            );
            _refreshIssuanceList();
          } else {
            DelightfulToastUtils.showDelightfulToast(
              context: context,
              icon: Icons.error_outline,
              title: 'Failed',
              subtitle: 'Failed to update issuance authentication status.',
            );
          }
        }

        if (state is IssuancesLoaded) {
          _isLoading = false;
          _totalRecords = state.totalIssuancesCount;
          _tableRows.clear();
          _tableRows.addAll(state.issuances.map((issuance) {
            return TableData(
              id: issuance.id,
              columns: [
                Text(
                  issuance is InventoryCustodianSlipEntity
                      ? issuance.icsId
                      : issuance is PropertyAcknowledgementReceiptEntity
                          ? issuance.parId
                          : issuance is RequisitionAndIssueSlipEntity
                              ? issuance.risId
                              : 'N/A',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  capitalizeWord(
                      issuance.receivingOfficerEntity?.name ?? 'N/A'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  documentDateFormatter(issuance.issuedDate),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                SizedBox(
                  width: 50.0,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildStatusHighlighter(
                      issuance.status,
                    ),
                  ),
                ),
              ],
              menuItems: [
                // {
                //   'text': 'View',
                //   'icon': FluentIcons.eye_12_regular,
                // },
                // {
                //   'text': 'Manual Receive',
                //   'icon': HugeIcons.strokeRoundedPackageReceive,
                // },
                // {
                //   'text': 'Return',
                //   'icon': HugeIcons.strokeRoundedPackageReceive,
                // },
                if (isAdmin)
                  {
                    'text': 'Archive',
                    'icon': HugeIcons.strokeRoundedArchive,
                  },
                if (!isAdmin)
                  {
                    'text': 'Generate Issuance Document',
                    'icon': HugeIcons.strokeRoundedDocumentAttachment,
                  },

                if (!isAdmin && issuance is! RequisitionAndIssueSlipEntity)
                  {
                    'text': 'Generate Sticker',
                    'icon': HugeIcons.strokeRoundedDocumentAttachment,
                  },
                if (!isAdmin && issuance is! RequisitionAndIssueSlipEntity)
                  {
                    'text': 'Generate RIS Document',
                    'icon': HugeIcons.strokeRoundedDocumentAttachment,
                  },
                if (!isAdmin)
                  {
                    'text': 'Receive Issuance',
                    'icon': HugeIcons.strokeRoundedDownload04,
                  },
              ],
              object: issuance,
            );
          }).toList());
        }

        if (state is IssuancesError) {
          _isLoading = false;
          _errorMessage = state.message;
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: CustomDataTable(
                      config: _tableConfig.copyWith(
                        rows: _tableRows,
                      ),
                      onActionSelected: (index, action) {
                        final issuanceId = _tableRows[index].id;
                        final issuanceObj = _tableRows[index].object;
                        String? path;
                        final Map<String, dynamic> extras = {
                          'issuance_id': issuanceId,
                        };

                        if (action.isNotEmpty) {
                          if (action.contains('View')) {
                            path = RoutingConstants
                                .nestedViewItemIssuanceViewRoutePath;

                            context.go(
                              path,
                              extra: extras,
                            );
                          }

                          if (action.contains('Archive')) {
                            _issuancesBloc.add(
                              UpdateIssuanceArchiveStatusEvent(
                                id: issuanceId,
                                isArchived: true,
                              ),
                            );
                          }

                          if (action.contains('Generate Issuance Document')) {
                            showCustomDocumentPreview(
                              context: context,
                              documentObject: issuanceObj,
                              docType: issuanceObj
                                      is InventoryCustodianSlipEntity
                                  ? DocumentType.ics
                                  : issuanceObj
                                          is PropertyAcknowledgementReceiptEntity
                                      ? DocumentType.par
                                      : DocumentType.ris,
                              canGenerateExcel: issuanceObj
                                      is InventoryCustodianSlipEntity ||
                                  issuanceObj
                                      is PropertyAcknowledgementReceiptEntity ||
                                  issuanceObj is RequisitionAndIssueSlipEntity,
                            );
                          }

                          if (action.contains('Generate RIS Document')) {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  CreateExistingIssuanceToRISModal(
                                issuanceEntity: issuanceObj,
                              ),
                            );
                            // showCustomDocumentPreview(
                            //   context: context,
                            //   documentObject: issuanceObj,
                            //   docType: DocumentType.ris,
                            // );
                          }

                          if (action.contains('Generate Sticker')) {
                            print('Checking items...');
                            print(
                                'Items: ${issuanceObj.items.map((e) => e.runtimeType)}'); // Debugging step

                            if (issuanceObj.items.any(
                                (item) => item.itemEntity is SupplyEntity)) {
                              // Change to correct type
                              print(
                                  'SupplyModel found! Blocking sticker generation.');
                              DelightfulToastUtils.showDelightfulToast(
                                context: context,
                                icon: Icons.error_outline,
                                title: 'Error',
                                subtitle:
                                    'Failed to generate a sticker. This document contains a Supply item.',
                              );
                              return;
                            }

                            print(
                                'No SupplyEntity found, proceeding with sticker generation.');
                            showCustomDocumentPreview(
                              context: context,
                              documentObject: issuanceObj,
                              docType: DocumentType.sticker,
                            );
                          }

                          if (action.contains('Receive Issuance')) {
                            final issuanceEntity =
                                issuanceObj as IssuanceEntity;
                            final receivingOfficerEntity =
                                issuanceEntity.receivingOfficerEntity;

                            showDialog(
                              context: context,
                              builder: (context) => ReceiveIssuanceModal(
                                baseIssuanceId: issuanceEntity.id,
                                receivingOfficerOffice:
                                    receivingOfficerEntity?.officeName,
                                receivingOfficerPosition:
                                    receivingOfficerEntity?.positionName,
                                receivingOfficerName:
                                    receivingOfficerEntity?.name,
                                receivedDate: issuanceEntity.receivedDate,
                              ),
                            );
                          }

                          if (action.contains(
                              'Generate Semi-expendable Property Card')) {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  GenerateSemiExpendablePropertyCardModal(
                                ics: issuanceObj,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  if (_isLoading)
                    LinearProgressIndicator(
                      backgroundColor: Theme.of(context).dividerColor,
                      color: AppColor.accent,
                    ),
                  if (_errorMessage != null)
                    Center(
                      child: CustomMessageBox.error(
                        message: _errorMessage!,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            PaginationControls(
              currentPage: _currentPage,
              totalRecords: _totalRecords,
              pageSize: _pageSize,
              onPageChanged: (page) {
                _currentPage = page;
                _fetchIssuances();
              },
              onPageSizeChanged: (size) {
                _pageSize = size;
                _fetchIssuances();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusHighlighter(IssuanceStatus status) {
    return HighlightStatusContainer(
      statusStyle: _issuanceStatusStyler(status: status),
    );
  }

  StatusStyle _issuanceStatusStyler({
    required IssuanceStatus status,
  }) {
    switch (status) {
      case IssuanceStatus.unreceived:
        return StatusStyle.yellow(label: 'Pending');
      case IssuanceStatus.received:
        return StatusStyle.green(label: 'Received');
      case IssuanceStatus.returned:
        return StatusStyle.blue(label: 'Returned');
      case IssuanceStatus.cancelled:
        return StatusStyle.red(label: 'Cancelled');
    }
  }
}
