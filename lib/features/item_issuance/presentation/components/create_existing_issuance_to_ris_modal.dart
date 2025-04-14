import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';
import '../../../../core/common/components/base_modal.dart';
import '../../../../core/common/components/custom_dropdown_field.dart';
import '../../../../core/common/components/custom_form_text_field.dart';
import '../../../../core/common/components/custom_loading_filled_button.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/services/entity_suggestions_service.dart';
import '../../../../core/services/officer_suggestions_service.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../../core/utils/fund_cluster_to_readable_string.dart';
import '../../../../init_dependencies.dart';
import '../../../officer/domain/entities/office.dart';
import '../../../officer/domain/entities/officer.dart';
import '../../../purchase_request/domain/entities/purchase_request.dart';
import '../../../purchase_request/presentation/components/custom_search_field.dart';
import '../../data/models/issuance_item.dart';
import '../../domain/entities/issuance.dart';
import '../bloc/issuances_bloc.dart';

class CreateExistingIssuanceToRISModal extends StatefulWidget {
  const CreateExistingIssuanceToRISModal({
    super.key,
    required this.issuanceEntity,
  });

  final IssuanceEntity issuanceEntity;

  @override
  State<CreateExistingIssuanceToRISModal> createState() =>
      _CreateExistingIssuanceToRISModalState();
}

