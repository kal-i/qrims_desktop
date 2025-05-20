import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_validator/form_validator.dart';

import '../../../config/themes/app_color.dart';
import '../../../config/themes/app_theme.dart';
import '../../../config/themes/bloc/theme_bloc.dart';

class CustomFormTextField extends StatefulWidget {
  const CustomFormTextField({
    super.key,
    this.controller,
    this.onTap,
    this.label,
    this.placeholderText,
    this.width,
    this.height,
    this.maxLines = 1,
    this.suffixIcon,
    this.suffixWidget,
    this.validator,
    this.enabled,
    this.isReadOnly = false,
    this.isNumeric = false,
    this.isCurrency = false,
    this.fillColor,
    this.hasValidation = true,
    this.isMultiline = false,
  });

  final TextEditingController? controller;
  final Function()? onTap;
  final String? label;
  final String? placeholderText;
  final double? width;
  final double? height;
  final int? maxLines;
  final IconData? suffixIcon;
  final Widget? suffixWidget;
  final String? Function(String?)? validator;
  final bool? enabled;
  final bool isReadOnly;
  final bool isNumeric;
  final bool isCurrency;
  final Color? fillColor;
  final bool hasValidation;
  final bool isMultiline;

  @override
  State<CustomFormTextField> createState() => _CustomFormTextFieldState();
}

class _CustomFormTextFieldState extends State<CustomFormTextField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<TextInputFormatter> inputFormatters;
    TextInputType keyboardType;

    if (widget.isNumeric && widget.isCurrency) {
      inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
      ];
      keyboardType = const TextInputType.numberWithOptions(decimal: true);
    } else if (widget.isNumeric) {
      inputFormatters = [FilteringTextInputFormatter.digitsOnly];
      keyboardType = TextInputType.number;
    } else {
      inputFormatters = [];
      keyboardType = TextInputType.text;
    }

    return SizedBox(
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            Text(
              widget.label!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          TextFormField(
            controller: widget.controller,
            enabled: widget.enabled,
            readOnly: widget.isReadOnly,
            focusNode: _focusNode,
            maxLines: widget.maxLines,
            keyboardType: widget.isMultiline
                ? TextInputType.multiline
                : (widget.maxLines == 1
                    ? TextInputType.text
                    : TextInputType.multiline),
            textInputAction: widget.isMultiline
                ? TextInputAction.newline
                : (widget.maxLines == 1
                    ? TextInputAction.next
                    : TextInputAction.newline),
            onEditingComplete: (!widget.isMultiline && widget.maxLines == 1)
                ? () => FocusScope.of(context).nextFocus()
                : null,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              filled: true,
              fillColor: widget.fillColor ??
                  (context.watch<ThemeBloc>().state == AppTheme.light
                      ? AppColor.lightBackground
                      : AppColor.darkBackground),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                // borderSide: BorderSide(
                //   color: Theme.of(context).dividerColor,
                //   width: 1.5,
                // ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                // borderSide: BorderSide(
                //   color: Theme.of(context).dividerColor,
                //   width: 1.5,
                // ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: AppColor.error,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: AppColor.accent,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: AppColor.error,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              hintText: widget.placeholderText,
              hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColor.darkPlaceHolderText,
                  ),
              suffixIcon: widget.suffixIcon != null
                  ? Icon(
                      widget.suffixIcon,
                      size: 20.0,
                    )
                  : widget.suffixWidget != null
                      ? SizedBox(width: 20.0, child: widget.suffixWidget)
                      : null,
            ),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
            onTap: widget.onTap,
            validator: widget.hasValidation
                ? widget.validator ??
                    ValidationBuilder(
                            requiredMessage: '${widget.label} is required')
                        .build()
                : null,
          ),
        ],
      ),
    );
  }
}
