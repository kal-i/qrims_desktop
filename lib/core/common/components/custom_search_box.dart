import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../../config/themes/app_color.dart';
import '../../../config/themes/app_theme.dart';
import '../../../config/themes/bloc/theme_bloc.dart';

class CustomSearchBox extends StatelessWidget {
  const CustomSearchBox({
    super.key,
    required this.suggestionsCallback,
    required this.onSelected,
    required this.controller,
    required this.label,
    this.enabled,
  });

  final FutureOr<List<String>?> Function(String) suggestionsCallback;
  final void Function(String)? onSelected;
  final TextEditingController controller;
  final String label;
  final bool? enabled;

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<String>(
      controller: controller,
      builder: (context, controller, focusNode) {
        return TextField(
          enabled: enabled,
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            filled: false,
            fillColor: context.watch<ThemeBloc>().state == AppTheme.light
                ? AppColor.lightBackground
                : AppColor.darkBackground,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightOutlineBorder
                    : AppColor.darkOutlineBorder,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: AppColor.error,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: AppColor.accent,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            label: Text(label),
            labelStyle: Theme.of(context).textTheme.bodySmall,
          ),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
              ),
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
            'No items found!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
          ),
        );
      },
      suggestionsCallback: suggestionsCallback,
    );
  }
}
