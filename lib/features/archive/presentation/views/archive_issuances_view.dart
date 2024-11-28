import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/app_routing_constants.dart';
import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/custom_data_table.dart';
import '../../../../core/common/components/custom_icon_button.dart';
import '../../../../core/common/components/custom_message_box.dart';
import '../../../../core/common/components/filter_table_row.dart';
import '../../../../core/common/components/highlight_status_container.dart';
import '../../../../core/common/components/pagination_controls.dart';
import '../../../../core/common/components/reusable_custom_refresh_outline_button.dart';
import '../../../../core/common/components/search_button/expandable_search_button.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../item_issuance/presentation/bloc/issuances_bloc.dart';

class ArchiveIssuancesView extends StatefulWidget {
  const ArchiveIssuancesView({super.key});

  @override
  State<ArchiveIssuancesView> createState() => _ArchiveIssuancesViewState();
}

class _ArchiveIssuancesViewState extends State<ArchiveIssuancesView> {
  late IssuancesBloc _issuancesBloc;

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
        //issueDateStart: issueDateStart,
        //issueDateEnd: issueDateEnd,
        type: _selectedFilterNotifier.value,
        isArchived: true,
      ),
    );
  }

  void _refreshIssuanceList() {
    _searchController.clear();
    _currentPage = 1;

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
      body: Column(
        children: [
          _buildActionsRow(),
          const SizedBox(
            height: 20.0,
          ),
          Expanded(
            child: _buildDataTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Archived Issuances',
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
        // const SizedBox(
        //   width: 10.0,
        // ),
        // _buildFilterButton(),
        // const SizedBox(
        //   width: 10.0,
        // ),
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
    return const CustomIconButton(
      icon: FluentIcons.filter_add_20_regular,
      isOutlined: true,
    );
  }

  Widget _buildDataTable() {
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
                // {
                //   'text': 'Manual Receive',
                //   'icon': HugeIcons.strokeRoundedPackageReceive,
                // },
                // {
                //   'text': 'Return',
                //   'icon': HugeIcons.strokeRoundedPackageReceive,
                // },
                {
                  'text': 'Unarchive',
                  'icon': HugeIcons.strokeRoundedArchive,
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
                          if (action.contains('Unarchive')) {
                            _issuancesBloc.add(
                              UpdateIssuanceArchiveStatusEvent(
                                id: issuanceId,
                                isArchived: false,
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
