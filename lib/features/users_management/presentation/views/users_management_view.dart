import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/base_container.dart';
import '../../../../core/common/components/custom_icon_button.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/common/components/error_message_container.dart';
import '../../../../core/common/components/pagination_controls.dart';
import '../../../../core/common/components/reusable_data_table.dart';
import '../../../../core/common/components/reusable_popup_menu_button.dart';
import '../../../../core/common/components/search_button/expandable_search_button.dart';
import '../../../../core/constants/assets_path.dart';
import '../../../../core/enums/auth_status.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../bloc/users_management_bloc.dart';
import '../components/auth_status_cell_renderer.dart';

// View to manage users with sorting, searching, and pagination features
class UsersManagementView extends StatefulWidget {
  const UsersManagementView({super.key});

  @override
  State<UsersManagementView> createState() => _UsersManagementViewState();
}

class _UsersManagementViewState extends State<UsersManagementView> {
  final List<DataColumn2> _columns = [];
  final List<DataRow2> _rows = [];
  late UsersManagementBloc _usersManagementBloc;

  // Sorting and filtering options
  late String _selectedSortValue = 'Account Creation';
  late String _selectedSortOrder = 'Descending';
  late String _filterValue = '';

  final _searchController = TextEditingController();
  final _searchDelay = const Duration(milliseconds: 500);
  Timer? _debounce;

