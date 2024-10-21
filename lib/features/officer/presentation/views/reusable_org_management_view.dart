import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReusableOrgManagementView extends StatefulWidget {
  const ReusableOrgManagementView({super.key});

  @override
  State<ReusableOrgManagementView> createState() =>
      _ReusableOrgManagementViewState();
}

class _ReusableOrgManagementViewState extends State<ReusableOrgManagementView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildNavLink(),
        const SizedBox(
          height: 30.0,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: _buildForm(),
          ),
        ),
      ],
    );
  }

  Widget _buildNavLink() {
    return Row(
      children: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            'Officers Overview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      child: Column(),
    );
  }

  Widget _buildOfficerForm() {
    return Column(
      children: [
        Text(
          'Officer Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
              ),
        ),

        const SizedBox(
          height: 20.0,
        ),

        Row(
          children: [

          ],
        ),
      ],
    );
  }
}
