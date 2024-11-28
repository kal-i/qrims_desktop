import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/custom_data_table.dart';
import '../../../../core/common/components/custom_icon_button.dart';
import '../../../../core/common/components/custom_message_box.dart';
import '../../../../core/common/components/filter_table_row.dart';
import '../../../../core/common/components/highlight_status_container.dart';
import '../../../../core/common/components/pagination_controls.dart';
import '../../../../core/common/components/search_button/expandable_search_button.dart';
import '../../../../core/enums/auth_status.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../bloc/archive_user_bloc/archive_users_bloc.dart';

class ArchiveUsersView extends StatefulWidget {
  const ArchiveUsersView({super.key});

  @override
  State<ArchiveUsersView> createState() => _ArchiveUsersViewState();
}

class _ArchiveUsersViewState extends State<ArchiveUsersView> {
  late ArchiveUsersBloc _archiveUsersBloc;
  late AuthStatus? _selectedStatus = null;

  final _searchController = TextEditingController();
  final _searchDelay = const Duration(milliseconds: 500);
  Timer? _debounce;

  int _currentPage = 1;
  int _pageSize = 10;

  final ValueNotifier<int> _totalRecords = ValueNotifier(0);
  final ValueNotifier<String> _selectedFilterRole = ValueNotifier('');
  //final ValueNotifier<bool> _trackFilterSelection = ValueNotifier(false);

  final bool _isArchived = true;
  bool _isLoading = false;
  String? _errorMessage;

  late TableConfig _tableConfig;
  final List<String> _tableHeaders = [
    //'User Id',
    'Name',
    'Email Address',
    'Created At',
    'Authentication Status',
  ];
  late List<TableData> _tableRows = [];

  @override
  void initState() {
    _archiveUsersBloc = context.read<ArchiveUsersBloc>();
    _searchController.addListener(_onSearchChanged);
    _selectedFilterRole.addListener(_onRoleFilterChanged);
    _fetchUsers();
    _initializeTableConfig();
    super.initState();
  }

  void _initializeTableConfig() {
    _tableConfig = TableConfig(
      headers: _tableHeaders,
      rows: _tableRows,
      columnFlex: [
        //1,
        2,
        2,
        1,
        2,
      ],
    );
  }

  void _fetchUsers() {
    _archiveUsersBloc.add(
      GetArchivedUsersEvent(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: _searchController.text,
        role: _selectedFilterRole.value,
        authStatus: _selectedStatus,
        isArchived: _isArchived,
      ),
    );
  }

  void _refreshUserList() {
    _searchController.clear();
    _selectedFilterRole.value = '';
    _selectedStatus = AuthStatus.revoked;
    _currentPage = 1;
    //_trackFilterSelection.value = false;
    _fetchUsers();
  }

  void _onRoleFilterChanged() {
    _selectedStatus = AuthStatus.revoked;
    _searchController.clear();
    _currentPage = 1;
    _fetchUsers();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(_searchDelay, () {
      _currentPage = 1;
      _fetchUsers();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDisplayArchivedUsersCount(),
        const SizedBox(
          height: 20.0,
        ),
        _buildActionsRow(),
        const SizedBox(
          height: 20.0,
        ),
        Expanded(
          child: _buildDataTable(),
        ),
      ],
    );
  }

