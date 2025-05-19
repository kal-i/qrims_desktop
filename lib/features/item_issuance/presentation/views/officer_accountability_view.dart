import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/common/components/reusable_linear_progress_indicator.dart';
import '../../../../core/enums/document_type.dart';
import '../../../../core/enums/issuance_item_status.dart';
import '../../../../core/services/excel_document_service/excel_document_service.dart';
import '../../../../core/services/officer_suggestions_service.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../../init_dependencies.dart';
import '../../../purchase_request/presentation/components/custom_search_field.dart';
import '../bloc/issuances_bloc.dart';
import '../components/accountability_status_modal.dart';
import '../components/item_card.dart';

class OfficerAccountabilityView extends StatefulWidget {
  const OfficerAccountabilityView({
    super.key,
  });

  @override
  State<OfficerAccountabilityView> createState() =>
      _OfficerAccountabilityViewState();
}

class _OfficerAccountabilityViewState extends State<OfficerAccountabilityView> {
  late IssuancesBloc _issuancesBloc;
  late OfficerSuggestionsService _officerSuggestionsService;
  late ExcelDocumentService _excelDocumentService;

  final _officeNameController = TextEditingController();
  final _positionNameController = TextEditingController();
  final _nameController = TextEditingController();

  final ValueNotifier<String?> _selectedOfficeName = ValueNotifier(null);
  final ValueNotifier<String?> _selectedPositionName = ValueNotifier(null);

