import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/custom_data_table.dart';
import '../../../../core/common/components/custom_icon_button.dart';
import '../../../../core/common/components/custom_message_box.dart';
import '../../../../core/common/components/custom_popup_menu.dart';
import '../../../../core/common/components/filter_table_row.dart';
import '../../../../core/common/components/highlight_status_container.dart';
import '../../../../core/common/components/pagination_controls.dart';
import '../../../../core/common/components/search_button/expandable_search_button.dart';
import '../../../../core/common/components/test_popup.dart';
import '../../../../core/enums/auth_status.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../bloc/users_management_bloc.dart';

class UsersManagementView extends StatefulWidget {
  const UsersManagementView({super.key});

  @override
  State<UsersManagementView> createState() => _UsersManagementViewState();
}

class _UsersManagementViewState extends State<UsersManagementView> {
  late UsersManagementBloc _usersManagementBloc;
  late final String _selectedSortValue = 'Account Creation';
  late String _selectedSortOrder = 'Descending';
  late AuthStatus? _selectedStatus = null;

  final _searchController = TextEditingController();
  final _searchDelay = const Duration(milliseconds: 500);
  Timer? _debounce;

  int _currentPage = 1;
  int _pageSize = 10;

  final ValueNotifier<int> _totalRecords = ValueNotifier(0);
  final ValueNotifier<String> _selectedFilterRole = ValueNotifier('');
  final ValueNotifier<bool> _trackFilterSelection = ValueNotifier(false);

  bool _isLoading = false;
  String? _errorMessage;

  late TableConfig _tableConfig;
  final List<String> _tableHeaders = [
    'User Id',
    'Name',
    'Email Address',
    'Created At',
    'Authentication Status',
  ];
  late List<TableData> _tableRows = [];

  @override
  void initState() {
    super.initState();
    _usersManagementBloc = context.read<UsersManagementBloc>();
    _searchController.addListener(_onSearchChanged);
    _selectedFilterRole.addListener(_onRoleFilterChanged);
    _initializeTableConfig();
    _fetchUsers();
  }

  void _initializeTableConfig() {
    _tableConfig = TableConfig(
      headers: _tableHeaders,
      rows: _tableRows,
      columnFlex: [
        2,
        2,
        2,
        2,
        2,
      ],
    );
  }

  void _fetchUsers() {
    _usersManagementBloc.add(
      FetchUsers(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: _searchController.text,
        sortBy: _selectedSortValue,
        sortAscending: _selectedSortOrder == 'Ascending',
        role: _selectedFilterRole.value,
        status: _selectedStatus,
      ),
    );
  }

  void _refreshUserList() {
    _searchController.clear();
    _selectedFilterRole.value = '';
    _selectedStatus = null;
    _currentPage = 1;
    _trackFilterSelection.value = false;
    _fetchUsers();
  }

