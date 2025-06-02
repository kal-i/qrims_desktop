import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/components/base_modal.dart';
import '../../../../core/common/components/custom_date_picker.dart';
import '../../../../core/common/components/custom_dropdown_field.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_form_text_field.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/enums/document_type.dart';
import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/generate_inventory_report.dart';
import '../../../../core/utils/custom_date_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/fund_cluster_to_readable_string.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../bloc/issuances_bloc.dart';
import 'custom_document_preview.dart';

class GenerateInventoryReportModal extends StatefulWidget {
  const GenerateInventoryReportModal({
    super.key,
    required this.generateInventoryReportType,
    required this.modalTitle,
  });

  final GenerateInventoryReportType generateInventoryReportType;
  final String modalTitle;

  @override
  State<GenerateInventoryReportModal> createState() =>
      _GenerateInventoryReportModalState();
}

class _GenerateInventoryReportModalState
    extends State<GenerateInventoryReportModal> {
  late IssuancesBloc _issuancesBloc;

  final _formKey = GlobalKey<FormState>();

  final _accountableOfficerNameController = TextEditingController();
  final _accountableOfficerPositionaNameController = TextEditingController();
  final _locationController = TextEditingController();

  final _approvingEntityOrAuthorizedRepresentativeController =
      TextEditingController();
  final _coaRepresentativeController = TextEditingController();

  final ValueNotifier<DateTime> _startDate = ValueNotifier(DateTime.now());
  final ValueNotifier<DateTime> _endDate = ValueNotifier(DateTime.now());
  final ValueNotifier<DateTime> _asAtDate = ValueNotifier(DateTime.now());
  final ValueNotifier<DateTime> _accountableDate =
      ValueNotifier(DateTime.now());
  final ValueNotifier<FundCluster?> _selectedFundCluster = ValueNotifier(null);
  final ValueNotifier<AssetSubClass?> _selectedAssetSubClass =
      ValueNotifier(null);
  final ValueNotifier<List<Map<String, TextEditingController>>> _officers =
      ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _issuancesBloc = context.read<IssuancesBloc>();
  }

  void _addOfficerField() {
    _officers.value = List.from(_officers.value)
      ..add({
        'name': TextEditingController(),
        'position': TextEditingController(),
      });
  }

  void _removeOfficerField(int index) {
    if (_officers.value.isNotEmpty) {
      // Dispose of the TextEditingControllers to prevent memory leaks
      _officers.value[index]['name']?.dispose();
      _officers.value[index]['position']?.dispose();

      // Create a new list without the removed item
      final updatedList =
          List<Map<String, TextEditingController>>.from(_officers.value);
      updatedList.removeAt(index);

      // Assign the updated list back to the ValueNotifier
      _officers.value = updatedList;
    }
  }

  void _onGenerateReport() {
    if (_formKey.currentState!.validate()) {
      // Dispatch the event to generate RPCI
      switch (widget.generateInventoryReportType) {
        case GenerateInventoryReportType.rcpi:
          _issuancesBloc.add(
            GetInventorySupplyReportEvent(
              startDate: _startDate.value,
              endDate: _endDate.value,
              fundCluster: _selectedFundCluster.value,
            ),
          );
        case GenerateInventoryReportType.rcsep:
          _issuancesBloc.add(
            GetInventorySemiExpendablePropertyReportEvent(
              startDate: _startDate.value,
              endDate: _endDate.value,
              assetSubClass: _selectedAssetSubClass.value,
              fundCluster: _selectedFundCluster.value,
            ),
          );
        case GenerateInventoryReportType.rcppe:
          _issuancesBloc.add(
            GetInventoryPropertyReportEvent(
              startDate: _startDate.value,
              endDate: _endDate.value,
              assetSubClass: _selectedAssetSubClass.value,
              fundCluster: _selectedFundCluster.value,
            ),
          );
      }
    }
  }

  @override
  void dispose() {
    _startDate.dispose();
    _endDate.dispose();
    _asAtDate.dispose();

    _selectedAssetSubClass.dispose();
    _selectedFundCluster.dispose();

    _accountableOfficerNameController.dispose();
    _accountableOfficerPositionaNameController.dispose();
    _locationController.dispose();
    _accountableDate.dispose();

    _approvingEntityOrAuthorizedRepresentativeController.dispose();
    _coaRepresentativeController.dispose();

    _officers.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      width: 900.0,
      height: 900.0,
      headerTitle: 'Generate ${widget.modalTitle}',
      subtitle:
          'Provide the necessary details below to generate the ${widget.modalTitle} document accurately.',
      content: _buildContent(),
      footer: _buildActionsRow(),
    );
  }

  Widget _buildContent() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 15.0,
            ),
            _buildDateRangeSection(),
            const SizedBox(
              height: 50.0,
            ),
            _buildInitialInformationSection(),
            const SizedBox(
              height: 50.0,
            ),
            _buildAccountableOfficerSection(),
            const SizedBox(
              height: 50.0,
            ),
            _buildApprovingEntityOrAuthorizedRepresentativeSection(),
            const SizedBox(
              height: 50.0,
            ),
            _buildCOARepresentativeSection(),
            const SizedBox(
              height: 50.0,
            ),
            _buildCertifiedOfficersSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select Date Range',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          'Choose a start and end date to retrieve the relevant inventory records.',
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
              child: _buildStartDateSelection(),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: _buildEndDateSelection(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInitialInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'General Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          'Specify the inventory type, reference date, and fund cluster for this document.',
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
            if (widget.generateInventoryReportType !=
                GenerateInventoryReportType.rcpi)
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildAssetSubClassSelection(),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _buildAsAtDateSelection(),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: _buildFundClusterSelection(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountableOfficerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Accountable Officer',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          'Enter the details of the officer responsible for the inventory, including their name, position, and assigned location.',
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
              child: CustomFormTextField(
                controller: _accountableOfficerNameController,
                label: 'Accountable officer Name',
                placeholderText: 'Enter accountable officer\'s name',
                hasValidation: false,
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: CustomFormTextField(
                controller: _accountableOfficerPositionaNameController,
                label: 'Accountable officer Position',
                placeholderText: 'Enter accountable officer\'s position',
                hasValidation: false,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            Expanded(
              child: CustomFormTextField(
                controller: _locationController,
                label: 'Location',
                placeholderText: 'Enter location',
                hasValidation: false,
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: _buildAccountableDateSelection(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildApprovingEntityOrAuthorizedRepresentativeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Approving Entity or Authorized Representative',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          'Enter the details of the officer responsible for the inventory, including their name, position, and assigned location.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        CustomFormTextField(
          controller: _approvingEntityOrAuthorizedRepresentativeController,
          label: 'Approving Entity or Authorized Representative Name',
          placeholderText:
              'Enter approving entity or authorized representative\'s name',
          hasValidation: false,
        ),
      ],
    );
  }

  Widget _buildCOARepresentativeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'COA Representative',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          'Enter the details of the officer responsible for the inventory, including their name, position, and assigned location.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        CustomFormTextField(
          controller: _coaRepresentativeController,
          label: 'COA Representative Name',
          placeholderText: 'Enter COA representative\'s name',
          hasValidation: false,
        ),
      ],
    );
  }

  Widget _buildCertifiedOfficersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Certifying Officials',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Text(
                  'List the officers who will certify this document. You can add or remove officers as needed.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ],
            ),
            CustomFilledButton(
              width: 160.0,
              height: 40.0,
              text: 'Add Officer Field',
              onTap: () => _addOfficerField(),
            ),
          ],
        ),
        const SizedBox(
          height: 20.0,
        ),
        ValueListenableBuilder(
          valueListenable: _officers,
          builder: (context, officers, child) {
            return Column(
              children: List.generate(
                officers.length,
                (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomFormTextField(
                            controller: officers[index]['name'],
                            label: '* Officer Name',
                            placeholderText: 'Enter officer\'s name',
                          ),
                        ),
                        const SizedBox(
                          width: 20.0,
                        ),
                        Expanded(
                          child: CustomFormTextField(
                            controller: officers[index]['position'],
                            label: '* Position',
                            placeholderText: 'Enter officer\'s position',
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () => _removeOfficerField(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStartDateSelection() {
    return ValueListenableBuilder(
      valueListenable: _startDate,
      builder: (context, pickedValue, child) {
        final dateController = TextEditingController(
          text: pickedValue != null ? dateFormatter(pickedValue) : '',
        );

        return CustomDatePicker(
          onDateChanged: (DateTime? date) {
            if (date != null) {
              _startDate.value = date;
            }
          },
          label: 'Start Date',
          dateController: dateController,
        );
      },
    );
  }

  Widget _buildEndDateSelection() {
    return ValueListenableBuilder(
      valueListenable: _endDate,
      builder: (context, pickedValue, child) {
        final dateController = TextEditingController(
          text: pickedValue != null ? dateFormatter(pickedValue) : '',
        );

        return CustomDatePicker(
          onDateChanged: (DateTime? date) {
            if (date != null) {
              _endDate.value = date;
            }
          },
          label: 'End Date',
          dateController: dateController,
        );
      },
    );
  }

  Widget _buildAsAtDateSelection() {
    return ValueListenableBuilder(
      valueListenable: _asAtDate,
      builder: (context, pickedValue, child) {
        final dateController = TextEditingController(
          text: pickedValue != null ? dateFormatter(pickedValue) : '',
        );

        return CustomDatePicker(
          onDateChanged: (DateTime? date) {
            if (date != null) {
              _asAtDate.value = date;
            }
          },
          label: 'As At Date',
          dateController: dateController,
        );
      },
    );
  }

  Widget _buildAccountableDateSelection() {
    return ValueListenableBuilder(
      valueListenable: _accountableDate,
      builder: (context, pickedValue, child) {
        final dateController = TextEditingController(
          text: pickedValue != null ? dateFormatter(pickedValue) : '',
        );

        return CustomDatePicker(
          onDateChanged: (DateTime? date) {
            if (date != null) {
              _accountableDate.value = date;
            }
          },
          label: 'Accountable Date',
          dateController: dateController,
        );
      },
    );
  }

  Widget _buildAssetSubClassSelection() {
    return ValueListenableBuilder(
      valueListenable: _selectedAssetSubClass,
      builder: (context, selectedAssetSubClass, child) {
        return CustomDropdownField<AssetSubClass>(
          onChanged: (value) => _selectedAssetSubClass.value = value,
          items: [
            const DropdownMenuItem<AssetSubClass>(
              value: null,
              child: Text('Select asset sub class'),
            ),
            ...AssetSubClass.values.map(
              (assetSubClass) => DropdownMenuItem(
                value: assetSubClass,
                child: Text(
                  readableEnumConverter(assetSubClass),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ),
          ],
          label: 'Asset Sub Class',
          hasValidation: false,
        );
      },
    );
  }

  Widget _buildFundClusterSelection() {
    return ValueListenableBuilder(
      valueListenable: _selectedFundCluster,
      builder: (context, selectedFundCluster, child) {
        return CustomDropdownField<FundCluster>(
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
          label: 'Fund Cluster',
          hasValidation: false,
        );
      },
    );
  }

  Widget _buildActionsRow() {
    return BlocListener<IssuancesBloc, IssuancesState>(
      listener: (context, state) {
        if (state is FetchedInventoryReport) {
          // List<Map<String, String>> certifyingOffcers =
          //     _officers.value.map((officer) {
          //   return {
          //     'name': officer['name']!.text,
          //     'position': officer['position']!.text,
          //   };
          // }).toList();

          List<Map<String, String>> certifyingOfficers =
              _officers.value.map((e) {
            return {
              'name': e['name']?.text ?? '',
              'position': e['position']?.text ?? '',
            };
          }).toList();

          final dataObject = {
            if (widget.generateInventoryReportType !=
                    GenerateInventoryReportType.rcpi &&
                _selectedAssetSubClass.value != null)
              'asset_sub_class':
                  readableEnumConverter(_selectedAssetSubClass.value),
            'as_at_date': customDateFormatter(_asAtDate.value),
            'fund_cluster':
                _selectedFundCluster.value?.toReadableString() ?? '\n',
            'accountable_officer': {
              'name': _accountableOfficerNameController.text,
              'position': _accountableOfficerPositionaNameController.text,
              'location': _locationController.text,
              'accountability_date':
                  customDateFormatter(_accountableDate.value),
            },
            'inventory_report': state.inventoryReport,
            'approving_entity_or_authorized_representative':
                _approvingEntityOrAuthorizedRepresentativeController.text,
            'coa_representative': _coaRepresentativeController.text,
            'certifying_officers': certifyingOfficers,
          };

          showCustomDocumentPreview(
            context: context,
            documentObject: dataObject,
            docType: widget.generateInventoryReportType ==
                    GenerateInventoryReportType.rcpi
                ? DocumentType.rpci
                : widget.generateInventoryReportType ==
                        GenerateInventoryReportType.rcsep
                    ? DocumentType.annexA8
                    : DocumentType.a73,
            canGenerateExcel: widget.generateInventoryReportType ==
                    GenerateInventoryReportType.rcpi ||
                widget.generateInventoryReportType ==
                    GenerateInventoryReportType.rcsep ||
                widget.generateInventoryReportType ==
                    GenerateInventoryReportType.rcppe,
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomOutlineButton(
            onTap: () => context.pop(),
            text: 'Cancel',
            width: 180.0,
          ),
          const SizedBox(width: 10.0),
          CustomFilledButton(
            onTap: _onGenerateReport,
            text: 'Generate',
            width: 180.0,
            height: 40.0,
          ),
        ],
      ),
    );
  }
}
