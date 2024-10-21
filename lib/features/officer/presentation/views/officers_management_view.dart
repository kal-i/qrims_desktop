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
import '../../../../core/services/officer_suggestions_service.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/components/custom_outline_button.dart';
import '../bloc/officers_bloc.dart';
import '../components/dropdown_action_button.dart';

class OfficersManagementView extends StatefulWidget {
  const OfficersManagementView({super.key});

  @override
  State<OfficersManagementView> createState() => _OfficersManagementViewState();
}

class _OfficersManagementViewState extends State<OfficersManagementView> {
  late OfficersBloc _officersBloc;
  late OfficerSuggestionsService _officerSuggestionsService;

  final _formKey = GlobalKey<FormState>();
  final _officeNameController = TextEditingController();
  final _positionNameController = TextEditingController();
  final _nameController = TextEditingController();

  final _searchController = TextEditingController();
  final _searchDelay = const Duration(milliseconds: 500);
  Timer? _debounce;

  late TableConfig _tableConfig;
  final List<String> _tableHeaders = [
    'Officer Id',
    'Name',
    'Office Name',
    'Position',
  ];
  late List<TableData> _tableRows = [];

  final ValueNotifier<String> _selectedFilterNotifier = ValueNotifier('');
  final ValueNotifier<int> _totalRecords = ValueNotifier(0);
  final ValueNotifier<bool> _isModalVisible = ValueNotifier(false);
  final ValueNotifier<String?> _selectedOfficeName = ValueNotifier(null);

  int _currentPage = 1;
  int _pageSize = 10;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _officersBloc = context.read<OfficersBloc>();
    _officerSuggestionsService = serviceLocator<OfficerSuggestionsService>();

    _searchController.addListener(_onSearchChanged);