class _CreateExistingIssuanceToRISModalState
    extends State<CreateExistingIssuanceToRISModal> {
  late IssuancesBloc _issuancesBloc;
  late EntitySuggestionService _entitySuggestionService;
  late OfficerSuggestionsService _officerSuggestionsService;

  late IssuanceEntity _issuanceEntity;

  PurchaseRequestEntity? _purchaseRequestEntity;
  Entity? _entity;
  FundCluster? _fundCluster;
  OfficeEntity? _officeEntity;

  String? _responsibilityCenterCode;
  String? _purpose;

  OfficerEntity? _requestingOfficerEntity;
  OfficerEntity? _approvingOfficerEntity;
  OfficerEntity? _issuingOfficerEntity;
  OfficerEntity? _receivingOfficerEntity;

  final _entityNameController = TextEditingController();
  final _divisionController = TextEditingController();
  final _officeController = TextEditingController();
  final _responsibilityCenterCodeController = TextEditingController();
  final _purposeController = TextEditingController();

  final _receivingOfficerOfficeNameController = TextEditingController();
  final _receivingOfficerPositionNameController = TextEditingController();
  final _receivingOfficerNameController = TextEditingController();

  final _issuingOfficerOfficeNameController = TextEditingController();
  final _issuingOfficerPositionNameController = TextEditingController();
  final _issuingOfficerNameController = TextEditingController();

  final _approvingOfficerOfficeNameController = TextEditingController();
  final _approvingOfficerPositionNameController = TextEditingController();
  final _approvingOfficerNameController = TextEditingController();

  final _requestingOfficerOfficeNameController = TextEditingController();
  final _requestingOfficerPositionNameController = TextEditingController();
  final _requestingOfficerNameController = TextEditingController();

  final ValueNotifier<FundCluster?> _selectedFundCluster = ValueNotifier(null);
  final ValueNotifier<String?> _selectedReceivingOfficerOffice =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedReceivingOfficerPosition =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedApprovingOfficerOffice =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedApprovingOfficerPosition =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedIssuingOfficerOffice =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedIssuingOfficerPosition =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedRequestingOfficerOffice =
      ValueNotifier(null);
  final ValueNotifier<String?> _selectedRequestingOfficerPosition =
      ValueNotifier(null);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _issuancesBloc = context.read<IssuancesBloc>();
      _issuancesBloc.stream.listen((state) {
        _isLoading.value = state is IssuancesLoading;
      });
    });

    _issuanceEntity = widget.issuanceEntity;
    _entitySuggestionService = serviceLocator<EntitySuggestionService>();
    _officerSuggestionsService = serviceLocator<OfficerSuggestionsService>();

    _purchaseRequestEntity = _issuanceEntity.purchaseRequestEntity;

    if (_purchaseRequestEntity != null) {
      _extractDataFromPurchaseRequestEntity();
    } else {
      _extractDataFromIssuanceWithoutPurchaseRequestEntity();
    }

    _extractDataFromIssuanceWithOrWithoutPurchaseRequestEntity();
  }

  void _extractDataFromPurchaseRequestEntity() {
    _entity = _purchaseRequestEntity?.entity;
    _officeEntity = _purchaseRequestEntity?.officeEntity;
    _fundCluster = _purchaseRequestEntity?.fundCluster;
    _responsibilityCenterCode =
        _purchaseRequestEntity?.responsibilityCenterCode ?? '';
    _purpose = _purchaseRequestEntity?.purpose ?? '';

    _requestingOfficerEntity = _purchaseRequestEntity?.requestingOfficerEntity;
    _approvingOfficerEntity = _purchaseRequestEntity?.approvingOfficerEntity;
  }

  void _extractDataFromIssuanceWithoutPurchaseRequestEntity() {
    _entity = _issuanceEntity.entity;
    _fundCluster = _issuanceEntity.fundCluster;
  }

  void _extractDataFromIssuanceWithOrWithoutPurchaseRequestEntity() {
    _issuingOfficerEntity = _issuanceEntity.issuingOfficerEntity;
    _receivingOfficerEntity = _issuanceEntity.receivingOfficerEntity;
  }

  void _saveIssuance() async {
    _issuancesBloc.add(
      CreateRISEvent(
        issuedDate: _issuanceEntity.issuedDate,
        issuanceItems: _issuanceEntity.items
            .map(
              (issuanceItem) => (issuanceItem as IssuanceItemModel).toJson(),
            )
            .toList(),
        prId: _purchaseRequestEntity?.id,
        entityName: _entity?.name ?? _entityNameController.text,
        fundCluster: _fundCluster,
        division: _divisionController.text,
        responsibilityCenterCode: _responsibilityCenterCode ??
            _responsibilityCenterCodeController.text,
        officeName: _officeEntity?.officeName ?? _officeController.text,
        purpose: _purpose ?? _purposeController.text,
        receivingOfficerOffice: _receivingOfficerEntity?.officeName ??
            _receivingOfficerOfficeNameController.text,
        receivingOfficerPosition: _receivingOfficerEntity?.positionName ??
            _receivingOfficerPositionNameController.text,
        receivingOfficerName: _receivingOfficerEntity?.name ??
            _receivingOfficerNameController.text,
        issuingOfficerOffice: _issuingOfficerEntity?.officeName ??
            _issuingOfficerOfficeNameController.text,
        issuingOfficerPosition: _issuingOfficerEntity?.positionName ??
            _issuingOfficerPositionNameController.text,
        issuingOfficerName:
            _issuingOfficerEntity?.name ?? _issuingOfficerNameController.text,
        approvingOfficerOffice: _approvingOfficerEntity?.officeName ??
            _approvingOfficerOfficeNameController.text,
        approvingOfficerPosition: _approvingOfficerEntity?.positionName ??
            _approvingOfficerPositionNameController.text,
        approvingOfficerName: _approvingOfficerEntity?.name ??
            _approvingOfficerNameController.text,
        requestingOfficerOffice: _requestingOfficerEntity?.officeName ??
            _requestingOfficerOfficeNameController.text,
        requestingOfficerPosition: _requestingOfficerEntity?.positionName ??
            _requestingOfficerPositionNameController.text,
        requestingOfficerName: _requestingOfficerEntity?.name ??
            _requestingOfficerNameController.text,
      ),
    );
  }

  @override
  void dispose() {
    _entityNameController.dispose();
    _divisionController.dispose();
    _officeController.dispose();
    _responsibilityCenterCodeController.dispose();
    _purposeController.dispose();
    _receivingOfficerOfficeNameController.dispose();
    _receivingOfficerPositionNameController.dispose();
    _receivingOfficerNameController.dispose();
    _issuingOfficerOfficeNameController.dispose();
    _issuingOfficerPositionNameController.dispose();
    _issuingOfficerNameController.dispose();
    _approvingOfficerOfficeNameController.dispose();
    _approvingOfficerPositionNameController.dispose();
    _approvingOfficerNameController.dispose();
    _requestingOfficerOfficeNameController.dispose();
    _requestingOfficerPositionNameController.dispose();
    _requestingOfficerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      width: 900.0,
      height: 500.0,
      headerTitle: 'Create RIS from Existing Issuance',
      subtitle: '',
      content: _buildModalContent(),
      footer: _buildActionsRow(),
    );
  }

  Widget _buildModalContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            spacing: 20.0,
            children: [
              if (_entity == null)
                Expanded(
                  child: _buildEntitySuggestionField(),
                ),
              if (_fundCluster == null)
                Expanded(
                  child: _buildFundClusterSelection(),
                ),
            ],
          ),
          Row(
            spacing: 20.0,
            children: [
              Expanded(
                child: CustomFormTextField(
                  label: 'Division',
                  controller: _divisionController,
                  placeholderText: 'Enter division',
                  fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                      ? AppColor.lightCustomTextBox
                      : AppColor.darkCustomTextBox),
                ),
              ),
              if (_officeEntity == null)
                Expanded(
                  child: _buildOfficeSuggestionField(),
                ),
              if (_responsibilityCenterCode == null ||
                  _responsibilityCenterCode!.trim().isEmpty)
                Expanded(
                  child: CustomFormTextField(
                    label: 'Responsibility Center Code',
                    placeholderText: 'Enter responsibility center code',
                    controller: _responsibilityCenterCodeController,
                    fillColor:
                        (context.watch<ThemeBloc>().state == AppTheme.light
                            ? AppColor.lightCustomTextBox
                            : AppColor.darkCustomTextBox),
                  ),
                ),
            ],
          ),
          if (_purpose == null || _purpose!.trim().isEmpty)
            CustomFormTextField(
              label: 'Purpose',
              controller: _purposeController,
              maxLines: 4,
              placeholderText: 'Enter purpose',
              fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                  ? AppColor.lightCustomTextBox
                  : AppColor.darkCustomTextBox),
            ),
          if (_requestingOfficerEntity == null)
            Column(
              children: [
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
              ],
            ),
          if (_approvingOfficerEntity == null)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildApprovingOfficerOfficeSuggestionField(),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: _buildApprovingOfficerPositionSuggestionField(),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: _buildApprovingOfficerNameSuggestionField(),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30.0,
                ),
              ],
            ),
          if (_issuingOfficerEntity == null)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildIssuingOfficerOfficeSuggestionField(),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: _buildIssuingOfficerPositionSuggestionField(),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: _buildIssuingOfficerNameSuggestionField(),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30.0,
                ),
              ],
            ),
          if (_receivingOfficerEntity == null)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildReceivingOfficerOfficeSuggestionField(),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: _buildReceivingOfficerPositionSuggestionField(),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: _buildReceivingOfficerNameSuggestionField(),
                    ),
                  ],
                ),
              ],
            ),
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
      label: 'Entity',
      placeHolderText: 'Enter entity',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildFundClusterSelection() {
    return ValueListenableBuilder(
      valueListenable: _selectedFundCluster,
      builder: (context, selectedFundCluster, child) {
        return CustomDropdownField<FundCluster>(
          value: selectedFundCluster,
          onChanged: (value) => _selectedFundCluster.value = value,
          items: [
            const DropdownMenuItem<FundCluster>(
              value: null,
              child: Text('Select fund cluster'),
            ),
            ...FundCluster.values.map(
              (fundCluster) => DropdownMenuItem(
                value: fundCluster,
                child: Text(
                  fundCluster.toReadableString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ),
          ],
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
          label: 'Fund Cluster',
        );
      },
    );
  }

  Widget _buildOfficeSuggestionField() {
    return CustomSearchField(
      suggestionsCallback: (officeName) async {
        return await _officerSuggestionsService.fetchOffices(
          // page: currentPage,
          officeName: officeName,
        );
      },
      onSelected: (value) {
        _officeController.text = value;
      },
      controller: _officeController,
      label: 'Office',
      placeHolderText: 'Enter purchase request\'s office',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildRequestingOfficerOfficeSuggestionField() {
    return CustomSearchField(
      suggestionsCallback: (officeName) async {
        final offices = await _officerSuggestionsService.fetchOffices(
          officeName: officeName,
        );

        if (offices == null) {
          _requestingOfficerPositionNameController.clear();
          _requestingOfficerNameController.clear();

          _selectedRequestingOfficerOffice.value = null;
          _selectedRequestingOfficerPosition.value = null;
        }

        return offices;
      },
      onSelected: (value) {
        _requestingOfficerOfficeNameController.text = value;
        _requestingOfficerPositionNameController.clear();
        _requestingOfficerNameController.clear();

        _selectedRequestingOfficerOffice.value = value;
        _selectedRequestingOfficerPosition.value = null;
      },
      controller: _requestingOfficerOfficeNameController,
      label: 'Requesting Officer Office',
      placeHolderText: 'Enter requesting officer\'s office',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildIssuingOfficerOfficeSuggestionField() {
    return CustomSearchField(
      suggestionsCallback: (officeName) async {
        final offices = await _officerSuggestionsService.fetchOffices(
          officeName: officeName,
        );

        if (offices == null) {
          _issuingOfficerPositionNameController.clear();
          _issuingOfficerNameController.clear();

          _selectedIssuingOfficerOffice.value = null;
          _selectedIssuingOfficerPosition.value = null;
        }

        return offices;
      },
      onSelected: (value) {
        _issuingOfficerOfficeNameController.text = value;
        _issuingOfficerPositionNameController.clear();
        _issuingOfficerNameController.clear();

        _selectedIssuingOfficerOffice.value = value;
        _selectedIssuingOfficerPosition.value = null;
      },
      controller: _issuingOfficerOfficeNameController,
      label: 'Issuing Officer Office',
      placeHolderText: 'Enter issuing officer\'s office',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildApprovingOfficerOfficeSuggestionField() {
    return CustomSearchField(
      suggestionsCallback: (officeName) async {
        final offices = await _officerSuggestionsService.fetchOffices(
          officeName: officeName,
        );

        if (offices == null) {
          _approvingOfficerPositionNameController.clear();
          _approvingOfficerNameController.clear();

          _selectedApprovingOfficerOffice.value = null;
          _selectedApprovingOfficerPosition.value = null;
        }

        return offices;
      },
      onSelected: (value) {
        _approvingOfficerOfficeNameController.text = value;
        _approvingOfficerPositionNameController.clear();
        _approvingOfficerNameController.clear();

        _selectedApprovingOfficerOffice.value = value;
        _selectedApprovingOfficerPosition.value = null;
      },
      controller: _approvingOfficerOfficeNameController,
      label: 'Approving Officer Office',
      placeHolderText: 'Enter approving officer\'s office',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildReceivingOfficerOfficeSuggestionField() {
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
      placeHolderText: 'Enter receiving officer\'s office',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildRequestingOfficerPositionSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedRequestingOfficerOffice,
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
                _requestingOfficerNameController.clear();
                _selectedRequestingOfficerPosition.value = null;
              }

              return positions;
            }
            return null;
          },
          onSelected: (value) {
            _requestingOfficerPositionNameController.text = value;
            _requestingOfficerNameController.clear();
            _selectedRequestingOfficerPosition.value = value;
          },
          controller: _requestingOfficerPositionNameController,
          label: 'Requesting Officer Position',
          placeHolderText: 'Enter requesting officer\'s position',
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        );
      },
    );
  }

  Widget _buildApprovingOfficerPositionSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedApprovingOfficerOffice,
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
                _approvingOfficerNameController.clear();
                _selectedApprovingOfficerPosition.value = null;
              }

              return positions;
            }
            return null;
          },
          onSelected: (value) {
            _approvingOfficerPositionNameController.text = value;
            _approvingOfficerNameController.clear();
            _selectedApprovingOfficerPosition.value = value;
          },
          controller: _approvingOfficerPositionNameController,
          label: 'Approving Officer Position',
          placeHolderText: 'Enter approving officer\'s position',
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        );
      },
    );
  }

  Widget _buildIssuingOfficerPositionSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedIssuingOfficerOffice,
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
                _issuingOfficerNameController.clear();
                _selectedIssuingOfficerPosition.value = null;
              }

              return positions;
            }
            return null;
          },
          onSelected: (value) {
            _issuingOfficerPositionNameController.text = value;
            _issuingOfficerNameController.clear();
            _selectedIssuingOfficerPosition.value = value;
          },
          controller: _issuingOfficerPositionNameController,
          label: 'Issuing Officer Position',
          placeHolderText: 'Enter issuing officer\'s position',
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        );
      },
    );
  }

  Widget _buildReceivingOfficerPositionSuggestionField() {
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
          placeHolderText: 'Enter receiving officer\'s position',
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
        );
      },
    );
  }

  Widget _buildRequestingOfficerNameSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedRequestingOfficerOffice,
      builder: (context, selectedOfficeName, child) {
        return ValueListenableBuilder(
          valueListenable: _selectedRequestingOfficerPosition,
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
                _requestingOfficerNameController.text = value;
              },
              controller: _requestingOfficerNameController,
              label: 'Requesting Officer Name',
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

  Widget _buildApprovingOfficerNameSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedApprovingOfficerOffice,
      builder: (context, selectedOfficeName, child) {
        return ValueListenableBuilder(
          valueListenable: _selectedApprovingOfficerPosition,
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
                _approvingOfficerNameController.text = value;
              },
              controller: _approvingOfficerNameController,
              label: 'Approving Officer Name',
              placeHolderText: 'Enter approving officer\'s name',
              fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                  ? AppColor.lightCustomTextBox
                  : AppColor.darkCustomTextBox),
            );
          },
        );
      },
    );
  }

  Widget _buildIssuingOfficerNameSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedIssuingOfficerOffice,
      builder: (context, selectedOfficeName, child) {
        return ValueListenableBuilder(
          valueListenable: _selectedIssuingOfficerPosition,
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
                _issuingOfficerNameController.text = value;
              },
              controller: _issuingOfficerNameController,
              label: 'Issuing Officer Name',
              placeHolderText: 'Enter issuing officer\'s name',
              fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                  ? AppColor.lightCustomTextBox
                  : AppColor.darkCustomTextBox),
            );
          },
        );
      },
    );
  }

  Widget _buildReceivingOfficerNameSuggestionField() {
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
              placeHolderText: 'Enter receiving officer\'s name',
              fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                  ? AppColor.lightCustomTextBox
                  : AppColor.darkCustomTextBox),
            );
          },
        );
      },
    );
  }

  // loading custom button i created
  Widget _buildActionsRow() {
    return BlocListener<IssuancesBloc, IssuancesState>(
      listener: (context, state) async {
        if (state is RISRegistered) {
          DelightfulToastUtils.showDelightfulToast(
            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
            context: context,
            title: 'Success',
            subtitle: 'RIS created successfully.',
          );
          await Future.delayed(const Duration(seconds: 3));
          context.pop();
        }

        if (state is IssuancesError) {
          DelightfulToastUtils.showDelightfulToast(
            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
            context: context,
            title: 'Error',
            subtitle: 'Failed to create RIS: ${state.message}.',
          );
        }
      },
      child: Row(
        spacing: 10.0,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomOutlineButton(
            onTap: context.pop,
            text: 'Cancel',
            width: 180.0,
          ),
          CustomLoadingFilledButton(
            onTap: _saveIssuance,
            text: 'Create',
            isLoadingNotifier: _isLoading,
            width: 180.0,
            height: 40.0,
          ),
        ],
      ),
    );
  }
}
