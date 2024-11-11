import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';
import '../../../../core/common/components/custom_data_table.dart';
import '../../../../core/common/components/custom_date_picker.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_form_text_field.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/common/components/reusable_linear_progress_indicator.dart';
import '../../../../core/enums/issuance_purpose.dart';
import '../../../../core/enums/issuance_type.dart';
import '../../../../core/services/officer_suggestions_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../../injection_container.dart';
import '../../../purchase_request/presentation/components/custom_search_field.dart';
import '../bloc/issuances_bloc.dart';

class ReusableItemIssuanceView extends StatefulWidget {
  const ReusableItemIssuanceView({
    super.key,
    required this.issuancePurpose,
    required this.issuanceType,
    required this.prId,
  });

  final IssuancePurpose issuancePurpose;
  final IssuanceType issuanceType;
  final String prId;

  @override
  State<ReusableItemIssuanceView> createState() =>
      _ReusableItemIssuanceViewState();
}

class _ReusableItemIssuanceViewState extends State<ReusableItemIssuanceView> {
  late IssuancesBloc _issuancesBloc;
  late OfficerSuggestionsService _officerSuggestionsService;

  final _formKey = GlobalKey<FormState>();
  final _prIdController = TextEditingController();
  final _dateController = TextEditingController();

  final _itemNameController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitCostController = TextEditingController();

  final _receivingOfficerOfficeNameController = TextEditingController();
  final _receivingOfficerPositionNameController = TextEditingController();
  final _receivingOfficerNameController = TextEditingController();

  final _sendingOfficerOfficeNameController = TextEditingController();
  final _sendingOfficerPositionNameController = TextEditingController();
  final _sendingOfficerNameController = TextEditingController();

  final ValueNotifier<String?> _selectedReceivingOfficerOffice =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedReceivingOfficerPosition =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedSendingOfficerOffice =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedSendingOfficerPosition =
      ValueNotifier(null);
  final ValueNotifier<DateTime> _pickedDate = ValueNotifier(DateTime.now());

  late TableConfig _tableConfig;
  final List<String> _tableHeaders = [
    'Item Id',
    'Fetched Quantity',
  ];
  late List<TableData> _tableRows;

  late List _issuanceItems;