  Widget _buildDisplayArchivedUsersCount() {
    return ValueListenableBuilder(
      valueListenable: _totalRecords,
      builder: (context, totalRecords, child) {
        return RichText(
          text: TextSpan(
            text: 'Archived Users ',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18.0,
                ),
            children: [
              TextSpan(
                text: totalRecords.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 18.0,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildFilterTableRow(),
        Row(
          children: [
            ExpandableSearchButton(
              controller: _searchController,
            ),
            const SizedBox(
              width: 10,
            ),
            _buildRefreshButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterTableRow() {
    final Map<String, String> filterMapping = {
      'View All': '',
      'Supply': 'supply',
      'Mobile': 'mobile',
    };

    return FilterTableRow(
      selectedFilterNotifier: _selectedFilterRole,
      filterMapping: filterMapping,
    );
  }

  Widget _buildRefreshButton() {
    return CustomIconButton(
      onTap: _refreshUserList,
      tooltip: 'Refresh',
      icon: FluentIcons.arrow_clockwise_dashes_20_regular,
      isOutlined: true,
    );
  }

  Widget _buildDataTable() {
    return BlocConsumer<ArchiveUsersBloc, ArchiveUsersState>(
      listener: (context, state) {
        if (state is ArchivedUsersLoading) {
          _isLoading = true;
          _errorMessage = null;
        }

        if (state is ArchivedUsersLoaded) {
          _isLoading = false;
          _totalRecords.value = state.totalUserCount;
          _tableRows.clear();
          print('table rows b4 loaded: $_tableRows}');
          print('users after loaded: ${state.users}');
          _tableRows = state.users
              .map(
                (user) => TableData(
                  id: user.id,
                  columns: [
                    // Text(
                    //   user.id.toString(),
                    //   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    //     fontSize: 14.0,
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                    Text(
                      capitalizeWord(user.name),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      dateFormatter(user.createdAt),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      width: 50.0,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _buildStatusHighlighter(user.authStatus),
                      ),
                    ),
                  ],
                  menuItems: [
                    {
                      'text': 'Unarchive',
                      'icon': HugeIcons.strokeRoundedArchive
                    }
                  ],
                ),
              )
              .toList();
          print('table rows after loaded: ${_tableRows}');
        }

        if (state is UserArchiveStatusUpdated) {
          if (state.isSuccessful == true) {
            DelightfulToastUtils.showDelightfulToast(
              context: context,
              icon: Icons.check_circle_outline,
              title: 'Success',
              subtitle: 'User authentication status updated successfully.',
            );
            _refreshUserList();
          } else {
            DelightfulToastUtils.showDelightfulToast(
              context: context,
              icon: Icons.error_outline,
              title: 'Failed',
              subtitle: 'Failed to update user authentication status.',
            );
          }
        }

        if (state is ArchivedUsersError) {
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
                        print('row index: $index - $action');
                        final userId = _tableRows[index].id;
                        final authStatus = action.toLowerCase() == 'archive'
                            ? AuthStatus.revoked
                            : action.toLowerCase() == 'unarchive'
                                ? AuthStatus.authenticated
                                : null;

                        if (authStatus != null) {
                          print('user id: $userId - auth status: $authStatus');
                          _archiveUsersBloc.add(
                            UpdateUserArchiveStatusEvent(
                              userId: userId,
                              isArchived: false,
                            ),
                          );
                        } else {
                          print('Invalid action selected.');
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
              height: 10,
            ),

            // Pagination Controls
            PaginationControls(
              currentPage: _currentPage,
              totalRecords: _totalRecords.value,
              pageSize: _pageSize,
              onPageChanged: (page) {
                _currentPage = page;
                _fetchUsers();
              },
              onPageSizeChanged: (size) {
                _pageSize = size;
                _fetchUsers();
              },
            ),
          ],
        );
      },
    );
  }

  StatusStyle _authStatusStyler(AuthStatus authStatus) {
    switch (authStatus) {
      case AuthStatus.authenticated:
        return StatusStyle.green(label: 'Authenticated');
      case AuthStatus.unauthenticated:
        return StatusStyle.yellow(label: 'Unauthenticated');
      case AuthStatus.revoked:
        return StatusStyle.red(label: 'Archived');
      default:
        return StatusStyle.red(label: 'Error');
    }
  }

  Widget _buildStatusHighlighter(AuthStatus authStatus) {
    return HighlightStatusContainer(
      statusStyle: _authStatusStyler(authStatus),
    );
  }
}