  int _currentPage = 1;
  int _pageSize = 10;
  int _totalRecords = 0;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _usersManagementBloc = context.read<UsersManagementBloc>();
    _initializeColumns();
    _searchController.addListener(_onSearchChanged);
    _fetchUsers();
  }

  void _initializeColumns() {
    _columns.addAll(
      [
        const DataColumn2(
          label: Text('User Id'),
          size: ColumnSize.S,
        ),
        const DataColumn2(
          label: Text('Name'),
          size: ColumnSize.L,
        ),
        const DataColumn2(
          label: Text('Email Address'),
        ),
        const DataColumn2(
          label: Text('Created At'),
        ),
        const DataColumn2(
          label: Text('Authentication Status'),
        ),
      ],
    );
  }

  // Fetch users with async pagination
  void _fetchUsers() {
    _usersManagementBloc.add(
      FetchUsers(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: _searchController.text,
        sortBy: _selectedSortValue,
        sortAscending: _selectedSortOrder == 'Ascending',
        filter: _filterValue,
      ),
    );
  }

  void _refreshUserList() {
    _searchController.clear();
    _filterValue = '';
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
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Management of user\'s access within the desktop and mobile systems.',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
        ),
        const SizedBox(
          height: 50.0,
        ),
        Expanded(
          flex: 6,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'All Users ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 18.0,
                          ),
                      children: [
                        TextSpan(
                          text: '17',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 18.0,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  _buildActionsRow(),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              Expanded(
                child: _buildDataTable(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsRow() {
    return Row(
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
        _buildFilterButton(),
        const SizedBox(
          width: 10,
        ),
        _buildSortButton(),
      ],
    );
  }

  Widget _buildRefreshButton() {
    return CustomIconButton(
      onTap: _refreshUserList,
      tooltip: 'Refresh',
      icon: CupertinoIcons.arrow_2_circlepath,
    );
  }

  Widget _buildFilterButton() {
    return ReusablePopupMenuButton(
      onSelected: _onFilterSelected,
      popupMenuItems: _buildFilterMenuItems(),
      tooltip: 'Filter',
      icon: const CustomIconButton(
        icon: Icons.tune,
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildFilterMenuItems() {
    return [
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: '',
        title: 'Filter by:',
      ),
      const PopupMenuDivider(
        height: .3,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: '',
        title: 'User Type:',
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: 'supply',
        title: 'Supply Department Employee',
        icon: CupertinoIcons.cube_box,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: 'mobile',
        title: 'Mobile User',
        icon: CupertinoIcons.device_phone_portrait,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: '',
        title: 'Authentication Status:',
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: 'unauthenticated',
        title: 'Unauthenticated',
        icon: Icons.lock_outline,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: 'authenticated',
        title: 'Authenticated',
        icon: Icons.vpn_key_outlined,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: 'revoked',
        title: 'Revoked',
        icon: Icons.vpn_key_off_outlined,
      ),
    ];
  }

  void _onFilterSelected(String? value) {
    print(value);
    if (value != null && value.isNotEmpty) {
      _searchController.clear();
      _currentPage = 1;
      _filterValue = value;
      _fetchUsers();
    }
  }

  Widget _buildSortButton() {
    return ReusablePopupMenuButton(
      onSelected: _onSortSelected,
      tooltip: 'Sort',
      icon: const CustomIconButton(icon: CupertinoIcons.arrow_up_arrow_down),
      popupMenuItems: _buildSortMenuItems(),
    );
  }

  List<PopupMenuEntry<String>> _buildSortMenuItems() {
    return [
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: '',
        title: 'Sort by:',
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: 'User Id',
        title: 'User Id',
        icon: Icons.person_2_outlined,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: 'Account Creation',
        title: 'Account Creation',
        icon: CupertinoIcons.calendar, // CupertinoIcons.chart_bar_alt_fill
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: '',
        title: 'Sort order:',
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        leading: RadioMenuButton<String>(
          value: 'Ascending',
          groupValue: _selectedSortOrder,
          onChanged: (value) {
            if (value != null) {
              _selectedSortOrder = value;
              _fetchUsers();
              // todo: temp sol is to close after picking a sort order val since ui changes do not reflect
              context.pop();
            }
          },
          child: Text(
            'Ascending',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ), // widget instead
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        leading: RadioMenuButton(
          value: 'Descending',
          groupValue: _selectedSortOrder,
          onChanged: (value) {
            if (value != null) {
              _selectedSortOrder = value;
              _fetchUsers();
              context.pop();
            }
          },
          child: Text(
            'Descending',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    ];
  }

  void _onSortSelected(String? value) {
    if (value != null && value.isNotEmpty) {
      // _searchController.clear();
      // _currentPage = 1;
      _selectedSortValue = value;
      _fetchUsers();
    }
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
          _totalRecords = state.totalUserCount;
          _rows.clear();
          _rows.addAll(
            state.users.map(
              (user) => DataRow2(
                cells: [
                  DataCell(Text(user.id.toString())),
                  DataCell(Text(capitalizeWord(user.name))),
                  DataCell(Text(user.email)),
                  DataCell(Text(dateFormatter(user.createdAt))),
                  DataCell(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: user.authStatus == AuthStatus.unauthenticated
                                ? AppColor.pastelOrange
                                : user.authStatus == AuthStatus.authenticated
                                    ? AppColor.pastelGreen
                                    : user.authStatus == AuthStatus.revoked
                                        ? AppColor.pastelRed
                                        : AppColor.pastelViolet,
                          ),
                          child: Text(
                            user.authStatus.toString().split('.').last,
                            style: const TextStyle(
                              color: AppColor.darkPrimary,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        AuthStatusCellRenderer(onStatusChanged: (newStatus) {
                          _usersManagementBloc.add(
                            UpdateUserAuthenticationStatus(
                              userId: user.id,
                              authStatus: newStatus,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
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

        if (state is UsersError) {
          _isLoading = false;
          _errorMessage = state.message;
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // DataTable2
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: ReusableDataTable(
                        columns: _columns,
                        rows: _rows,
                      ),
                    ),
                  ),
                  if (_isLoading)
                    Container(
                      height: 2.0,
                      color: AppColor.accent, // Use your theme color
                    ),
                  if (_errorMessage != null)
                    Center(
                      child: ErrorMessageContainer(
                        errorMessage: _errorMessage!,
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
              totalRecords: _totalRecords,
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
}
