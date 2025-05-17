import 'dart:async';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/custom_data_table.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_icon_button.dart';
import '../../../../core/common/components/custom_message_box.dart';
import '../../../../core/common/components/filter_table_row.dart';
import '../../../../core/common/components/pagination_controls.dart';
import '../../../../core/common/components/reusable_custom_refresh_outline_button.dart';
import '../../../../core/common/components/reusable_linear_progress_indicator.dart';
import '../../../../core/common/components/search_button/expandable_search_button.dart';
import '../../../../core/enums/officer_status.dart';
import '../../../../core/enums/role.dart';
import '../../../../core/models/supply_department_employee.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../../core/utils/standardize_position_name.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/officer.dart';
import '../bloc/officers_bloc.dart';
import '../components/filter_officer_modal.dart';
import '../components/reusable_officer_modal.dart';
import '../components/view_officer_modal.dart';

// todo: implement filter
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

  final ValueNotifier<String> _selectedFilterNotifier =
      ValueNotifier(OfficerStatus.active.toString());
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
    _selectedFilterNotifier.addListener(_onFilterChanged);

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
    // Convert the selected filter value (String) to OfficerStatus enum
    final selectedStatus = OfficerStatus.values.firstWhere(
      (e) =>
          e.toString().split('.').last ==
          _selectedFilterNotifier.value.toString().split('.').last,
      orElse: () =>
          OfficerStatus.active, // Default to 'active' if no match is found
    );

    _officersBloc.add(
      GetPaginatedOfficersEvent(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: _searchController.text,
        office: _selectedOffice,
        status: selectedStatus, // Pass the correct OfficerStatus enum value
      ),
    );
  }

  void _refreshOfficerList() {
    _searchController.clear();
    _currentPage = 1;
    _selectedOffice = null;
    _selectedFilterNotifier.value = OfficerStatus.active.toString();
    _fetchOfficers();
  }

  void _onFilterChanged() {
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

  void _updateOfficerStatus({
    required String id,
    required OfficerStatus officerStatus,
  }) {
    _officersBloc.add(
      UpdateOfficerEvent(
        id: id,
        status: officerStatus,
      ),
    );
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildFilterTableRow(),
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

  // todo: to be implement
  Widget _buildFilterTableRow() {
    final Map<String, String> filterMapping = {
      'Active': OfficerStatus.active.toString(),
      'Suspended': OfficerStatus.suspended.toString(),
      'Resigned': OfficerStatus.resigned.toString(),
      'Retired': OfficerStatus.retired.toString(),
    };
    return FilterTableRow(
      selectedFilterNotifier: _selectedFilterNotifier,
      filterMapping: filterMapping,
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
              object: officer,
              columns: [
                Text(
                  capitalizeWord(officer.name),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
                Text(
                  capitalizeWord(officer.officeName),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
                Text(
                  standardizePositionName(officer.positionName),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ],
              menuItems: [
                {
                  'text': 'View',
                  'icon': HugeIcons.strokeRoundedEye,
                },
                if (!isAdmin)
                  {
                    'text': 'Edit',
                    'icon': FluentIcons.eye_20_regular,
                  },
                if (officer.status != OfficerStatus.active)
                  {
                    'text': 'Set status to active',
                    'icon': HugeIcons.strokeRoundedToggleOn,
                  },
                if (officer.status != OfficerStatus.suspended)
                  {
                    'text': 'Set status to suspended',
                    'icon': HugeIcons.strokeRoundedToggleOff,
                  },
                if (officer.status != OfficerStatus.resigned)
                  {
                    'text': 'Set status to resigned',
                    'icon': HugeIcons.strokeRoundedLogout01,
                  },
                if (officer.status != OfficerStatus.retired)
                  {
                    'text': 'Set status to retired',
                    'icon': HugeIcons.strokeRoundedUnavailable,
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

        if (state is UpdatedOfficer) {
          if (state.isSuccessful == true) {
            DelightfulToastUtils.showDelightfulToast(
              context: context,
              icon: Icons.check_circle_outline,
              title: 'Success',
              subtitle: 'Officer updated successfully.',
            );
            _refreshOfficerList();
          } else {
            DelightfulToastUtils.showDelightfulToast(
              context: context,
              icon: Icons.error_outline,
              title: 'Failed',
              subtitle: 'Failed to update officer.',
            );
          }
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
                        final officerObj =
                            _tableRows[index].object as OfficerEntity;

                        if (action.isNotEmpty) {
                          if (action.contains('Archive')) {
                            _officersBloc.add(
                              UpdateOfficerArchiveStatusEvent(
                                id: officerId,
                                isArchived: true,
                              ),
                            );
                          }

                          if (action.contains('View')) {
                            showDialog(
                              context: context,
                              builder: (context) => ViewOfficerModal(
                                officerEntity: _tableRows[index].object,
                              ),
                            );
                          }

                          if (action.contains('Edit')) {
                            showDialog(
                              context: context,
                              builder: (context) => ReusableOfficerModal(
                                officerEntity: officerObj,
                              ),
                            );
                          }

                          if (action.contains('Set status to active')) {
                            _updateOfficerStatus(
                              id: officerId,
                              officerStatus: OfficerStatus.active,
                            );
                          }

                          if (action.contains('Set status to suspended')) {
                            _updateOfficerStatus(
                              id: officerId,
                              officerStatus: OfficerStatus.suspended,
                            );
                          }

                          if (action.contains('Set status to resigned')) {
                            _updateOfficerStatus(
                              id: officerId,
                              officerStatus: OfficerStatus.resigned,
                            );
                          }

                          if (action.contains('Set status to retired')) {
                            _updateOfficerStatus(
                              id: officerId,
                              officerStatus: OfficerStatus.retired,
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
