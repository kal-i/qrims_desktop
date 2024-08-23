import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/enums/verification_purpose.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/common/components/custom_filled_button/custom_filled_button.dart';

import '../../../../config/routes/app_routing_constants.dart';
import '../../../../config/themes/app_color.dart';
import '../components/custom_container.dart';
import '../components/custom_email_text_box.dart';
import 'base_auth_view.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
    return BaseAuthView(
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthFailure) {
            DelightfulToastUtils.showDelightfulToast(
              context: context,
              icon: Icons.error_outline,
              title: 'Error',
              subtitle: state.message,
            );
          }

          if (state is OtpSent) {
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
        child: CustomContainer(
          width: 500.0,
          height: 600.0,
          paddingTop: 50.0,
          paddingLeft: 50.0,
          paddingBottom: 20.0,
          paddingRight: 50.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Forgot Password?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(
                height: 10.0,
              ),
              Text(
                'Please enter your email address, and we will send you an email OTP to reset your password.',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(height: 2.0,),
              ),
              const SizedBox(
                height: 40.0,
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 70.0,
                        child: CustomEmailTextBox(
                          controller: _emailController,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CustomFilledButtonWithBloc(
                onTap: () => _sendCode(),
                text: 'Send Code',
                height: 50.0,
                textColor: AppColor.lightPrimary,
              ),
              const SizedBox(
                height: 15.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Go back to sign in?',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  TextButton(
                    onPressed: () =>
                        context.go(RoutingConstants.registerViewRoutePath),
                    child: Text(
                      'Click here',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColor.darkHighlightedText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
