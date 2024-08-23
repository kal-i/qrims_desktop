import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/themes/app_color.dart';
import 'bloc/button_bloc.dart';

class CustomFilledButtonWithBloc extends StatelessWidget {
  const CustomFilledButtonWithBloc({
    super.key,
    required this.onTap,
    required this.text,
    this.textColor,
    this.buttonColor = AppColor.button,
    this.height = 30.0,
    this.borderRadius = 5.0,
  });

  final VoidCallback onTap;
  final String text;
  final Color? textColor;
  final Color buttonColor;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ButtonBloc, ButtonState>(
      builder: (context, state) {
        return MouseRegion(
          onEnter: (_) => context.read<ButtonBloc>().add(HoverEntered()),
          onExit: (_) => context.read<ButtonBloc>().add(HoverExited()),
          child: GestureDetector(
            onTap: () {
              context.read<ButtonBloc>().add(ButtonTapped());
              onTap();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                color: state.color,
              ),
              child: Center(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: state.textColor,
                        fontSize: 16.0,
                      ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
