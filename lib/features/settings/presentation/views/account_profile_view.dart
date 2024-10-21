import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/custom_labeled_text_box.dart';
import '../../../../core/common/components/custom_message_box.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/constants/assets_path.dart';
import '../../../../core/models/supply_department_employee.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/components/custom_outline_button.dart';

class AccountProfileView extends StatefulWidget {
  const AccountProfileView({super.key});

  @override
  State<AccountProfileView> createState() => _AccountProfileViewState();
}

class _AccountProfileViewState extends State<AccountProfileView> {
  SupplyDepartmentEmployeeModel? _user;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          _errorMessage = null;
        }

        if (state is UserInfoUpdated) {
          _errorMessage = null;
          _user = SupplyDepartmentEmployeeModel.fromEntity(state.updatedUser);
          DelightfulToastUtils.showDelightfulToast(
            context: context,
            title: 'Success',
            subtitle: 'Updated',
          );
        }

        if (state is AuthFailure) {
          _errorMessage = state.message;
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthSuccess) {
            _user = SupplyDepartmentEmployeeModel.fromEntity(state.data);
          }

          if (state is UserInfoUpdated) {
            _user = SupplyDepartmentEmployeeModel.fromEntity(state.updatedUser);
          }

          return Column(
            children: [
              if (_errorMessage != null)
                Center(
                  child: CustomMessageBox.error(
                    message: _errorMessage!,
                  ),
                ),
              if (_user != null)
                _Profile(
                  userModel: _user!,
                ),
              const SizedBox(
                height: 50.0,
              ),
              Expanded(
                child: _AccountSecurity(
                  userModel: _user!,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Profile extends StatefulWidget {
  const _Profile({
    super.key,
    required this.userModel,
  });

  final SupplyDepartmentEmployeeModel userModel;

  @override
  State<_Profile> createState() => _ProfileState();
}

class _ProfileState extends State<_Profile> {
  Future<void> _uploadImage(String userId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      // get path of selected file
      final file = File(result.files.single.path!);

      // read file as bytes
      final bytes = await file.readAsBytes();

      // Convert bytes to Base64 string
      final base64String = base64Encode(bytes);

      // Print or use the Base64 string as needed
      print('Base64 String: $base64String');

      context.read<AuthBloc>().add(
            UpdateUserInfo(
              id: userId,
              profileImage: base64String,
            ),
          );
      //print('file: $file');
      //print('bytes: $bytes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Profile',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 100.0,
                        height: 100.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: widget.userModel.profileImage != null
                                ? MemoryImage(base64Decode(
                                    widget.userModel.profileImage!))
                                : const AssetImage(ImagePath.profile)
                                    as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 30.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            capitalizeWord(widget.userModel.name),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            readableEnumConverter(widget.userModel.role),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 14.0,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  /// Actions
                  Column(
                    children: [
                      _outlineButton(
                        context: context,
                        onTap: () => _uploadImage(widget.userModel.id),
                        text: 'Upload',
                        icon: FluentIcons.arrow_upload_16_filled,
                        color: AppColor.accent,
                      ),
                      // const SizedBox(
                      //   height: 10.0,
                      // ),
                      // _outlineButton(
                      //   context: context,
                      //   onTap: () {},
                      //   text: 'Edit',
                      //   icon: FluentIcons.edit_16_regular,
                      // ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _outlineButton({
    required BuildContext context,
    required void Function()? onTap,
    required String text,
    Color? color,
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.0),
      hoverColor: Theme.of(context).dividerColor.withOpacity(0.9),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 4.0,
        ),
        width: 120.0,
        height: 40.0,
        decoration: BoxDecoration(
          border: Border.all(
            color: color ?? Theme.of(context).dividerColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (icon != null)
              Icon(
                icon,
                color: color ?? AppColor.icon,
                size: 20.0,
              ),
            Text(
              text,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountSecurity extends StatefulWidget {
  const _AccountSecurity({
    super.key,
    required this.userModel,
  });

  final SupplyDepartmentEmployeeModel userModel;

  @override
  State<_AccountSecurity> createState() => _AccountSecurityState();
}

class _AccountSecurityState extends State<_AccountSecurity> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final ValueNotifier<bool> _isExpanded = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    _emailController.text = widget.userModel.email;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Account Security',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(
          height: 50.0,
          child: Divider(
            color: Theme.of(context).dividerColor,
            thickness: 1.5,
          ),
        ),
        Expanded(
          child: Column(
            children: [

              Row(
                children: [

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          'This is bound into your account.',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: CustomLabeledTextBox(
                      label: 'Email',
                      controller: _emailController,
                      enabled: false,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 30.0,
              ),

              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _isExpanded,
                  builder: (context, isExpanded, child) {
                    return SingleChildScrollView(
                      child: ExpansionTile(
                        onExpansionChanged: (bool expanded) =>
                            _isExpanded.value = expanded,
                        tilePadding: EdgeInsets.zero,
                        childrenPadding:
                            const EdgeInsets.symmetric(vertical: 5.0),
                        title: Text(
                          'Password Update',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        trailing: Icon(
                          isExpanded
                              ? HugeIcons.strokeRoundedArrowUp01
                              : HugeIcons.strokeRoundedArrowDown01,
                          size: 20.0,
                        ),
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Create a new password.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.w400,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomLabeledTextBox(
                                      label: 'New Password',
                                      controller: _passwordController,
                                    ),
                                    const SizedBox(
                                      height: 20.0,
                                    ),
                                    CustomLabeledTextBox(
                                      label: 'Confirm New Password',
                                      controller: _confirmPasswordController,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          _buildActions(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomOutlineButton(
          onTap: () {
            _passwordController.clear();
            _confirmPasswordController.clear();
          },
          text: 'Cancel',
          height: 40.0,
        ),
        const SizedBox(
          width: 10.0,
        ),
        CustomOutlineButton(
          onTap: () => context.read<AuthBloc>().add(
            UpdateUserInfo(
              id: widget.userModel.id,
              password: _passwordController.text,
            ),
          ),
          text: 'Save Changes',
          height: 40.0,
        ),
      ],
    );
  }
}
