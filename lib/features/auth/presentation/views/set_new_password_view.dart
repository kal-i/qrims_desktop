import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../bloc/auth_bloc.dart';
import '../components/custom_auth_password_text_box/custom_auth_password_text_box.dart';

import '../../../../config/routes/app_routing_constants.dart';
import '../components/custom_outline_button.dart';
import 'base_auth_view.dart';
import '../../../../config/themes/app_color.dart';
import '../components/custom_container.dart';
import '../../../../core/common/components/custom_filled_button/custom_filled_button.dart';

class SetNewPasswordView extends StatefulWidget {
  const SetNewPasswordView({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<SetNewPasswordView> createState() => _SetNewPasswordViewState();
}

class _SetNewPasswordViewState extends State<SetNewPasswordView> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      /// need to trigger this first
      if (_passwordController.text != _confirmPasswordController.text) {
        DelightfulToastUtils.showDelightfulToast(
          context: context,
          icon: Icons.error_outline,
          title: 'Error',
          subtitle: 'Password and Confirm Password did not match.',
        );
      } else {
        context.read<AuthBloc>().add(
              AuthResetPassword(
                  email: widget.email, password: _passwordController.text),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthFailure) {
          DelightfulToastUtils.showDelightfulToast(
            context: context,
            icon: Icons.error_outline,
            title: 'Error',
            subtitle: state.message,
          );
        }

        if (state is AuthSuccess) {
          DelightfulToastUtils.showDelightfulToast(
            context: context,
            icon: Icons.check_circle_outline,
            title: 'Success',
            subtitle: 'Password updated successfully.',
          );
          await Future.delayed(const Duration(seconds: 3));
          context.go(RoutingConstants.loginViewRoutePath);
        }
      },
      child: Column(
        children: [
          _buildFormHeader(),
          const SizedBox(
            height: 50.0,
          ),
          Expanded(
            child: _buildForm(),
          ),
          const SizedBox(
            height: 30.0,
          ),
          _buildNavigationActionRow(),
        ],
      ),
    );
  }

  Widget _buildFormHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Set up New Password.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(
          height: 10.0,
        ),
        Text(
          'Please create a secure password.',
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 70.0,
            child: CustomAuthPasswordTextBox(
              placeHolderText: 'password',
              controller: _passwordController,
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          SizedBox(
            height: 70.0,
            child: CustomAuthPasswordTextBox(
              placeHolderText: 'confirm password',
              controller: _confirmPasswordController,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationActionRow() {
    return Row(
      children: [
        Expanded(
          child: CustomOutlineButton(
            onTap: () => context.go(RoutingConstants.loginViewRoutePath),
            text: 'Cancel',
            height: 50.0,
          ),
        ),
        const SizedBox(
          width: 30.0,
        ),
        Expanded(
          child: CustomFilledButtonWithBloc(
            onTap: () => _changePassword(),
            text: 'Change Password',
            textColor: AppColor.lightPrimary,
            height: 50.0,
          ),
        ),
      ],
    );
  }
}

// TODO: if we put a timer for otp resend, use stream
