import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/common/components/custom_data_table.dart';
import '../../../../core/common/components/custom_message_box.dart';
import '../../../../core/common/components/pagination_controls.dart';
import '../../../../core/common/components/reusable_custom_refresh_outline_button.dart';
import '../../../../core/common/components/reusable_linear_progress_indicator.dart';
import '../../../../core/common/components/search_button/expandable_search_button.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../officer/presentation/bloc/officers_bloc.dart';

class ArchiveOfficersView extends StatefulWidget {
  const ArchiveOfficersView({super.key});

  @override
  State<ArchiveOfficersView> createState() => _ArchiveOfficersViewState();
}

class _ArchiveOfficersViewState extends State<ArchiveOfficersView> {
  late OfficersBloc _officersBloc;

  final _searchController = TextEditingController();
  final _searchDelay = const Duration(milliseconds: 500);
  Timer? _debounce;

  late TableConfig _tableConfig;
  final List<String> _tableHeaders = [
    //'Officer Id',
    'Name',
    'Office Name',
    'Position',
  ];
  late List<TableData> _tableRows = [];

  final ValueNotifier<String> _selectedFilterNotifier = ValueNotifier('');
  final ValueNotifier<int> _totalRecords = ValueNotifier(0);

  int _currentPage = 1;
  int _pageSize = 10;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _officersBloc = context.read<OfficersBloc>();

    _searchController.addListener(_onSearchChanged);

    _initializeTableConfig();
    _fetchOfficers();
  }

  void _initializeTableConfig() {
    _tableConfig = TableConfig(
      headers: _tableHeaders,
      rows: _tableRows,
      columnFlex: [
        //1,
        2,
        2,
        2,
      ],
    );
  }

  void _fetchOfficers() {
    _officersBloc.add(
      GetPaginatedOfficersEvent(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: _searchController.text,
        isArchived: true,
      ),
    );
  }

  void _refreshOfficerList() {
    _searchController.clear();
    _currentPage = 1;
    _fetchOfficers();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(_searchDelay, () {
      _currentPage = 1;
      _fetchOfficers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _totalRecords.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTableActionsRow(),
        const SizedBox(
          height: 20.0,
        ),
        Expanded(
          child: _buildDataTable(),
        ),
      ],
    );
  }

  Widget _buildTableActionsRow() {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.end, // MainAxisAlignment.spaceBetween,
      children: [
        // _buildFilterTableRow(),
        Row(
          children: [
            ExpandableSearchButton(
              controller: _searchController,
            ),
            const SizedBox(
              width: 10.0,
            ),
            ReusableCustomRefreshOutlineButton(
              onTap: _refreshOfficerList,
            ),
            const SizedBox(
              width: 10.0,
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildDataTable() {
    return BlocConsumer<OfficersBloc, OfficersState>(
      listener: (context, state) {
        if (state is OfficersLoading) {
          _isLoading = true;
          _errorMessage = null;
        }

        if (state is OfficersLoaded) {
          _isLoading = false;
          _totalRecords.value = state.totalOfficersCount;
          _tableRows.clear();
          _tableRows = state.officers.map((officer) {
            return TableData(
              id: officer.id,
              columns: [
                // Text(
                //   officer.id,
                //   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                //     fontSize: 14.0,
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
                Text(
                  capitalizeWord(officer.name),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  capitalizeWord(officer.officeName),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  capitalizeWord(officer.positionName),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              menuItems: [
                  {
                    'text': 'Unarchive',
                    'icon': HugeIcons.strokeRoundedArchive02,
                  },
              ],
            );
          }).toList();
        }

        if (state is OfficerRegistered) {
          print('triggered');
          DelightfulToastUtils.showDelightfulToast(
            context: context,
            icon: Icons.check_circle_outline,
            title: 'Success',
            subtitle: 'Officer added successfully.',
          );

          _refreshOfficerList();
        }

        if (state is OfficersArchiveStatusUpdated) {
          if (state.isSuccessful == true) {
            DelightfulToastUtils.showDelightfulToast(
              context: context,
              icon: Icons.check_circle_outline,
              title: 'Success',
              subtitle: 'Officer archive status updated successfully.',
            );
            _refreshOfficerList();
          } else {
            DelightfulToastUtils.showDelightfulToast(
              context: context,
              icon: Icons.error_outline,
              title: 'Failed',
              subtitle: 'Failed to update officer archive status.',
            );
          }
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
                        final officerId = _tableRows[index].id;

                        if (action.isNotEmpty) {
                          if (action.contains('Unarchive')) {
                            _officersBloc.add(
                              UpdateOfficerArchiveStatusEvent(
                                id: officerId,
                                isArchived: false,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  if (_isLoading) const ReusableLinearProgressIndicator(),
                  if (_errorMessage != null)
                    Center(
                      child: CustomMessageBox.error(message: _errorMessage!),
                    ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            PaginationControls(
              currentPage: _currentPage,
              totalRecords: _totalRecords.value,
              pageSize: _pageSize,
              onPageChanged: (page) {
                _currentPage = page;
                _fetchOfficers();
              },
              onPageSizeChanged: (size) {
                _pageSize = size;
                _fetchOfficers();
              },
            ),
          ],
        );
      },
    );
  }
}
