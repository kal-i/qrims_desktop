import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../config/themes/app_color.dart';
import '../bloc/auth_bloc.dart';
import '../components/custom_container.dart';
import '../components/custom_theme_switch_button.dart';
import '../components/window_close_button.dart';

class BaseAuthView extends StatelessWidget {
  const BaseAuthView({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return _BaseAuthViewContent(
            content: child,
          );
        },
      ),
    );
  }
}

class _BaseAuthViewHeader extends StatelessWidget {
  const _BaseAuthViewHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      //CustomDragToMoveArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'qrims.',
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ],
          ),
          const WindowCloseButton(),
        ],
      ),
    );
  }
}

class _BaseAuthViewContent extends StatelessWidget {
  const _BaseAuthViewContent({
    super.key,
    required this.content,
  });

  final Widget content;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      return Padding(
        padding: const EdgeInsets.only(
          top: 10.0,
          left: 20.0,
          bottom: 20.0,
          right: 20.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _BaseAuthViewHeader(),
            const SizedBox(
              height: 20.0, // 60.0,
            ),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 500.0,
                  height: 520.0,
                  child: CustomContainer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: ModalProgressHUD(
                        inAsyncCall: state is AuthLoading,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 50.0,
                            left: 50.0,
                            bottom: 20.0,
                            right: 50.0,
                          ),
                          child: content,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            const CustomThemeSwitchButton(),
          ],
        ),
      );
    });
  }
}
