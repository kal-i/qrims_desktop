import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/themes/app_color.dart';
import '../../../config/themes/app_theme.dart';
import '../../../config/themes/bloc/theme_bloc.dart';

class FilterButton extends StatelessWidget {
  const FilterButton({
    super.key,
    required this.filterValue,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  final String filterValue;
  final String text;
  final bool isSelected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10.0),
      color: isSelected
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        hoverColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
        splashColor:
        Theme.of(context).scaffoldBackgroundColor.withOpacity(0.03),
        onTap: () => onTap(filterValue),
        child: Container(
          width: 100.0,
          height: 40.0,
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Center(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 13.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FilterTableRow extends StatelessWidget {
  const FilterTableRow({
    super.key,
    required this.selectedFilterNotifier,
    required this.filterMapping,
  });

  final ValueNotifier<String> selectedFilterNotifier;
  final Map<String, String> filterMapping;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: (context.watch<ThemeBloc>().state == AppTheme.light
            ? AppColor.lightPrimary
            : AppColor.darkSecondary),
      ),
      child: Row(
        children: filterMapping.entries.map((entry) {
          String label = entry.key;
          String filterValue = entry.value;

          return ValueListenableBuilder(
            valueListenable: selectedFilterNotifier,
            builder: (context, selectedFilter, child) {
              return FilterButton(
                filterValue: filterValue,
                text: label,
                isSelected: selectedFilter == filterValue,
                onTap: (String newFilterValue) {
                  print(newFilterValue);
                  selectedFilterNotifier.value = newFilterValue;
                },
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

// ValueChanged<int> onTap is a callback func that takes int as param
// to notify parent widget when tapped, passing the index of the tapped btn

// asMap() converts list of string into a Map<int, String>, where item's index
// is the key and the item itself it the value

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../config/themes/app_color.dart';
// import '../../../config/themes/app_theme.dart';
// import '../../../config/themes/bloc/theme_bloc.dart';
//
// class FilterButton extends StatelessWidget {
//   const FilterButton({
//     super.key,
//     required this.index,
//     required this.text,
//     required this.isSelected,
//     required this.onTap,
//   });
//
//   final int index;
//   final String text;
//   final bool isSelected;
//   final ValueChanged<int> onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       borderRadius: BorderRadius.circular(10.0),
//       color: isSelected
//           ? Theme.of(context).scaffoldBackgroundColor
//           : Colors.transparent,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(10.0),
//         hoverColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
//         splashColor:
//             Theme.of(context).scaffoldBackgroundColor.withOpacity(0.03),
//         onTap: () => onTap(index),
//         child: Container(
//           width: 100.0,
//           height: 40.0,
//           padding: const EdgeInsets.all(10.0),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10.0),
//           ),
//           child: Center(
//             child: Text(
//               text,
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontSize: 13.0,
//                   ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class FilterTableRow extends StatelessWidget {
//   const FilterTableRow({
//     super.key,
//     required this.selectedIndexNotifier,
//     required this.filterOptions,
//   });
//
//   final ValueNotifier<int> selectedIndexNotifier;
//   final List<String> filterOptions;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 50.0,
//       padding: const EdgeInsets.all(5.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10.0),
//         color: (context.watch<ThemeBloc>().state == AppTheme.light
//             ? AppColor.lightSecondary
//             : AppColor.darkSecondary),
//       ),
//       child: Row(
//         children: filterOptions.asMap().entries.map((entry) {
//           int index = entry.key;
//           String text = entry.value;
//
//           return ValueListenableBuilder(
//             valueListenable: selectedIndexNotifier,
//             builder: (context, selectedIndex, child) {
//               return FilterButton(
//                 index: index,
//                 text: text,
//                 isSelected: selectedIndex == index,
//                 onTap: (int newIndex) {
//                   selectedIndexNotifier.value = newIndex;
//                 },
//               );
//             },
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
//
// // ValueChanged<int> onTap is a callback func that takes int as param
// // to notify parent widget when tapped, passing the index of the tapped btn
//
// // asMap() converts list of string into a Map<int, String>, where item's index
// // is the key and the item itself it the value