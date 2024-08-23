import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_validator/form_validator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/enums/verification_purpose.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../components/custom_auth_password_text_box/custom_auth_password_text_box.dart';
import '../../../../config/routes/app_routing_constants.dart';
import '../bloc/auth_bloc.dart';
import '../components/custom_email_text_box.dart';
import 'base_auth_view.dart';
import '../../../../config/themes/app_color.dart';
import '../components/custom_container.dart';
import '../../../../core/common/components/custom_filled_button/custom_filled_button.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

          // we need to change the redirection of user to otp ver if we
          if (state is OtpRequired) {
            context.read<AuthBloc>().add(
                  AuthSendOtp(
                    email: _emailController.text,
                  ),
                );
          }

          if (state is OtpSent) {
            context.go(
              RoutingConstants.otpVerificationViewRoutePath,
              extra: {
                'email': _emailController.text,
                'purpose': VerificationPurpose.auth,
              },
            );
          }

          if (state is AuthSuccess) {
            DelightfulToastUtils.showDelightfulToast(
              context: context,
              icon: Icons.check_circle_outline,
              title: 'Success',
              subtitle: 'You have log-in successfully.',
            );
            await Future.delayed(const Duration(seconds: 3));

            context.go(RoutingConstants.dashboardViewRoutePath);
          }
        },
        child: CustomContainer(
          width: 500,
          height: 600,
          paddingTop: 50.0,
          paddingLeft: 50.0,
          paddingBottom: 20.0,
          paddingRight: 50.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign in.',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(
                height: 10.0,
              ),
              Text(
                'QR Code Inventory Management and Item Tracking System',
                style: Theme.of(context).textTheme.titleSmall,
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
                      const SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                        height: 70.0,
                        child: CustomAuthPasswordTextBox(
                          placeHolderText: 'password',
                          controller: _passwordController,
                          validator: ValidationBuilder(requiredMessage: 'password is required').build(),
                        ),
                      ),
                      // const SizedBox(
                      //   height: 10.0,
                      // ),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: () => context
                              .go(RoutingConstants.forgotPasswordViewRoutePath),
                          child: Text(
                            'Forgot Password?',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColor.darkHighlightedText,
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0, //30
              ),
              CustomFilledButtonWithBloc(
                onTap: () => _login(),
                text: 'Sign in',
                textColor: AppColor.lightPrimary,
                height: 50.0,
              ),
              const SizedBox(
                height: 15.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account?',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  TextButton(
                    onPressed: () =>
                        context.go(RoutingConstants.registerViewRoutePath),
                    child: Text(
                      'Sign up',
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