  @override
  void initState() {
    super.initState();
    _issuancesBloc = context.read<IssuancesBloc>();
    _officerSuggestionsService = serviceLocator<OfficerSuggestionsService>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _issuancesBloc.add(
        MatchItemWithPrEvent(
          prId: widget.prId,
        ),
      );
    });

    _tableRows = [];
    _initializeTableConfig();
  }

  void _initializeTableConfig() {
    _tableConfig = TableConfig(
      headers: _tableHeaders,
      rows: _tableRows,
      columnFlex: [
        2,
        1,
      ],
    );
  }

  void _saveIssuance() {
    if (widget.issuanceType == IssuanceType.ics) {
      _issuancesBloc.add(
        CreateICSEvent(
          prId: _prIdController.text,
          issuanceItems: _issuanceItems,
          receivingOfficerOffice: _receivingOfficerOfficeNameController.text,
          receivingOfficerPosition:
              _receivingOfficerPositionNameController.text,
          receivingOfficerName: _receivingOfficerNameController.text,
          sendingOfficerOffice: _sendingOfficerOfficeNameController.text,
          sendingOfficerPosition: _sendingOfficerPositionNameController.text,
          sendingOfficerName: _sendingOfficerNameController.text,
        ),
      );
    }

    if (widget.issuanceType == IssuanceType.par) {
      _issuancesBloc.add(
        CreatePAREvent(
          prId: _prIdController.text,
          issuanceItems: _issuanceItems,
          receivingOfficerOffice: _receivingOfficerOfficeNameController.text,
          receivingOfficerPosition:
              _receivingOfficerPositionNameController.text,
          receivingOfficerName: _receivingOfficerNameController.text,
          sendingOfficerOffice: _sendingOfficerOfficeNameController.text,
          sendingOfficerPosition: _sendingOfficerPositionNameController.text,
          sendingOfficerName: _sendingOfficerNameController.text,
        ),
      );
    }
  }

  @override
  void dispose() {
    _prIdController.dispose();
    _dateController.dispose();

    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _quantityController.dispose();
    _unitCostController.dispose();

    _receivingOfficerOfficeNameController.dispose();
    _receivingOfficerPositionNameController.dispose();
    _receivingOfficerNameController.dispose();

    _sendingOfficerOfficeNameController.dispose();
    _sendingOfficerPositionNameController.dispose();
    _sendingOfficerNameController.dispose();

    //_quantity.dispose();
    _selectedReceivingOfficerOffice.dispose();
    _selectedReceivingOfficerPosition.dispose();
    _selectedSendingOfficerOffice.dispose();
    _selectedSendingOfficerPosition.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<IssuancesBloc, IssuancesState>(listener:
          (context, state) async {
        if (state is MatchedItemWithPr) {
          final initData = state.matchedItemWithPrEntity;
          final prData = initData.purchaseRequestEntity;

          _prIdController.text = prData.id;
          _itemNameController.text = prData.productNameEntity.name;
          _quantityController.text = prData.quantity.toString();

          _issuanceItems = initData.matchedItemEntity!
              .map(
                (matchedItem) => {
                  'item_id': matchedItem.itemId,
                  'issued_quantity': matchedItem.issuedQuantity,
                },
              )
              .toList();
          print(_issuanceItems);

          _tableRows.clear();
          _tableRows.addAll(initData.matchedItemEntity!
              .map(
                (matchedItem) => TableData(
                  id: matchedItem.itemId,
                  columns: [
                    Text(
                      matchedItem.itemId,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text(
                      matchedItem.issuedQuantity.toString(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              )
              .toList());
        }

        if (state is ICSRegistered) {
          DelightfulToastUtils.showDelightfulToast(
            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
            context: context,
            title: 'Success',
            subtitle: 'ICS created successfully.',
          );
          await Future.delayed(const Duration(seconds: 3));
          context.pop();
        }

        if (state is PARRegistered) {
          DelightfulToastUtils.showDelightfulToast(
            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
            context: context,
            title: 'Success',
            subtitle: 'PAR created successfully.',
          );
          await Future.delayed(const Duration(seconds: 3));
          context.pop();
        }
      }, child:
          BlocBuilder<IssuancesBloc, IssuancesState>(builder: (context, state) {
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
                  child: _buildForm(),
                ),
              ),
            ),
          ],
        );
      })),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildPreviewPurchaseRequestSummary(),
          const SizedBox(
            height: 50.0,
          ),
          _buildItemIssuanceSection(),
          const SizedBox(
            height: 50.0,
          ),
          _buildRelatedOfficersSection(),
          const SizedBox(
            height: 80.0,
          ),
          _buildActionsRow(),
        ],
      ),
    );
  }

  Widget _buildPreviewPurchaseRequestSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Purchase Request',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          'Summarize information of the Purchase Request.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomFormTextField(
                controller: _prIdController,
                enabled: false,
                label: 'PR No.',
                placeholderText: 'Ex.',
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: CustomFormTextField(
                controller: _itemNameController,
                enabled: false,
                label: 'Item Name',
                placeholderText: 'Ex.',
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: CustomFormTextField(
                controller: _quantityController,
                enabled: false,
                label: 'Quantity',
                placeholderText: 'Ex.',
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
              ),
            ),
            // Expanded(
            //   child: _buildDateSelection(),
            // ),
          ],
        ),
        // const SizedBox(
        //   height: 30.0,
        // ),
        // Row(
        //   children: [
        //     Expanded(
        //       flex: 2,
        //       child: CustomFormTextField(
        //         label: 'Item Name',
        //         placeholderText: 'Ex.',
        //         fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
        //             ? AppColor.lightCustomTextBox
        //             : AppColor.darkCustomTextBox),
        //       ),
        //     ),
        //     const SizedBox(
        //       width: 20.0,
        //     ),
        //     Expanded(
        //       flex: 2,
        //       child: CustomFormTextField(
        //         label: 'Quantity',
        //         placeholderText: 'Ex.',
        //         fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
        //             ? AppColor.lightCustomTextBox
        //             : AppColor.darkCustomTextBox),
        //       ),
        //     ),
        //     const SizedBox(
        //       width: 20.0,
        //     ),
        //     Expanded(
        //       flex: 2,
        //       child: CustomFormTextField(
        //         label: 'Unit Cost',
        //         placeholderText: 'Ex.',
        //         fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
        //             ? AppColor.lightCustomTextBox
        //             : AppColor.darkCustomTextBox),
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildItemIssuanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Item Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          'Item(s) to be issued.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        SizedBox(
          height: 250.0,
          child: CustomDataTable(
            config: _tableConfig.copyWith(
              rows: _tableRows,
            ),
            onActionSelected: (id, action) {},
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedOfficersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Associated Officers',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          'Officers involved to this request.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        // Text(
        //   'Receiving Officers',
        //   style: Theme.of(context).textTheme.titleMedium?.copyWith(
        //     fontSize: 16.0,
        //     fontWeight: FontWeight.w700,
        //   ),
        // ),
        Row(
          children: [
            Expanded(
              child: _buildRequestingOfficerOfficeSuggestionField(),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: _buildRequestingOfficerPositionSuggestionField(),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: _buildRequestingOfficerNameSuggestionField(),
            ),
          ],
        ),
        const SizedBox(
          height: 30.0,
        ),
        // Text(
        //   'Approving Officers',
        //   style: Theme.of(context).textTheme.titleMedium?.copyWith(
        //     fontSize: 16.0,
        //     fontWeight: FontWeight.w700,
        //   ),
        // ),
        Row(
          children: [
            Expanded(
              child: _buildSendingOfficerOfficeSuggestionField(),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: _buildSendingOfficerPositionSuggestionField(),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: _buildSendingOfficerNameSuggestionField(),
            ),
          ],
        ),
      ],
    );
  }

  //Widget _buildOfficersRelatedSection() {}

  Widget _buildDateSelection() {
    return ValueListenableBuilder(
      valueListenable: _pickedDate,
      builder: (context, pickedValue, child) {
        final dateController = TextEditingController(
          text: pickedValue != null ? dateFormatter(pickedValue) : '',
        );

        return CustomDatePicker(
          onDateChanged: (DateTime? date) {
            if (date != null) {
              _pickedDate.value = date;
            }
          },
          label: 'Acquired Date',
          dateController: dateController,
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        );
      },
    );
  }

  Widget _buildRequestingOfficerOfficeSuggestionField() {
    return CustomSearchField(
      suggestionsCallback: (officeName) async {
        final offices = await _officerSuggestionsService.fetchOffices(
          officeName: officeName,
        );

        if (offices == null) {
          _receivingOfficerPositionNameController.clear();
          _receivingOfficerNameController.clear();

          _selectedReceivingOfficerOffice.value = null;
          _selectedReceivingOfficerPosition.value = null;
        }

        return offices;
      },
      onSelected: (value) {
        _receivingOfficerOfficeNameController.text = value;
        _receivingOfficerPositionNameController.clear();
        _receivingOfficerNameController.clear();

        _selectedReceivingOfficerOffice.value = value;
        _selectedReceivingOfficerPosition.value = null;
      },
      controller: _receivingOfficerOfficeNameController,
      label: 'Receiving Officer Office',
      placeHolderText: 'Enter requesting officer\'s office',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildSendingOfficerOfficeSuggestionField() {
    return CustomSearchField(
      suggestionsCallback: (officeName) async {
        final offices = await _officerSuggestionsService.fetchOffices(
          officeName: officeName,
        );

        if (offices == null) {
          _sendingOfficerPositionNameController.clear();
          _sendingOfficerNameController.clear();

          _selectedSendingOfficerOffice.value = null;
          _selectedSendingOfficerPosition.value = null;
        }

        return offices;
      },
      onSelected: (value) {
        _sendingOfficerOfficeNameController.text = value;
        _sendingOfficerPositionNameController.clear();
        _sendingOfficerNameController.clear();

        _selectedSendingOfficerOffice.value = value;
        _selectedSendingOfficerPosition.value = null;
      },
      controller: _sendingOfficerOfficeNameController,
      label: 'Sending Officer Office',
      placeHolderText: 'Enter sending officer\'s office',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildRequestingOfficerPositionSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedReceivingOfficerOffice,
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
                _receivingOfficerNameController.clear();
                _selectedReceivingOfficerPosition.value = null;
              }

              return positions;
            }
            return null;
          },
          onSelected: (value) {
            _receivingOfficerPositionNameController.text = value;
            _receivingOfficerNameController.clear();
            _selectedReceivingOfficerPosition.value = value;
          },
          controller: _receivingOfficerPositionNameController,
          label: 'Receiving Officer Position',
          placeHolderText: 'Enter requesting officer\'s position',
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        );
      },
    );
  }

  Widget _buildSendingOfficerPositionSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedSendingOfficerOffice,
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
                _sendingOfficerNameController.clear();
                _selectedSendingOfficerPosition.value = null;
              }

              return positions;
            }
            return null;
          },
          onSelected: (value) {
            _sendingOfficerPositionNameController.text = value;
            _sendingOfficerNameController.clear();
            _selectedSendingOfficerPosition.value = value;
          },
          controller: _sendingOfficerPositionNameController,
          label: 'Sending Officer Position',
          placeHolderText: 'Enter sending officer\'s position',
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        );
      },
    );
  }

  Widget _buildRequestingOfficerNameSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedReceivingOfficerOffice,
      builder: (context, selectedOfficeName, child) {
        return ValueListenableBuilder(
          valueListenable: _selectedReceivingOfficerPosition,
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
                _receivingOfficerNameController.text = value;
              },
              controller: _receivingOfficerNameController,
              label: 'Receiving Officer Name',
              placeHolderText: 'Enter requesting officer\'s name',
              fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                  ? AppColor.lightCustomTextBox
                  : AppColor.darkCustomTextBox),
            );
          },
        );
      },
    );
  }

  Widget _buildSendingOfficerNameSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedSendingOfficerOffice,
      builder: (context, selectedOfficeName, child) {
        return ValueListenableBuilder(
          valueListenable: _selectedSendingOfficerPosition,
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
                _sendingOfficerNameController.text = value;
              },
              controller: _sendingOfficerNameController,
              label: 'Sending Officer Name',
              placeHolderText: 'Enter sending officer\'s name',
              fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                  ? AppColor.lightCustomTextBox
                  : AppColor.darkCustomTextBox),
            );
          },
        );
      },
    );
  }

  Widget _buildActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomOutlineButton(
          onTap: () => context.pop(),
          text: 'Cancel',
          width: 180.0,
        ),
        const SizedBox(
          width: 10.0,
        ),
        CustomFilledButton(
          onTap: _saveIssuance,
          text: 'Create',
          width: 180.0,
          height: 40.0,
        ),
      ],
    );
  }
}
