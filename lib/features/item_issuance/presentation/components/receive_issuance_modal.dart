import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/common/components/base_modal.dart';
import '../../../../core/common/components/custom_date_picker.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/services/entity_suggestions_service.dart';
import '../../../../core/services/officer_suggestions_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../../init_dependencies.dart';
import '../../../purchase_order/presentation/components/custom_search_field.dart';
import '../bloc/issuances_bloc.dart';

class ReceiveIssuanceModal extends StatefulWidget {
  const ReceiveIssuanceModal({
    super.key,
    required this.baseIssuanceId,
    this.receivingOfficerOffice,
    this.receivingOfficerPosition,
    this.receivingOfficerName,
    this.receivedDate,
  });

  final String baseIssuanceId;
  final String? receivingOfficerOffice;
  final String? receivingOfficerPosition;
  final String? receivingOfficerName;
  final DateTime? receivedDate;

  @override
  State<ReceiveIssuanceModal> createState() => _ReceiveIssuanceModalState();
}

class _ReceiveIssuanceModalState extends State<ReceiveIssuanceModal> {
  late IssuancesBloc _issuancesBloc;
  late EntitySuggestionService _entitySuggestionService;
  late OfficerSuggestionsService _officerSuggestionsService;

  final _formKey = GlobalKey<FormState>();

  final _entityNameController = TextEditingController();
  final _officeNameController = TextEditingController();
  final _positionNameController = TextEditingController();
  final _nameController = TextEditingController();

  final ValueNotifier<String?> _selectedOfficeName = ValueNotifier(null);
  final ValueNotifier<String?> _selectedPositionName = ValueNotifier(null);
  final ValueNotifier<DateTime?> _receivedDate = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _issuancesBloc = context.read<IssuancesBloc>();
    _officerSuggestionsService = serviceLocator<OfficerSuggestionsService>();

    _officeNameController.text = widget.receivingOfficerOffice ?? '';
    _positionNameController.text = widget.receivingOfficerPosition ?? '';
    _nameController.text = widget.receivingOfficerName ?? '';
    _receivedDate.value = widget.receivedDate ?? DateTime.now();
  }

  void _onReceiveIssuance() {
    if (_formKey.currentState!.validate()) {
      _issuancesBloc.add(
        ReceiveIssuanceEvent(
          baseIssuanceId: widget.baseIssuanceId,
          entity: _entityNameController.text,
          receivingOfficerOffice: _officeNameController.text,
          receivingOfficerPosition: _positionNameController.text,
          receivingOfficerName: _nameController.text,
          receivedDate: _receivedDate.value!,
        ),
      );
    }
  }

  @override
  void dispose() {
    _entityNameController.dispose();
    _officeNameController.dispose();
    _positionNameController.dispose();
    _nameController.dispose();

    _selectedOfficeName.dispose();
    _selectedPositionName.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<IssuancesBloc, IssuancesState>(
      listener: (context, state) async {
        if (state is ReceivedIssuance) {
          DelightfulToastUtils.showDelightfulToast(
            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
            context: context,
            title: 'Success',
            subtitle: 'Issuance received successfully.',
          );
          await Future.delayed(const Duration(seconds: 3));
          context.pop();
        }

        if (state is IssuancesError) {
          DelightfulToastUtils.showDelightfulToast(
            icon: Icons.error_outline,
            context: context,
            title: 'Error',
            subtitle: state.message,
          );
        }
      },
      child: BaseModal(
        width: 600.0,
        height: 650.0,
        headerTitle: 'Receive Issuance Document',
        subtitle:
            'Designated accountable officer or recipeint of this issuance document.',
        content: _buildContent(),
        footer: _buildActionsRow(),
      ),
    );
  }

  Widget _buildContent() {
    return Form(
      key: _formKey,
      child: Column(
        spacing: 20.0,
        children: [
          _buildEntitySuggestionField(),
          _buildOfficeNameSuggestionField(),
          _buildPositionSuggestionField(),
          _buildOfficerNameSuggestionField(),
          _buildReceiveDateSelection(),
        ],
      ),
    );
  }

  Widget _buildEntitySuggestionField() {
    return CustomSearchField(
      suggestionsCallback: (entityName) async {
        final entityNames = await _entitySuggestionService.fetchEntities(
          entityName: entityName,
        );

        return entityNames;
      },
      onSelected: (value) {
        _entityNameController.text = value;
      },
      controller: _entityNameController,
      label: '* Entity',
      placeHolderText: 'Enter entity',
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
      label: '* Office',
      placeHolderText: 'Enter officer\'s office',
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
          label: '* Position',
          placeHolderText: 'Enter officer\'s position',
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
                label: '* Name',
                placeHolderText: 'Enter officer\'s name',
              );
            });
      },
    );
  }

  Widget _buildReceiveDateSelection() {
    return ValueListenableBuilder(
      valueListenable: _receivedDate,
      builder: (context, pickedValue, child) {
        final dateController = TextEditingController(
          text: pickedValue != null ? dateFormatter(pickedValue) : '',
        );

        return CustomDatePicker(
          onDateChanged: (DateTime? date) {
            if (date != null) {
              _receivedDate.value = date;
            }
          },
          label: '* Received Date',
          dateController: dateController,
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
          onTap: _onReceiveIssuance,
          text: 'Receive',
          width: 180.0,
          height: 40.0,
        ),
      ],
    );
  }
}
