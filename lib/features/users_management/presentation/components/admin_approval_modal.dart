import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/common/components/pagination_controls.dart';
import '../../../../core/enums/admin_approval_status.dart';
import '../../../../core/models/mobile_user.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/utils/time_ago_formatter.dart';
import '../bloc/users_management_bloc.dart';
import '../../../../core/common/components/base_modal.dart';

class AdminApprovalModal extends StatefulWidget {
  const AdminApprovalModal({super.key});

  @override
  State<AdminApprovalModal> createState() => _AdminApprovalModalState();
}

/// todo: add a loading indicator and maybe a msg feedback
class _AdminApprovalModalState extends State<AdminApprovalModal> {
  late UsersManagementBloc _usersManagementBloc;

  final List<MobileUserModel> _pendingUsers = [];
  final ValueNotifier<int> _totalRecords = ValueNotifier(0);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  int _currentPage = 1;
  int _pageSize = 2;

  @override
  void initState() {
    super.initState();
    _usersManagementBloc = context.read<UsersManagementBloc>();
    _fetchUsers();
  }

  void _fetchUsers() {
    _usersManagementBloc.add(
      FetchPendingUsersEvent(
        page: _currentPage,
        pageSize: _pageSize,
      ),
    );
  }

  void _updateAdminApprovalStatus({
    required String id,
    required AdminApprovalStatus status,
  }) {
    _usersManagementBloc.add(
      UpdateAdminApprovalStatusEvent(
        userId: id,
        adminApprovalStatus: status,
      ),
    );
  }

  @override
  void dispose() {
    //_pendingUsers.dispose();
    _totalRecords.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      width: 650.0,
      height: 700.0,
      headerTitle: 'Pending Request',
      subtitle: 'Accept to grant access, or reject to delete.',
      content: _buildContent(),
    );
  }

  Widget _buildContent() {
    return BlocListener<UsersManagementBloc, UsersManagementState>(
      listener: (context, state) {
        if (state is PendingUsersLoading) {
          _isLoading.value = true;
        }

        if (state is PendingUsersLoaded) {
          _isLoading.value = false;
          _totalRecords.value = state.totalUserCount;
          _pendingUsers.clear();
          _pendingUsers.addAll(state.users
              .map((user) => MobileUserModel.fromEntity(user))
              .toList());
        }

        if (state is AdminApprovalStatusUpdated && state.isSuccessful) {
          _isLoading.value = false;
          _fetchUsers();
        }
      },
      child: BlocBuilder<UsersManagementBloc, UsersManagementState>(
          builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async => _fetchUsers(),
          child: Column(
            children: [
              _pendingUsers.isEmpty
                  ? Expanded(
                      child: _buildEmptyState(),
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: 500.0,
                          child: ListView.builder(
                            itemCount: _pendingUsers.length,
                            itemBuilder: (context, index) {
                              final user = _pendingUsers[index];

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
                                      flex: 5,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
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
                                                onTap: () =>
                                                    _updateAdminApprovalStatus(
                                                  id: user.id,
                                                  status: AdminApprovalStatus
                                                      .accepted,
                                                ),
                                                text: 'Accept',
                                                height: 40.0,
                                              )),
                                              const SizedBox(
                                                width: 10.0,
                                              ),
                                              Expanded(
                                                  child: CustomOutlineButton(
                                                onTap: () =>
                                                    _updateAdminApprovalStatus(
                                                  id: user.id,
                                                  status: AdminApprovalStatus
                                                      .rejected,
                                                ),
                                                text: 'Delete',
                                                height: 40.0,
                                              )),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20.0,
                                    ),
                                    Text(
                                      timeAgo(user.createdAt),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w400,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        PaginationControls(
                          currentPage: _currentPage,
                          totalRecords: _totalRecords.value,
                          pageSize: _pageSize,
                          onPageChanged: (page) {
                            _currentPage = page;
                            _fetchUsers();
                          },
                          onPageSizeChanged: (size) {
                            _pageSize = size;
                            _fetchUsers();
                          },
                        ),
                      ],
                    ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            HugeIcons.strokeRoundedUserAdd01,
            size: 34,
            color: AppColor.lightYellowOutline,
          ),
          SizedBox(height: 20),
          Text(
            'No pending requests.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColor.lightYellowOutline,
            ),
          ),
        ],
      ),
    );
  }
}

// we opted for delete because we've added a Unique constraint for the email field in the db
// if an account tried to reg and they were rejected, then they won't be able to use that email again
// that is why it is necessary to delete them
