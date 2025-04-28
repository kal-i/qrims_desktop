import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_form_text_field.dart';
import '../../../../core/common/components/reusable_linear_progress_indicator.dart';
import '../bloc/issuances_bloc.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<IssuancesBloc, IssuancesState>(
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
    );
  }

  Widget _buildMainView() {
    return Column(
      spacing: 50.0,
      children: [
        _buildAccountableOfficerInformationSection(),
        _buildAccountabilityList(),
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
          'Accountable officer involved to this issuance.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Row(
          spacing: 20.0,
          children: [
            Expanded(
              child: CustomFormTextField(
                label: 'Office',
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
              ),
            ),
            Expanded(
              child: CustomFormTextField(
                label: 'Position',
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
              ),
            ),
            Expanded(
              child: CustomFormTextField(
                label: 'Name',
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
              ),
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
        // in the row, we add export to excel and date range
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
                  'Accountable officer involved to this issuance.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ],
            ),
            const Row(
              children: [
                CustomFilledButton(
                  height: 40.0,
                  prefixWidget: Icon(
                    HugeIcons.strokeRoundedDownload04,
                    size: 15.0,
                    color: Colors.white,
                  ),
                  text: 'Export to xlxs',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20.0),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = (constraints.maxWidth ~/ 250).clamp(1, 4);

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              //itemCount: widget.accountabilities.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20.0,
                mainAxisSpacing: 20.0,
                childAspectRatio: 1.5,
              ),
              itemBuilder: (context, index) {
                //final accountability = widget.accountabilities[index];
                return ItemCard(
                  data: {}, //accountability,
                  isAccountability: true,
                  onRemove: () {
                    // handle removing if needed
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