  final ValueNotifier<String?> _accountableOfficerId = ValueNotifier(null);
  final ValueNotifier<List<Map<String, dynamic>>> _accountabilityList =
      ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _issuancesBloc = context.read<IssuancesBloc>();
    _officerSuggestionsService = serviceLocator<OfficerSuggestionsService>();
    _excelDocumentService = serviceLocator<ExcelDocumentService>();
  }

  void _onGetAccountableOfficerId() {
    if (_officeNameController.text.trim().isEmpty ||
        _positionNameController.text.trim().isEmpty ||
        _nameController.text.trim().isEmpty) {
      DelightfulToastUtils.showDelightfulToast(
        context: context,
        icon: Icons.error_outline,
        title: ' Accountability Search Failed',
        subtitle: 'Please fill officer\'s office, position, and name.',
      );
      return;
    }

    _accountabilityList.value = [];

    _issuancesBloc.add(
      GetAccountableOfficerIdEvent(
        office: _officeNameController.text,
        position: _positionNameController.text,
        name: _nameController.text,
      ),
    );
  }

  void _exportToExcel() async {
    if (_accountabilityList.value.isEmpty) {
      DelightfulToastUtils.showDelightfulToast(
        context: context,
        icon: Icons.error_outline,
        title: 'Export Failed',
        subtitle: 'No data available to export.',
      );
      return;
    }

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) return;

    String officerName =
        _nameController.text.trim().replaceAll(RegExp(r'[\\/:*?"<>| ]'), '_');
    String baseFileName =
        '${officerName}_${DateFormat('yyyy-MM').format(DateTime.now())}';

    String outputFilePath =
        _getNextAvailableFileName(selectedDirectory, baseFileName);

    _excelDocumentService.generateAndSaveExcelFromScratch(
      docType: DocumentType.accountability,
      data: {
        'officer': {
          'office': _officeNameController.text,
          'position': _positionNameController.text,
          'name': _nameController.text,
        },
        'accountabilities': _accountabilityList.value,
      },
      outputPath: outputFilePath,
    );

    DelightfulToastUtils.showDelightfulToast(
      context: context,
      icon: Icons.check_circle_outline,
      title: 'Export Successful',
      subtitle: 'Excel file saved to selected path.',
    );
  }

  String _getNextAvailableFileName(String directory, String baseFileName) {
    int n = 1;
    String fileName = '$baseFileName-$n.xlsx';
    String filePath = '$directory/$fileName';
    while (File(filePath).existsSync()) {
      n++;
      fileName = '$baseFileName-$n.xlsx';
      filePath = '$directory/$fileName';
    }
    return filePath;
  }

  @override
  void dispose() {
    _officeNameController.dispose();
    _positionNameController.dispose();
    _nameController.dispose();

    _selectedOfficeName.dispose();
    _selectedPositionName.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<IssuancesBloc, IssuancesState>(
        listener: (context, state) {
          if (state is FetchedAccountableOfficerId) {
            _accountableOfficerId.value = state.officerId;

            if (_accountableOfficerId.value != null &&
                _accountableOfficerId.value!.isNotEmpty) {
              _issuancesBloc.add(
                GetOfficerAccountabilityEvent(
                  officerId: _accountableOfficerId.value!,
                ),
              );
            } else {
              DelightfulToastUtils.showDelightfulToast(
                context: context,
                icon: Icons.error_outline,
                title: 'Search Failed',
                subtitle: 'Officer not found.',
              );
            }
          }

          if (state is FetchedOfficerAccountability) {
            print('officer\'s accountablity: ${state.officerAccountability}');
            final List<Map<String, dynamic>> extracted = [];
            for (final officerData in state.officerAccountability) {
              final accountabilities = officerData['accountabilities'] as List;
              for (final item in accountabilities) {
                extracted.add(item as Map<String, dynamic>);
              }
            }
            _accountabilityList.value = extracted;
          }

          if (state is ResolvedIssuanceItem) {
            if (state.isSuccessful) {
              DelightfulToastUtils.showDelightfulToast(
                context: context,
                icon: Icons.check_circle_outline,
                title: 'Status Update Successful',
                subtitle: 'Issuance item status updated successfully.',
              );
              if (_accountableOfficerId.value != null &&
                  _accountableOfficerId.value!.isNotEmpty) {
                _issuancesBloc.add(
                  GetOfficerAccountabilityEvent(
                    officerId: _accountableOfficerId.value!,
                  ),
                );
              }
            } else {
              DelightfulToastUtils.showDelightfulToast(
                context: context,
                icon: Icons.error_outline,
                title: 'Status Update Failed',
                subtitle: 'Failed to update issuance item status.',
              );
            }
          }

          if (state is IssuancesError) {
            DelightfulToastUtils.showDelightfulToast(
              context: context,
              icon: Icons.error_outline,
              title: 'Error',
              subtitle: state.message,
            );
          }
        },
        child: BlocBuilder<IssuancesBloc, IssuancesState>(
          builder: (context, state) {
            return Column(
              children: [
                if (state is IssuancesLoading)
                  const ReusableLinearProgressIndicator(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 30.0,
                      ),
                      child: _buildMainView(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainView() {
    return Column(
      spacing: 50.0,
      children: [
        _buildAccountableOfficerInformationSection(),
        _buildAccountabilityList(),
        _buildActionsRow(),
      ],
    );
  }

  Widget _buildAccountableOfficerInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '**👨‍💼 Accountable Officer**',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          'Designated accountable officer or receipent of issued items.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 20.0,
          children: [
            Expanded(
              child: _buildOfficeNameSuggestionField(),
            ),
            Expanded(
              child: _buildPositionSuggestionField(),
            ),
            Expanded(
              child: _buildOfficerNameSuggestionField(),
            ),
            CustomFilledButton(
              onTap: _onGetAccountableOfficerId,
              width: 80.0,
              height: 40.0,
              prefixWidget: const Icon(
                HugeIcons.strokeRoundedSearch01,
                size: 15.0,
                color: AppColor.lightPrimary,
              ),
              text: 'Find',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountabilityList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  '**📦 Accountability List**',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Text(
                  'List of inventory items issued to this officer.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ],
            ),
            Row(
              children: [
                CustomFilledButton(
                  onTap: _exportToExcel,
                  height: 40.0,
                  prefixWidget: const Icon(
                    HugeIcons.strokeRoundedDownload04,
                    size: 15.0,
                    color: Colors.white,
                  ),
                  text: 'Export to XLXS',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 20.0,
        ),
        ValueListenableBuilder(
          valueListenable: _accountabilityList,
          builder: (context, accountabilities, child) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(accountabilities.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 250.0,
                      child: ItemCard(
                        data: accountabilities[index],
                        isAccountability: true,
                        onEdit: () => showDialog(
                          context: context,
                          builder: (context) => AccountabilityStatusModal(
                            baseItemId: accountabilities[index]['base_item_id'],
                            status: accountabilities[index]['status'] !=
                                        IssuanceItemStatus.issued
                                            .toString()
                                            .split('.')
                                            .last &&
                                    accountabilities[index]['status'] !=
                                        IssuanceItemStatus.received
                                            .toString()
                                            .split('.')
                                            .last
                                ? IssuanceItemStatus.values.firstWhere(
                                    (e) =>
                                        e.toString().split('.').last ==
                                        accountabilities[index]['status'],
                                  )
                                : null,
                            date: accountabilities[index]['returned_date'] !=
                                    null
                                ? DateTime.parse(
                                    accountabilities[index]['returned_date'])
                                : accountabilities[index]['lost_date'] != null
                                    ? DateTime.parse(
                                        accountabilities[index]['lost_date'])
                                    : null,
                            remarks: accountabilities[index]['remarks'],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOfficeNameSuggestionField() {
    return CustomSearchField(
      suggestionsCallback: (officeName) async {
        final offices = await _officerSuggestionsService.fetchOffices(
          officeName: officeName,
        );

        if (offices == null) {
          _positionNameController.clear();
          _nameController.clear();

          _selectedOfficeName.value = null;
          _selectedPositionName.value = null;
        }

        return offices;
      },
      onSelected: (value) {
        _officeNameController.text = value;
        _positionNameController.clear();
        _nameController.clear();

        _selectedOfficeName.value = value;
        _selectedPositionName.value = null;
      },
      controller: _officeNameController,
      label: 'Office',
      placeHolderText: 'Enter officer\'s office',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildPositionSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedOfficeName,
      builder: (context, selectedOfficeName, child) {
        return CustomSearchField(
          key: ValueKey(selectedOfficeName),
          suggestionsCallback: (String? positionName) async {
            if (selectedOfficeName != null && selectedOfficeName.isNotEmpty) {
              final positions =
                  await _officerSuggestionsService.fetchOfficePositions(
                officeName: selectedOfficeName,
                positionName: positionName,
              );

              if (positions == null) {
                _nameController.clear();
                _selectedPositionName.value = null;
              }

              return positions;
            }
            return null;
          },
          onSelected: (value) {
            _positionNameController.text = value;
            _nameController.clear();
            _selectedPositionName.value = value;
          },
          controller: _positionNameController,
          label: 'Position',
          placeHolderText: 'Enter officer\'s position',
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        );
      },
    );
  }

  Widget _buildOfficerNameSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedOfficeName,
      builder: (context, selectedOfficeName, child) {
        return ValueListenableBuilder(
            valueListenable: _selectedPositionName,
            builder: (context, selectedPositionName, child) {
              return CustomSearchField(
                key: ValueKey('$selectedOfficeName-$selectedPositionName'),
                suggestionsCallback: (String? officerName) async {
                  if ((selectedOfficeName != null &&
                          selectedOfficeName.isNotEmpty) &&
                      (selectedPositionName != null &&
                          selectedPositionName.isNotEmpty)) {
                    final officers =
                        await _officerSuggestionsService.fetchOfficers(
                      officeName: selectedOfficeName,
                      positionName: selectedPositionName,
                      officerName: officerName,
                    );

                    return officers;
                  }
                  return null;
                },
                onSelected: (value) {
                  _nameController.text = value;
                },
                controller: _nameController,
                label: 'Name',
                placeHolderText: 'Enter officer\'s name',
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
              );
            });
      },
    );
  }

  Widget _buildActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomOutlineButton(
          onTap: () => context.pop(),
          text: 'Back',
          width: 180.0,
        ),
      ],
    );
  }
}
