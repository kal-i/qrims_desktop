import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/app_routing_constants.dart';
import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/custom_icon_button.dart';
import '../../../../core/common/components/custom_message_box.dart';
import '../../../../core/common/components/filter_by_date_modal.dart';
import '../../../../core/common/components/filter_table_row.dart';
import '../../../../core/common/components/highlight_status_container.dart';
import '../../../../core/common/components/pagination_controls.dart';
import '../../../../core/common/components/reusable_custom_refresh_outline_button.dart';
import '../../../../core/common/components/search_button/expandable_search_button.dart';
import '../../../../core/enums/document_type.dart';
import '../../../../core/enums/role.dart';
import '../../../../core/models/supply_department_employee.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/common/components/custom_data_table.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/issuances_bloc.dart';
import '../components/create_ics_modal.dart';
import '../components/create_par_modal.dart';
import '../components/custom_document_preview.dart';
import '../components/custom_interactable_card.dart';
import '../components/document_card.dart';

class ItemIssuanceView extends StatefulWidget {
  const ItemIssuanceView({super.key});

  @override
  State<ItemIssuanceView> createState() => _ItemIssuanceViewState();
}

class _ItemIssuanceViewState extends State<ItemIssuanceView> {
  late IssuancesBloc _issuancesBloc;

  late DateTime? _selectedStartDate;
  late DateTime? _selectedEndDate;

  final _searchController = TextEditingController();
  final _searchDelay = const Duration(milliseconds: 500);
  Timer? _debounce;

  late TableConfig _tableConfig;
  final List<String> _tableHeaders = [
    'Issuance ID',
    'PR No',
    'Requesting Officer Name',
    'Status',
  ];
  late List<TableData> _tableRows = [];

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
    _searchController.addListener(_onSearchChanged);
    _selectedFilterNotifier.addListener(_fetchIssuances);

    _selectedStartDate = null;
    _selectedEndDate = null;

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
      body: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
        bool isAdmin = false;

        if (state is AuthSuccess) {
          isAdmin = SupplyDepartmentEmployeeModel.fromEntity(state.data).role ==
              Role.admin;
        }

        return Column(
          children: [
            _buildClickableCardsRow(isAdmin),
            const SizedBox(
              height: 50.0,
            ),
            _buildRecentlyGeneratedDocumentsRow(),
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
      }),
    );
  }

  Widget _buildClickableCardsRow(bool isAdmin) {
    return Row(
      children: [
        Expanded(
          child: CustomInteractableCard(
            name: 'New Issuance',
            icon: CupertinoIcons.folder,
            onTap: () {},
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
                    builder: (context) => const CreateIcsModal(),
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
                    builder: (context) => const CreateParModal(),
                  ),
          ),
        ),
      ],
    );
  }

  // todo: for this, imma fetch few info in the server like the id, file/issuance name, and if possible size
  // this will then make an http req when wanna be previewed
  // every time there is a new issuance, it will first the first 3 item issuance info in the db and paste in here
  // btw let's add an stepper for the status like: prepared a doc for approval - approved/ declined - conclusion if there is like generated
  Widget _buildRecentlyGeneratedDocumentsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Recently generated documents',
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
              /// todo: rpci
              child: DocumentCard(
                onTap: () {
                  showCustomDocumentPreview(
                    context: context,
                    documentObject: null,
                    docType: DocumentType.rpci,
                  );
                },
              ),
            ),
            const SizedBox(
              width: 15.0,
            ),
            Expanded(

                /// todo: a73
                child: DocumentCard(
              onTap: () {},
            )),
            const SizedBox(
              width: 15.0,
            ),
            Expanded(
                child: DocumentCard(
              onTap: () {},
            )),
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
      children: [
        ExpandableSearchButton(controller: _searchController),
        const SizedBox(
          width: 10.0,
        ),
        _buildRefreshButton(),
        const SizedBox(
          width: 10.0,
        ),
        _buildFilterButton(),
        const SizedBox(
          width: 10.0,
        ),
        //_buildSortButton(),
      ],
    );
  }

  Widget _buildFilterTableRow() {
    final Map<String, String> filterMapping = {
      'View All': '',
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

  Widget _buildSortButton() {
    return const CustomIconButton(
      icon: FluentIcons.text_sort_ascending_20_regular,
      isOutlined: true,
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

        if (state is ICSRegistered || state is PARRegistered) {
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
                  issuance.id,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  issuance.purchaseRequestEntity.id,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  capitalizeWord(issuance.receivingOfficerEntity.name),
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
                      issuance.isReceived,
                    ),
                  ),
                ),
              ],
              menuItems: [
                {
                  'text': 'View',
                  'icon': FluentIcons.eye_12_regular,
                },
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
                if (!isAdmin)
                  {
                    'text': 'Generate RIS Document',
                    'icon': HugeIcons.strokeRoundedDocumentAttachment,
                  },
                if (!isAdmin)
                  {
                    'text': 'Generate Sticker',
                    'icon': HugeIcons.strokeRoundedDocumentAttachment,
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

                          // if (action.contains('Generate Issuance Document')) {
                          //   showCustomDocumentPreview(
                          //       context: context,
                          //       documentObject: _tableRows[index].object,
                          //       docType: DocumentType);
                          // }

                          if (action.contains('Generate RIS Document')) {
                            showCustomDocumentPreview(
                              context: context,
                              documentObject: _tableRows[index].object,
                              docType: DocumentType.ris,
                            );
                          }

                          if (action.contains('Generate Sticker')) {
                            showCustomDocumentPreview(
                              context: context,
                              documentObject: _tableRows[index].object,
                              docType: DocumentType.sticker,
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

  Widget _buildStatusHighlighter(bool isReceived) {
    return HighlightStatusContainer(
      statusStyle: _issuanceStatusStyler(isReceived: isReceived),
    );
  }

  StatusStyle _issuanceStatusStyler({required bool isReceived}) {
    if (isReceived) {
      return StatusStyle.green(label: 'Received');
    } else {
      return StatusStyle.yellow(label: 'To be receive');
    }
  }
}