  void _onRoleFilterChanged() {
    _searchController.clear();
    _selectedStatus = null;
    _currentPage = 1;
    _trackFilterSelection.value = false;
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
    _searchController.dispose();
    _debounce?.cancel();
    _selectedFilterRole.dispose();
    _trackFilterSelection.dispose();
    _totalRecords.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(
            height: 50.0,
          ),
          _buildDisplayUsersCount(),
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
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Management of user\'s access within the desktop and mobile systems.',
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
          ),
    );
  }

  Widget _buildDisplayUsersCount() {
    return ValueListenableBuilder(
      valueListenable: _totalRecords,
      builder: (context, totalRecords, child) {
        return RichText(
          text: TextSpan(
            text: 'All Users ',
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
            const SizedBox(
              width: 10,
            ),
            //_buildFilterButton(),
            _buildFilterStatusButton(),
            const SizedBox(
              width: 10,
            ),
            _buildSortOrderButton(),
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

  Widget _buildFilterButton() {
    return ValueListenableBuilder(
        valueListenable: _trackFilterSelection,
        builder: (context, trackFilterSelection, child) {
          return TestPopup(
            tooltip: 'Filter',
            items: const [
              {
                'text': 'Unauthenticated',
              },
              {
                'text': 'Authenticated',
              },
              {
                'text': 'Revoked',
              }
            ],
            onItemSelected: (selectedItem) {
              _trackFilterSelection.value = true;
              print('selected status: $selectedItem');
              _selectedStatus = AuthStatus.values.firstWhere((authStatus) =>
                  authStatus.toString().split('.').last.toLowerCase() ==
                  selectedItem.toLowerCase());
              _searchController.clear();
              _currentPage = 1;
              _fetchUsers();
            },
            initialItemSelected: _selectedStatus.toString(),
            icon: FluentIcons.filter_add_20_regular,
            isIconOutlined: true,
            trackSelection: trackFilterSelection,
          );
        });
  }

  Widget _buildFilterStatusButton() {
    return CustomMenuButton(
      tooltip: 'Filter',
      items: const [
        {
          'text': 'Unauthenticated',
          'icon': FluentIcons.lock_closed_key_16_regular
        },
        {'text': 'Authenticated', 'icon': FluentIcons.key_16_regular},
        {'text': 'Revoked', 'icon': FluentIcons.shield_keyhole_16_regular},
      ],
      onItemSelected: (selectedItem) {
        _selectedStatus = AuthStatus.values.firstWhere((authStatus) =>
            authStatus.toString().split('.').last.toLowerCase() ==
            selectedItem.toLowerCase());
        _searchController.clear();
        _currentPage = 1;
        _fetchUsers();
      },
      icon: FluentIcons.filter_add_20_regular,
    );
  }

  Widget _buildSortOrderButton() {
    return CustomMenuButton(
      tooltip: 'Sort',
      items: const [
        {
          'text': 'Ascending',
          'icon': FluentIcons.text_sort_ascending_16_regular
        },
        {
          'text': 'Descending',
          'icon': FluentIcons.text_sort_descending_16_regular
        }
      ],
      onItemSelected: (selectedItem) {
        print('selected order: $selectedItem');
        _selectedSortOrder = selectedItem;
        _fetchUsers();
      },
      icon: FluentIcons.text_sort_ascending_20_regular,
    );
  }

  Widget _buildDataTable() {
    return BlocConsumer<UsersManagementBloc, UsersManagementState>(
      listener: (context, state) {
        if (state is UsersLoading) {
          _isLoading = true;
          _errorMessage = null;
        }

        if (state is UsersLoaded) {
          _isLoading = false;
          _totalRecords.value = state.totalUserCount;
          _tableRows.clear();
          print('table rows b4 loaded: $_tableRows}');
          print('users after loaded: ${state.users}');
          _tableRows = state.users.map((user) {
            final List<Map<String, dynamic>> allMenuItems = [
              {
                'text': 'Unauthenticated',
                'icon': HugeIcons.strokeRoundedSecurityBlock,
                'status': AuthStatus.unauthenticated,
              },
              {
                'text': 'Authenticated',
                'icon': HugeIcons.strokeRoundedSecurityCheck,
                'status': AuthStatus.authenticated,
              },
              {
                'text': 'Revoked',
                'icon': HugeIcons.strokeRoundedSecurityLock,
                'status': AuthStatus.revoked,
              },
              {
                'text': 'Archive',
                'icon': HugeIcons.strokeRoundedArchive,
              },
            ];

            final filteredMenuItems = allMenuItems.where((item) {
              return item['status'] != user.authStatus;
            }).toList();

            return TableData(
              id: user.id,
              columns: [
                Text(
                  user.id,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400,
                      ),
                ),
                Text(
                  capitalizeWord(user.name),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  dateFormatter(user.createdAt),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400,
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
              menuItems: filteredMenuItems,
            );
          }).toList();
          print('table rows after loaded: ${_tableRows}');
        }

        if (state is UserAuthenticationStatusUpdated) {
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

        if (state is UserArchiveStatusUpdated) {
          if (state.isSuccessful == true) {
            DelightfulToastUtils.showDelightfulToast(
              context: context,
              icon: Icons.check_circle_outline,
              title: 'Success',
              subtitle: 'User archive status updated successfully.',
            );
            _refreshUserList();
          } else {
            DelightfulToastUtils.showDelightfulToast(
              context: context,
              icon: Icons.error_outline,
              title: 'Failed',
              subtitle: 'Failed to update user archive status.',
            );
          }
        }

        if (state is UsersError) {
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
                      onActionSelected: _onActionSelected,
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

  void _onActionSelected(int index, String action) {
    final userId = _tableRows[index].id;

    if (action == 'Unauthenticated' ||
        action == 'Authenticated' ||
        action == 'Revoked') {
      final authStatus = AuthStatus.values.firstWhere((authStatus) =>
          authStatus.toString().split('.').last.toLowerCase() ==
          action.toLowerCase());

      print('user id: $userId');
      _usersManagementBloc.add(
        UpdateUserAuthenticationStatus(
          userId: userId,
          authStatus: authStatus,
        ),
      );
    }

    if (action == 'Archive') {
      print('Archiving user id: $userId');
      _usersManagementBloc.add(
        UpdateArchiveStatus(
          userId: userId,
          isArchived: true,
        ),
      );
    }
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
