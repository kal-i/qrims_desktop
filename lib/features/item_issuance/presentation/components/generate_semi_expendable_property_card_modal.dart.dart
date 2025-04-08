import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';
import '../../../../core/common/components/custom_dropdown_field.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/enums/document_type.dart';
import '../../../../core/enums/fund_cluster.dart';

import '../../../../core/common/components/base_modal.dart';
import '../../../../core/utils/fund_cluster_to_readable_string.dart';
import '../../domain/entities/inventory_custodian_slip.dart';
import '../bloc/issuances_bloc.dart';
import 'custom_document_preview.dart';

class GenerateSemiExpendablePropertyCardModal extends StatelessWidget {
  GenerateSemiExpendablePropertyCardModal({
    super.key,
    required this.ics,
  });

  final InventoryCustodianSlipEntity ics;
  final ValueNotifier<FundCluster?> _selectedFundCluster = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FundCluster?>(
      valueListenable: _selectedFundCluster,
      builder: (context, fundCluster, _) {
        return BaseModal(
          width: 900.0,
          height: 350.0,
          headerTitle: 'Generate Semi Expendable Property Card',
          subtitle: 'Fill in the fund cluster before clicking generate.',
          content: _buildModalContent(context),
          footer: _ActionRows(
            ics: ics,
            fundCluster: fundCluster,
          ),
        );
      },
    );
  }

  Widget _buildModalContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ValueListenableBuilder<FundCluster?>(
          valueListenable: _selectedFundCluster,
          builder: (context, selectedFundCluster, _) {
            return CustomDropdownField<FundCluster>(
              value: selectedFundCluster,
              onChanged: (value) {
                _selectedFundCluster.value = value;
              },
              items: FundCluster.values
                  .map(
                    (fundCluster) => DropdownMenuItem<FundCluster>(
                      value: fundCluster,
                      child: Text(
                        fundCluster.toReadableString(),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                fontSize: 12.0, fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                  .toList(),
              fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                  ? AppColor.lightCustomTextBox
                  : AppColor.darkCustomTextBox),
              label: '* Fund Cluster',
              placeholderText: 'Enter fund cluster',
            );
          },
        ),
      ],
    );
  }
}

class _ActionRows extends StatelessWidget {
  const _ActionRows({
    super.key,
    required this.ics,
    required this.fundCluster,
  });

  final InventoryCustodianSlipEntity ics;
  final FundCluster? fundCluster;

  @override
  Widget build(BuildContext context) {
    return BlocListener<IssuancesBloc, IssuancesState>(
      listener: (context, state) {
        if (state is GeneratedSemiExpendablePropertyCardData) {
          context.pop();

          final data = {
            'ics': ics,
            'semi_expendable_property_card_data':
                state.semiExpendablePropertyCardData,
          };

          showCustomDocumentPreview(
            context: context,
            documentObject: data,
            docType: DocumentType.spc,
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
            onTap: () {
              if (fundCluster == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Please select a fund cluster before generating.'),
                  ),
                );
                return;
              }

              context.read<IssuancesBloc>().add(
                    GenerateSemiExpendablePropertyCardDataEvent(
                      icsId: ics.id,
                      fundCluster: fundCluster!,
                    ),
                  );
            },
            text: 'Generate',
            width: 180.0,
            height: 40.0,
          ),
        ],
      ),
    );
  }
}
