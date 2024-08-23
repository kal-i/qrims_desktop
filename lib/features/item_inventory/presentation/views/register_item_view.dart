// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
//
// import '../../../../core/common/components/base_container.dart';
// import '../../../../core/common/components/custom_dropdown_button.dart';
// import '../../../../core/common/components/custom_labeled_text_box.dart';
// import '../../../../core/common/components/custom_date_picker.dart';
// import '../../../../core/enums/asset_classification.dart';
// import '../../../../core/enums/asset_sub_class.dart';
// import '../../../../core/utils/delightful_toast_utils.dart';
// import '../../../../core/utils/readable_enum_converter.dart';
// import '../../../auth/presentation/components/custom_outline_button.dart';
// import '../bloc/item_inventory_bloc.dart';
//
// class RegisterItemView extends StatefulWidget {
//   const RegisterItemView({super.key});
//
//   @override
//   State<RegisterItemView> createState() => _RegisterItemViewState();
// }
//
// class _RegisterItemViewState extends State<RegisterItemView> {
//   final _formKey = GlobalKey<FormState>();
//   final _brandController = TextEditingController();
//   final _manufacturerController = TextEditingController();
//   final _modelController = TextEditingController();
//   final _serialNoController = TextEditingController();
//   final _specificationController = TextEditingController();
//   final _unitController = TextEditingController();
//   final _quantityController = TextEditingController();
//   final _unitCostController = TextEditingController();
//   final _estimatedUsefulLifeController = TextEditingController();
//
//   final ValueNotifier<int> _quantity = ValueNotifier(0);
//
//   late AssetClassification? _selectedAssetClassification;
//   late AssetSubClass? _selectedAssetSubClassification;
//
//   late DateTime? _pickedDate;
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedAssetClassification = null;
//     _selectedAssetSubClassification = null;
//     _pickedDate = DateTime.now();
//
//     _quantityController.addListener(() {
//       final newQuantity = int.tryParse(_quantityController.text) ?? 0;
//       _quantity.value = newQuantity;
//     });
//
//     _quantity.addListener(() {
//       _quantityController.text = _quantity.value.toString();
//     });
//   }
//
//   @override
//   void dispose() {
//     _brandController.dispose();
//     _manufacturerController.dispose();
//     _modelController.dispose();
//     _serialNoController.dispose();
//     _specificationController.dispose();
//     _unitController.dispose();
//     _quantityController.dispose();
//     _unitCostController.dispose();
//     _estimatedUsefulLifeController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<ItemInventoryBloc, ItemInventoryState>(
//       listener: (context, state) async {
//         if (state is ItemRegistered) {
//           DelightfulToastUtils.showDelightfulToast(
//             context: context,
//             icon: Icons.check_circle_outline,
//             title: 'Success',
//             subtitle: 'Item registered successfully.',
//           );
//           await Future.delayed(const Duration(seconds: 3));
//           context.pop();
//         }
//
//         if (state is ItemsError) {
//           print(state.message);
//           DelightfulToastUtils.showDelightfulToast(
//             context: context,
//             icon: Icons.error_outline,
//             title: 'Error',
//             subtitle: state.message,
//           );
//         }
//       },
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildNavLink(),
//           const SizedBox(
//             height: 10.0,
//           ),
//           Expanded(
//             child: BaseContainer(
//               child: SingleChildScrollView(
//                 child: _buildForm(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNavLink() {
//     return Row(
//       children: [
//         TextButton(
//           onPressed: () => context.pop(),
//           child: Text(
//             'Inventory Overview',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontSize: 14.0,
//                 ),
//           ),
//         ),
//         const SizedBox(width: 8.0),
//         Icon(
//           CupertinoIcons.chevron_forward,
//           color: Theme.of(context).dividerColor,
//           size: 20.0,
//         ),
//         const SizedBox(width: 8.0),
//         Text(
//           'Register Item',
//           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                 fontSize: 14.0,
//               ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildForm() {
//     return Form(
//       key: _formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Item Description',
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//               fontSize: 18.0,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const SizedBox(height: 20.0),
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     CustomLabeledTextBox(
//                       label: 'Brand',
//                       controller: _brandController,
//                     ),
//                     const SizedBox(height: 20.0),
//                     CustomLabeledTextBox(
//                       label: 'Model',
//                       controller: _modelController,
//                     ),
//                     const SizedBox(height: 20.0),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 20.0),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     CustomLabeledTextBox(
//                       label: 'Manufacturer',
//                       controller: _manufacturerController,
//                     ),
//                     const SizedBox(height: 20.0),
//                     CustomLabeledTextBox(
//                       label: 'Serial No.',
//                       controller: _serialNoController,
//                     ),
//                     const SizedBox(height: 20.0),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           CustomLabeledTextBox(
//             label: 'Specification',
//             maxLines: 4,
//             controller: _specificationController,
//           ),
//           const SizedBox(
//             height: 40.0,
//           ),
//           Text(
//             'Other Information',
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//               fontSize: 18.0,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const SizedBox(
//             height: 20.0,
//           ),
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     CustomDropdownButton(
//                       onChanged: (String? value) {
//                         if (value != null && value.isNotEmpty) {
//                           _selectedAssetClassification =
//                               AssetClassification.values.firstWhere(
//                                     (e) =>
//                                 e.toString().split('.').last ==
//                                     value.split('.').last,
//                               );
//                           print(_selectedAssetClassification);
//                         }
//                       },
//                       label: 'Asset Classification',
//                       items: AssetClassification.values
//                           .map(
//                             (assetClassification) =>
//                             DropdownMenuItem<String>(
//                               value: assetClassification.toString(),
//                               child: Text(
//                                 readableEnumConverter(
//                                     assetClassification),
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .bodySmall,
//                               ),
//                             ),
//                       )
//                           .toList(),
//                     ),
//                     const SizedBox(height: 20.0),
//                     CustomLabeledTextBox(
//                       label: 'Unit',
//                       controller: _unitController,
//                     ),
//                     const SizedBox(height: 20.0),
//                     CustomLabeledTextBox(
//                       label: 'Unit Cost',
//                       controller: _unitCostController,
//                       isNumeric: true,
//                       isCurrency: true,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 20.0),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     CustomDropdownButton(
//                       onChanged: (String? value) {
//                         if (value != null && value.isNotEmpty) {
//                           _selectedAssetSubClassification =
//                               AssetSubClass.values.firstWhere(
//                                     (e) =>
//                                 e.toString().split('.').last ==
//                                     value.split('.').last,
//                               );
//                         }
//                       },
//                       label: 'Asset Sub Class',
//                       items: AssetSubClass.values
//                           .map(
//                             (assetSubClass) =>
//                             DropdownMenuItem<String>(
//                               value: assetSubClass.toString(),
//                               child: Text(
//                                 readableEnumConverter(
//                                     assetSubClass),
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .bodySmall,
//                               ),
//                             ),
//                       )
//                           .toList(),
//                     ),
//                     const SizedBox(height: 20.0),
//                     ValueListenableBuilder(
//                       valueListenable: _quantity,
//                       builder: (BuildContext context, int value, Widget? child) {
//                         return CustomLabeledTextBox(
//                           label: 'Quantity',
//                           controller: _quantityController,
//                           isNumeric: true,
//                           suffixWidget: Column(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               InkWell(
//                                 onTap: () {
//                                   _quantity.value++;
//                                   _quantityController.text == _quantity.value.toString();
//                                 },
//                                 child: const Icon(
//                                   Icons.keyboard_arrow_up,
//                                   size: 18.0,
//                                 ),
//                               ),
//                               InkWell(
//                                 onTap: () {
//                                   _quantity.value--;
//                                   _quantityController.text == _quantity.value.toString();
//                                 },
//                                 child: const Icon(
//                                   Icons.keyboard_arrow_down,
//                                   size: 18.0,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 20.0),
//                     CustomLabeledTextBox(
//                       label: 'Estimated Useful Life',
//                       controller: _estimatedUsefulLifeController,
//                       isNumeric: true,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(
//             height: 20.0,
//           ),
//           CustomDatePicker(
//             onDateChanged: (DateTime? date) {
//               print(date);
//               _pickedDate = date;
//             },
//             label: 'Acquired Date',
//             initialDate: DateTime.now(),
//           ),
//           const SizedBox(
//             height: 20.0,
//           ),
//           _buildActions(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActions() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         CustomOutlineButton(
//           onTap: () => context.pop(),
//           text: 'Cancel',
//           height: 40.0,
//         ),
//         const SizedBox(
//           width: 10.0,
//         ),
//         CustomOutlineButton(
//           onTap: _saveItem,
//           text: 'Save',
//           height: 40.0,
//         ),
//       ],
//     );
//   }
//
//   void _saveItem() {
//     print('''
//     ${_specificationController.text}
//     ${_brandController.text}
//     ${_modelController.text}
//     ${_serialNoController.text}
//     ${_manufacturerController.text}
//     $_selectedAssetClassification
//     $_selectedAssetSubClassification
//     ${_unitController.text}
//     ${_quantityController.text}
//     ${_unitCostController.text}
//     ${_estimatedUsefulLifeController.text}
//     $_pickedDate
//     ''');
//
//     // if (_formKey.currentState!.validate()) {
//     //   context.read<ItemInventoryBloc>().add(
//     //         ItemRegister(
//     //           specification: _specificationController.text,
//     //           brand: _brandController.text,
//     //           model: _modelController.text,
//     //           serialNo: _serialNoController.text,
//     //           manufacturer: _manufacturerController.text,
//     //           assetClassification: _selectedAssetClassification,
//     //           assetSubClass: _selectedAssetSubClassification,
//     //           unit: _unitController.text,
//     //           quantity: int.parse(_quantityController.text),
//     //           unitCost: double.parse(_unitCostController.text),
//     //           estimatedUsefulLife:
//     //               int.parse(_estimatedUsefulLifeController.text),
//     //           acquiredDate: _pickedDate,
//     //         ),
//     //       );
//     // }
//   }
// }
