import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/entities/mobile_user.dart';
import '../../../../core/enums/admin_approval_status.dart';
import '../../../../core/models/mobile_user.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/utils/time_ago_formatter.dart';
import '../bloc/users_management_bloc.dart';
import 'base_modal.dart';

class AdminApprovalModal extends StatefulWidget {
  const AdminApprovalModal({super.key});

  @override
  State<AdminApprovalModal> createState() => _AdminApprovalModalState();
}

class _AdminApprovalModalState extends State<AdminApprovalModal> {
  late UsersManagementBloc _usersManagementBloc;

  final ValueNotifier<List<MobileUserModel>> _pendingUsers =
      ValueNotifier(<MobileUserModel>[]);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  final String _selectedSortValue = 'Account Creation';
  final String _selectedSortOrder = 'Descending';
  AdminApprovalStatus adminApprovalStatus = AdminApprovalStatus.pending;

  int _currentPage = 1;
  int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _usersManagementBloc = context.read<UsersManagementBloc>();
    _fetchUsers();
  }

  void _fetchUsers() {
    _usersManagementBloc.add(
      FetchUsersEvent(
        page: _currentPage,
        pageSize: _pageSize,
        sortBy: _selectedSortValue,
        sortAscending: _selectedSortOrder == 'Ascending',
        adminApprovalStatus: adminApprovalStatus,
      ),
    );
  }

  void _updateAdminApprovalStatus(
      {required String id, required AdminApprovalStatus status}) {
    _usersManagementBloc.add(
      UpdateAdminApprovalStatusEvent(
        userId: id,
        adminApprovalStatus: status,
      ),
    );
  }

  @override
  void dispose() {
    _pendingUsers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      width: 500.0,
      height: 550.0,
      headerTitle: 'Pending Request',
      subtitle: '''Mobile-registered accounts pending approval. 
          Accept to grant access, or reject to delete.''',
      content: _buildContent(),
    );
  }

  Widget _buildContent() {
    return BlocListener<UsersManagementBloc, UsersManagementState>(
      listener: (context, state) {
        if (state is UsersLoading) {
          _isLoading.value = true;
        }

        if (state is UsersLoaded) {
          _isLoading.value = false;
          _pendingUsers.value.addAll(state.users
              .map((user) {
                if (user is MobileUserEntity) {
                  return MobileUserModel.fromEntity(user);
                }
                return null;
              })
              .whereType<MobileUserModel>()
              .toList());
        }

        if (state is AdminApprovalStatusUpdated && state.isSuccessful) {
          _fetchUsers();
        }
      },
      child: BlocBuilder<UsersManagementBloc, UsersManagementState>(
          builder: (context, state) {
        return ValueListenableBuilder(
            valueListenable: _pendingUsers,
            builder: (context, pendingUsers, child) {
              return ListView.builder(
                itemCount: pendingUsers.length,
                itemBuilder: (context, index) {
                  final user = pendingUsers[index];

                  return Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            width: 80.0,
                            height: 80.0,
                            decoration: const BoxDecoration(
                              color: AppColor.lightYellow,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              HugeIcons.strokeRoundedUser,
                              color: AppColor.lightYellowOutline,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20.0,
                        ),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                capitalizeWord(user.name),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                capitalizeWord(
                                    '${user.officerEntity.officeName} - ${user.officerEntity.positionName}'),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child: CustomFilledButton(
                                    onTap: () => _updateAdminApprovalStatus(
                                      id: user.id,
                                      status: AdminApprovalStatus.accepted,
                                    ),
                                    text: 'Accept',
                                    height: 40.0,
                                  )),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Expanded(
                                      child: CustomOutlineButton(
                                    onTap: () => _updateAdminApprovalStatus(
                                      id: user.id,
                                      status: AdminApprovalStatus.rejected,
                                    ),
                                    text: 'Delete',
                                    height: 40.0,
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        Text(
                          timeAgo(user.createdAt),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w400,
                                  ),
                        ),
                      ],
                    ),
                  );

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                    leading: Container(
                      padding: const EdgeInsets.all(10.0),
                      width: 50.0,
                      height: 50.0,
                      decoration: const BoxDecoration(
                        color: AppColor.lightYellow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        HugeIcons.strokeRoundedUser,
                        color: AppColor.lightYellowOutline,
                      ),
                    ),
                    title: Text(
                      capitalizeWord('full name'),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    subtitle: Text(
                      capitalizeWord('Supply - Supply Officer I'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    trailing: Text(
                      '2w',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                  );
                },
              );
            });
      }),
    );
  }
}

// we opted for delete because we've added a Unique constraint for the email field in the db
// if an account tried to reg and they were rejected, then they won't be able to use that email again
// that is why it is necessary to delete them