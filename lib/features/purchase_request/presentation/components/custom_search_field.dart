import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:form_validator/form_validator.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';

class CustomSearchField extends StatelessWidget {
  const CustomSearchField({
    super.key,
    required this.suggestionsCallback,
    required this.onSelected,
    required this.controller,
    this.label,
    this.placeHolderText,
    this.maxLines = 1,
    this.enabled,
    this.scrollController,
  });

  final FutureOr<List<String>?> Function(String) suggestionsCallback;
  final void Function(String)? onSelected;
  final TextEditingController controller;
  final String? label;
  final String? placeHolderText;
  final int? maxLines;
  final bool? enabled;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
        TypeAheadField<String>(
          controller: controller,
          constraints: const BoxConstraints(
            maxHeight: 300.0,
          ),
          //hideOnEmpty: true,
          builder: (context, controller, focusNode) {
            return TextFormField(
              enabled: enabled,
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                filled: true,
                fillColor: context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightBackground
                    : AppColor.darkBackground,
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
                hintText: placeHolderText,
                hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColor.darkPlaceHolderText,
                ),
              ),
              maxLines: maxLines,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
              validator:
                  ValidationBuilder(requiredMessage: '$label is required')
                      .build(),
            );
          },
          itemBuilder: (context, itemName) {
            return ListTile(
              title: Text(
                itemName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            );
          },
          onSelected: onSelected,
          decorationBuilder: (context, child) {
            return Material(
              type: MaterialType.card,
              elevation: 4,
              borderRadius: BorderRadius.circular(10.0),
              child: child,
            );
          },
          //itemSeparatorBuilder: ,
          errorBuilder: (context, error) {
            String message = 'An error has occurred: $error';
            return Center(
              child: Text(
                message,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            );
          },
          emptyBuilder: (context) {
            return Center(
              child: Text(
                'No data found.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            );
          },
          suggestionsCallback: suggestionsCallback,
          scrollController: scrollController,
        ),
      ],
    );
  }
}
