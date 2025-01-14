import 'dart:async';
import 'package:dio/dio.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/custom_data_table.dart';
import '../../../../core/common/components/custom_dropdown_button.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_icon_button.dart';
import '../../../../core/common/components/custom_labeled_text_box.dart';
import '../../../../core/common/components/custom_message_box.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/common/components/custom_search_box.dart';
import '../../../../core/common/components/filter_table_row.dart';
import '../../../../core/common/components/pagination_controls.dart';
import '../../../../core/common/components/reusable_custom_refresh_outline_button.dart';
import '../../../../core/common/components/reusable_linear_progress_indicator.dart';
import '../../../../core/common/components/search_button/expandable_search_button.dart';
import '../../../../core/common/components/slideable_container.dart';
import '../../../../core/enums/role.dart';
import '../../../../core/models/supply_department_employee.dart';
import '../../../../core/services/officer_suggestions_service.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/components/custom_outline_button.dart';
import '../bloc/officers_bloc.dart';
import '../components/dropdown_action_button.dart';
import '../components/filter_officer_modal.dart';
import '../components/reusable_officer_modal.dart';

class OfficersManagementView extends StatefulWidget {
  const OfficersManagementView({super.key});

  @override
  State<OfficersManagementView> createState() => _OfficersManagementViewState();
}

class _OfficersManagementViewState extends State<OfficersManagementView> {
  late OfficersBloc _officersBloc;

  late String? _selectedOffice;

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
    _selectedOffice = null;

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
        office: _selectedOffice,
      ),
    );
  }

  void _refreshOfficerList() {
    _searchController.clear();
    _currentPage = 1;
    _selectedOffice = null;
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
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      bool isAdmin = false;

      if (state is AuthSuccess) {
        isAdmin = SupplyDepartmentEmployeeModel.fromEntity(state.data).role ==
            Role.admin;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(
            height: 50.0,
          ),
          _buildActionsRow(isAdmin),
          const SizedBox(
            height: 30.0,
          ),
          _buildTableActionsRow(),
          const SizedBox(
            height: 20.0,
          ),
          Expanded(
            child: _buildDataTable(isAdmin),
          ),
        ],
      );
    });
  }

  Widget _buildHeader() {
    return Text(
      'Management of officers involved with in item issuance process and document reports.',
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
          ),
    );
  }

  Widget _buildActionsRow(bool isAdmin) {
    final actionTexts = [
      'Add Officer',
      'Add Office',
      'Add Position',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // DropdownActionButton(
        //   actionTexts: actionTexts,
        //   onActionSelected: _handleActionSelection,
        // ),
        if (isAdmin)
          const CustomMessageBox.info(
            message: 'You can only view.',
          )
        else
          CustomFilledButton(
            width: 160.0,
            height: 40.0,
            onTap: () => showDialog(
              context: context,
              builder: (context) => const ReusableOfficerModal(),
            ),
            prefixWidget: const Icon(
              HugeIcons.strokeRoundedUserAdd01,
              size: 15.0,
              color: AppColor.lightPrimary,
            ),
            text: 'Add Officer',
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
            _buildFilterButton(),
            // const SizedBox(
            //   width: 10.0,
            // ),
            // _buildMoreButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterButton() {
    return CustomIconButton(
      tooltip: 'Filter',
      onTap: () => showDialog(
        context: context,
        builder: (context) => FilterOfficerModal(
          onApplyFilters: (
            String? office,
          ) {
            _selectedOffice = office;
            _fetchOfficers();
          },
          office: _selectedOffice,
        ),
      ),
      isOutlined: true,
      icon: FluentIcons.filter_add_20_regular,
    );
  }

  Widget _buildMoreButton() {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      //elevation: 8.0,
      icon: const CustomIconButton(
        tooltip: 'More',
        icon: HugeIcons.strokeRoundedMoreHorizontal,
        isOutlined: true,
      ),
      onSelected: (action) {
        if (action != null) {}
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            child: ListTile(
              leading: const Icon(
                HugeIcons.strokeRoundedOffice,
                size: 16.0,
              ),
              title: Text(
                'Offices',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ),
          ),
          PopupMenuItem(
            child: ListTile(
              leading: const Icon(
                HugeIcons.strokeRoundedOffice,
                size: 16.0,
              ),
              title: Text(
                'Positions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ),
          ),
        ];
      },
    );
  }

  Widget _buildDataTable(bool isAdmin) {
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
                if (!isAdmin)
                  {
                    'text': 'Edit',
                    'icon': FluentIcons.eye_20_regular,
                  },
                if (isAdmin)
                  {
                    'text': 'Archive',
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
                          if (action.contains('Archive')) {
                            _officersBloc.add(
                              UpdateOfficerArchiveStatusEvent(
                                id: officerId,
                                isArchived: true,
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
