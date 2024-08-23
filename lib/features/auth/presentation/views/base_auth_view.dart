import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../../config/themes/bloc/theme_bloc.dart';
import '../../../../core/common/components/custom_drag_to_move_area.dart';
import '../bloc/auth_bloc.dart';
import '../components/custom_container.dart';
import 'package:window_manager/window_manager.dart';
import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
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
      body: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
        return ModalProgressHUD(
          inAsyncCall: state is AuthLoading,
          opacity: 0.5,
          blur: 0.5,
          child: _BaseAuthViewContent(
            content: child,
          ),
        );
      }),
    );
  }
}

class _BaseAuthViewHeader extends StatelessWidget {
  const _BaseAuthViewHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomDragToMoveArea(
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
            height: 60.0,
          ),
          Expanded(
            child: Center(
              child: content,
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          CustomContainer(
            child: IconButton(
              onPressed: () {
                context.read<ThemeBloc>().add(ToggleTheme());
              },
              icon: context.watch<ThemeBloc>().state == AppTheme.light
                  ? const Icon(
                      Icons.light_mode_outlined,
                      color: AppColor.darkPrimary,
                      size: 20.0,
                    )
                  : const Icon(
                      Icons.dark_mode_outlined,
                      color: AppColor.lightPrimary,
                      size: 20.0,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
