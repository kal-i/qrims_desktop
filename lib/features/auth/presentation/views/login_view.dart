import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_validator/form_validator.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/sizing/sizing_config.dart';
import '../../../../core/common/components/custom_loading_filled_button.dart';
import '../../../../core/enums/verification_purpose.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../components/custom_auth_password_text_box/bloc/custom_auth_password_text_box_bloc.dart';
import '../components/custom_auth_password_text_box/custom_auth_password_text_box.dart';
import '../../../../config/routes/app_routing_constants.dart';
import '../bloc/auth_bloc.dart';
import '../components/custom_email_text_box.dart';
import '../../../../config/themes/app_color.dart';
import '../components/custom_container.dart';
import '../../../../core/common/components/custom_filled_button/custom_filled_button.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLogin(
              email: _emailController.text,
              password: _passwordController.text,
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

        // we need to change the redirection of user to otp ver if we
        if (state is OtpRequired) {
          _isLoading.value = false;
          context.read<AuthBloc>().add(
                AuthSendOtp(
                  email: _emailController.text,
                ),
              );
        }

        if (state is OtpSent) {
          _isLoading.value = false;
          DelightfulToastUtils.showDelightfulToast(
            context: context,
            icon: Icons.check_circle_outline,
            title: 'Verify Email',
            subtitle: 'An OTP was sent to ${_emailController.text}.',
          );
          await Future.delayed(const Duration(seconds: 3));
          context.go(
            RoutingConstants.otpVerificationViewRoutePath,
            extra: {
              'email': _emailController.text,
              'purpose': VerificationPurpose.auth,
            },
          );
        }

        if (state is AuthSuccess) {
          _isLoading.value = false;
          DelightfulToastUtils.showDelightfulToast(
            context: context,
            icon: Icons.check_circle_outline,
            title: 'Success',
            subtitle: 'You have log-in successfully.',
          );
          context.read<CustomAuthPasswordTextBoxBloc>().add(ResetVisibility());
          await Future.delayed(const Duration(seconds: 3));
          context.go(RoutingConstants.dashboardViewRoutePath);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFormHeader(),
          // const SizedBox(
          //   height: 20.0,
          // ),
          const SizedBox(
            height: 10.0,
          ),
          Expanded(
            child: _buildForm(),
          ),
          const SizedBox(
            height: 30.0, //30
          ),
          CustomLoadingFilledButton(
            onTap: () => _login(),
            text: 'Sign in',
            isLoadingNotifier: _isLoading,
            height: 50.0,
          ),
          const SizedBox(
            height: 10.0,
          ),
          _buildNavigationButtonRow(),
        ],
      ),
    );
  }

  Widget _buildFormHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Sign in.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        // const SizedBox(
        //   height: 10.0,
        // ),
        // Text(
        //   'QR Code Inventory Management and Item Tracking System',
        //   style: Theme.of(context).textTheme.bodySmall,
        // ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomEmailTextBox(
            controller: _emailController,
          ),
          const SizedBox(
            height: 5.0,
          ),
          CustomAuthPasswordTextBox(
            placeHolderText: 'password',
            controller: _passwordController,
            validator:
                ValidationBuilder(requiredMessage: 'password is required')
                    .build(),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () => context.go(
                RoutingConstants.changeEmailViewRoutePath,
                extra: VerificationPurpose.resetPassword,
              ),
              child: Text(
                'Forgot Password?',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account?',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        TextButton(
          onPressed: () => context.go(RoutingConstants.registerViewRoutePath),
          child: Text(
            'Sign up',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
