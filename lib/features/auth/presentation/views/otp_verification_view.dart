import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';
import '../../../../core/enums/verification_purpose.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../bloc/auth_bloc.dart';
import '../components/custom_container.dart';
import '../../../../core/common/components/custom_filled_button/custom_filled_button.dart';
import '../components/custom_otp_text_box.dart';
import '../components/custom_outline_button.dart';
import 'base_auth_view.dart';

import '../../../../config/routes/app_routing_constants.dart';
import '../../../../config/themes/app_color.dart';

class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({
    super.key,
    required this.email,
    required this.purpose,
  });

  final String email;
  final VerificationPurpose purpose;

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final _firstCodeController = TextEditingController();
  final _secondCodeController = TextEditingController();
  final _thirdCodeController = TextEditingController();
  final _fourthCodeController = TextEditingController();

  @override
  void dispose() {
    _firstCodeController.dispose();
    _secondCodeController.dispose();
    _thirdCodeController.dispose();
    _fourthCodeController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    context.read<AuthBloc>().add(
          AuthVerifyOtp(
            email: widget.email,
            otp:
                '${_firstCodeController.text}${_secondCodeController.text}${_thirdCodeController.text}${_fourthCodeController.text}',
            purpose: widget.purpose,
          ),
        );
  }

  void _resentOtp() {
    context.read<AuthBloc>().add(
          AuthSendOtp(
            email: widget.email,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = context.watch<ThemeBloc>().state;

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
              subtitle: 'An OTP was sent to ${widget.email}.',
            );
          }

          if (state is AuthSuccess) {
            print('otp ver. success');
            if (widget.purpose == VerificationPurpose.resetPassword) {
              context.go(
                RoutingConstants.setUpNewPasswordViewRoutePath,
                extra: widget.email,
              );
            } else if (widget.purpose == VerificationPurpose.auth) {
              DelightfulToastUtils.showDelightfulToast(
                context: context,
                icon: Icons.check_circle_outline,
                title: 'Success',
                subtitle: 'Account verified successfully.',
              );
              await Future.delayed(const Duration(seconds: 3));
              context.go(RoutingConstants.loginViewRoutePath);
            }
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Verification.',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(
                height: 10.0,
              ),
              Text(
                'Please check your email for a verification code sent to',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                children: [
                  Text(
                    widget.email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: currentTheme == AppTheme.light
                              ? AppColor.darkPrimary
                              : AppColor.lightPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  TextButton(
                    onPressed: () => context.go(
                      RoutingConstants.forgotPasswordViewRoutePath,
                    ),
                    child: Text(
                      '\t\t\tChange email address?',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColor.darkHighlightedText,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 40.0,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Form(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomOtpTextBox(
                            controller: _firstCodeController,
                          ),
                          CustomOtpTextBox(
                            controller: _secondCodeController,
                          ),
                          CustomOtpTextBox(
                            controller: _thirdCodeController,
                          ),
                          CustomOtpTextBox(
                            controller: _fourthCodeController,
                          ),
                        ],
                      ),
                    ),
                    // RichText(
                    //   text: TextSpan(
                    //     text: 'Resend code after ',
                    //     style: Theme.of(context).textTheme.bodySmall,
                    //     children: [
                    //       TextSpan(
                    //         text: '00:00',
                    //         style:
                    //             Theme.of(context).textTheme.bodySmall?.copyWith(
                    //                   color: AppColor.darkHighlightedText,
                    //                 ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30.0,
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomOutlineButton(
                      onTap: () => _resentOtp(),
                      text: 'Resend',
                      height: 50.0,
                    ),
                  ),
                  const SizedBox(
                    width: 30.0,
                  ),
                  Expanded(
                    child: CustomFilledButtonWithBloc(
                      onTap: () => _verifyOtp(),
                      text: 'Submit Code',
                      height: 50.0,
                      textColor: AppColor.lightPrimary,
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
