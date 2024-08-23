import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/entities/supply_department_employee.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class AccountProfile extends StatelessWidget {
  const AccountProfile({
    super.key,
    required this.imagePath,
  });

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      String name = 'Unknown';
      String email = 'Unknown';

      if (state is AuthSuccess) {
        final userData = state.data;

        if (userData is SupplyDepartmentEmployeeEntity) {
          name = capitalizeWord(userData.name);
          email = userData.email;
        }
      }

      return PopupMenuButton(
        color: Theme.of(context).scaffoldBackgroundColor,
        elevation: 5,
        position: PopupMenuPosition.under,
        tooltip: 'Manage Account',
        onSelected: (value) async {
          if (value == 'Logout') {
            print(value);
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('authToken');
            print(token);
            context.read<AuthBloc>().add(
                  AuthLogout(
                    token: token!,
                  ),
                );
            print(token);
          } else if (value == 'Profile') {
            print('profile');
          }
        },
        itemBuilder: (context) => <PopupMenuEntry<String>>[
          _customPopupMenuItem(
            context: context,
            value: name,
            leading: Container(
              width: 35.0,
              height: 35.0,
              decoration: BoxDecoration(
                border: Border.all(width: 2),
                image: DecorationImage(image: AssetImage(imagePath)),
                shape: BoxShape.circle,
              ),
            ),
            title: name,
            subTitle: email,
          ),
          const PopupMenuDivider(),
          _customPopupMenuItem(
            context: context,
            value: 'View Profile',
            leading: const Icon(
              Icons.manage_accounts_outlined,
              size: 20.0,
            ),
            title: 'View Profile',
          ),
          _customPopupMenuItem(
            context: context,
            value: 'Account Settings',
            leading: const Icon(
              Icons.settings_outlined,
              size: 20.0,
            ),
            title: 'Account Settings',
          ),
          _customPopupMenuItem(
            context: context,
            value: 'Logout',
            leading: const Icon(
              Icons.logout_outlined,
              size: 20.0,
            ),
            title: 'Logout',
          ),
        ],
        child: Container(
          width: 35.0,
          height: 35.0,
          decoration: BoxDecoration(
            border: Border.all(width: 2),
            image: DecorationImage(image: AssetImage(imagePath)),
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }
}

/// Helper method to create a custom list tile, avoiding redundancy in styling
PopupMenuItem<String> _customPopupMenuItem({
  required BuildContext context,
  required String value,
  Widget? leading,
  required String title,
  String? subTitle,
}) {
  return PopupMenuItem<String>(
    padding: const EdgeInsets.only(
      left: 20.0,
      right: 20.0,
    ),
    value: value,
    child: ListTile(
      leading: leading,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: subTitle != null
          ? Text(
              subTitle,
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
      //titleTextStyle: Theme.of(context).textTheme.bodySmall,
    ),
  );
}