    _initializeTableConfig();
    _fetchOfficers();
  }

  void _initializeTableConfig() {
    _tableConfig = TableConfig(
      headers: _tableHeaders,
      rows: _tableRows,
      columnFlex: [
        1,
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

  void _addOfficer() {
    if (_formKey.currentState!.validate()) {
      _officersBloc.add(
        RegisterOfficerEvent(
          name: _nameController.text,
          officeName: _officeNameController.text,
          positionName: _positionNameController.text,
        ),
      );

      _nameController.clear();
      _officeNameController.clear();
      _positionNameController.clear();

      _selectedOfficeName.value = null;

      _isModalVisible.value = false;
    }
  }

  Future<List<String>?> _officeSuggestionCallback(String? officeName) async {
    final offices = await _officerSuggestionsService.fetchOffices(
      officeName: officeName,
    );

    if (offices == null) {
      _positionNameController.clear();
      _selectedOfficeName.value = null;
    }

    return offices;
  }

  void _onOfficeSelected(String value) {
    _officeNameController.text = value;
    _positionNameController.clear();
    _selectedOfficeName.value = value;
  }

  Future<List<String>?> _positionSuggestionCallback(String? positionName) async {

  }

  void _onPositionSelected(String value) {
    _positionNameController.text = value;
  }

  // void _handleActionSelection(String selectedAction) {
  //   // Determine the content based on the selected action
  //   switch (selectedAction) {
  //     case 'Add Officer':
  //       setState(() {
  //         _modalContent = _buildModalContent();
  //         _isModalVisible.value = true;
  //       });
  //       break;
  //     case 'Add Office':
  //       setState(() {
  //         _modalContent =
  //             Text('Add Office Content'); // Replace with your actual widget
  //         _isModalVisible.value = true;
  //       });
  //       break;
  //     case 'Add Position':
  //       setState(() {
  //         _modalContent =
  //             Text('Add Position Content'); // Replace with your actual widget
  //         _isModalVisible.value = true;
  //       });
  //       break;
  //   }
  // }

  @override
  void dispose() {
    _nameController.dispose();
    _officeNameController.dispose();
    _positionNameController.dispose();

    _isModalVisible.dispose();
    _selectedOfficeName.dispose();

    _searchController.dispose();
    _debounce?.cancel();
    _totalRecords.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(
              height: 20.0,
            ),
            _buildActionsRow(),
            const SizedBox(
              height: 50.0,
            ),
            _buildTableActionsRow(),
            const SizedBox(
              height: 20.0,
            ),
            Expanded(
              child: _buildDataTable(),
            ),
          ],
        ),
        _buildModal(),
      ],
    );
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

  Widget _buildActionsRow() {
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
        CustomFilledButton(
          height: 40.0,
          onTap: () => _isModalVisible.value = true,
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
            const ReusableCustomRefreshOutlineButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterTableRow() {
    final Map<String, String> filterMapping = {
      'View All': '',
      'Supply': 'supply',
      'Others': 'others',
    };

    return FilterTableRow(
      selectedFilterNotifier: _selectedFilterNotifier,
      filterMapping: filterMapping,
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
                Text(
                  officer.id,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400,
                      ),
                ),
                Text(
                  officer.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400,
                      ),
                ),
                Text(
                  officer.officeName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400,
                      ),
                ),
                Text(
                  officer.positionName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ],
              menuItems: [
                {
                  'text': 'Edit',
                  'icon': FluentIcons.eye_20_regular,
                },
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
              subtitle: 'User authentication status updated successfully.',
            );
            _refreshOfficerList();
          } else {
            DelightfulToastUtils.showDelightfulToast(
              context: context,
              icon: Icons.error_outline,
              title: 'Failed',
              subtitle: 'Failed to update officer authentication status.',
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

  Widget _buildModal() {
    return ValueListenableBuilder(
      valueListenable: _isModalVisible,
      builder: (context, isModalVisible, child) {
        return SlideableContainer(
          content: isModalVisible ? _buildModalContent() : const SizedBox.shrink(),
          isVisible: isModalVisible,
          onClose: () {
            _formKey.currentState!.reset();
            _isModalVisible.value = false;
          },
        );
      },
    );
  }

  Widget _buildModalContent() {
    return Column(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add Officer',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(
                height: 30.0,
              ),
              _buildForm(),
              const SizedBox(
                height: 20.0,
              ),
            ],
          ),
        ),
        _modalActionsRow(),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomLabeledTextBox(
            controller: _nameController,
            label: 'Name',
          ),
          const SizedBox(
            height: 20.0,
          ),
          _buildOfficeNameSearchBox(),
          const SizedBox(
            height: 20.0,
          ),
          _buildPositionSearchBox(),
        ],
      ),
    );
  }

  Widget _buildOfficeNameSearchBox() {
    return CustomSearchBox(
      suggestionsCallback: _officeSuggestionCallback,
      onSelected: _onOfficeSelected,
      controller: _officeNameController,
      label: 'Office Name',
    );
  }

  Widget _buildPositionSearchBox() {
    return ValueListenableBuilder(
      valueListenable: _selectedOfficeName,
      builder: (context, selectedOfficeName, child) {
        return CustomSearchBox(
          suggestionsCallback: (String? positionName) async {
            if (selectedOfficeName != null && selectedOfficeName.isNotEmpty) {
              final positionNames =
                  await _officerSuggestionsService.fetchOfficePositions(
                officeName: selectedOfficeName,
                positionName: positionName,
              );

              return positionNames;
            }
            return null;
          },
          onSelected: _onPositionSelected,
          controller: _positionNameController,
          label: 'Position Name',
        );
      },
    );
  }

  Widget _modalActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: CustomOutlineButton(
            onTap: () {
              _isModalVisible.value = false;
              _formKey.currentState!.reset();
            },
            height: 40.0,
            text: 'Cancel',
          ),
        ),
        const SizedBox(
          width: 5.0,
        ),
        Expanded(
          child: CustomFilledButton(
            onTap: _addOfficer,
            height: 40.0,
            text: 'Add',
          ),
        ),
      ],
    );
  }
}
