import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/common/components/custom_loading_filled_button.dart';
import '../../../../core/enums/verification_purpose.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/common/components/custom_filled_button/custom_filled_button.dart';

import '../../../../config/routes/app_routing_constants.dart';
import '../../../../config/themes/app_color.dart';
import '../components/custom_container.dart';
import '../components/custom_email_text_box.dart';
import 'base_auth_view.dart';

class ChangeEmailView extends StatefulWidget {
  const ChangeEmailView({
    super.key,
    required this.purpose,
  });

  final VerificationPurpose purpose;

  @override
  State<ChangeEmailView> createState() => _ChangeEmailViewState();
}

class _ChangeEmailViewState extends State<ChangeEmailView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  @override
  void dispose() {
    _emailController.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  void _sendCode() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthSendOtp(
              email: _emailController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthLoading) {
          _isLoading.value = true;
        }

        if (state is AuthFailure) {
          _isLoading.value = false;
          DelightfulToastUtils.showDelightfulToast(
            context: context,
            icon: Icons.error_outline,
            title: 'Error',
            subtitle: state.message,
          );
        }

        if (state is OtpSent) {
          _isLoading.value = false;
          DelightfulToastUtils.showDelightfulToast(
            context: context,
            icon: Icons.check_circle_outline,
            title: 'Success',
            subtitle: 'An OTP was sent to ${_emailController.text}.',
          );
          await Future.delayed(const Duration(seconds: 3));
          context.go(
            RoutingConstants.otpVerificationViewRoutePath,
            extra: {
              'email': _emailController.text,
              'purpose': VerificationPurpose.resetPassword,
            },
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFormHeader(),
          const SizedBox(
            height: 20.0,
          ),
          Expanded(
            child: _buildForm(),
          ),
          CustomLoadingFilledButton(
            onTap: () => _sendCode(),
            text: 'Send Code',
            isLoadingNotifier: _isLoading,
            height: 50.0,
          ),
          const SizedBox(
            height: 10.0,
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
          widget.purpose == VerificationPurpose.auth ? 'Change Email?' : 'Forgot Password?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(
          height: 10.0,
        ),
        Text(
          'Please enter your email address, and we will send you an email OTP.',
          style: Theme.of(context).textTheme.bodySmall,
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
          CustomEmailTextBox(
            controller: _emailController,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationActionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Go back to sign in?',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        TextButton(
          onPressed: () => context.go(RoutingConstants.loginViewRoutePath),
          child: Text(
            'Click here',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
