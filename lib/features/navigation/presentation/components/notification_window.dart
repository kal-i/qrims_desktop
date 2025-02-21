import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/custom_message_box.dart';
import '../../../../core/common/components/pagination_controls_2.dart';
import '../../data/data/models/notification.dart';
import '../bloc/notifications_bloc.dart';
import 'notification_card.dart';

class NotificationWindow extends StatefulWidget {
  const NotificationWindow({
    super.key,
  });

  @override
  State<NotificationWindow> createState() => _NotificationWindowState();
}

class _NotificationWindowState extends State<NotificationWindow> {
  late NotificationsBloc _notificationsBloc;

  final List<NotificationModel> _notifications = [];

  int _currentPage = 1;
  int _pageSize = 5;
  int _totalRecords = 0;

  @override
  void initState() {
    super.initState();
    _notificationsBloc = context.read<NotificationsBloc>();
    _fetchNotifications();
  }

  void _fetchNotifications() {
    _notificationsBloc.add(
      GetNotificationsEvent(
        page: _currentPage,
        pageSize: _pageSize,
      ),
    );
  }

  void _refreshNotificationList() {
    _currentPage = 1;
    _fetchNotifications();
  }

  void _markNotificationAsRead(
    NotificationModel notification,
  ) {
    if (!notification.read) {
      _notificationsBloc.add(ReadNotificationEvent(
        notificationId: notification.id,
        read: true,
      ));
    }
  }

  void _readNotification(
    NotificationModel notification,
  ) {
    _markNotificationAsRead(notification);

    // final issuancePattern = RegExp(r'ISS-\d{4}-\d{2}-\d+');
    // final purchaseRequestPattern = RegExp(r'\d{4}-\d{2}-\d+');
    //
    // final issuanceMatch = issuancePattern.firstMatch(notification.message);
    // if (issuanceMatch != null) {
    //   final trackingId = issuanceMatch.group(0);
    //   if (trackingId != null) {
    //     context.go(
    //       RoutingConstants.nestedNotificationIssuanceViewRoutePath,
    //       extra: {
    //         'issuance_id': trackingId,
    //       },
    //     );
    //     return;
    //   }
    // }
    //
    // final purchaseRequestMatch =
    // purchaseRequestPattern.firstMatch(notification.message);
    // if (purchaseRequestMatch != null) {
    //   final trackingId = purchaseRequestMatch.group(0);
    //   if (trackingId != null) {
    //     context.go(
    //         RoutingConstants.nestedNotificationPurchaseRequestViewRoutePath,
    //         extra: {
    //           'pr_id': trackingId,
    //           'init_location': RoutingConstants.notificationViewRoutePath,
    //         });
    //     return;
    //   }
    // }
  }

  void _toggleNotificationRead(
    NotificationModel notification,
  ) {
    final newReadStatus = !notification.read;

    _notificationsBloc.add(
      ReadNotificationEvent(
        notificationId: notification.id,
        read: newReadStatus,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildNotificationViewSection();
  }

  Widget _buildNotificationViewSection() {
    return BlocListener<NotificationsBloc, NotificationsState>(
      listener: (context, state) {
        if (state is NotificationsLoaded) {
          _totalRecords = state.totalNotificationsCount;
          _notifications.clear();
          _notifications.addAll(
            state.notifications
                .map((notif) => notif as NotificationModel)
                .toList(),
          );
        }

        if (state is NotificationRead && state.isSuccessful) {
          _fetchNotifications();
        }
      },
      child: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15.0,
            vertical: 20.0,
          ),
          child: Column(
            children: [
              _buildNotificationHeader(),
              const SizedBox(
                height: 30.0,
              ),
              if (state is NotificationsLoading)
                const SpinKitFadingCircle(
                  color: AppColor.accent,
                  size: 10.0,
                ),
              if (state is NotificationsError)
                CustomMessageBox.error(
                  message: state.message,
                ),
              Expanded(
                child: _buildNotificationList(),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildNotificationHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            PaginationControls2(
              currentPage: _currentPage,
              totalRecords: _totalRecords,
              pageSize: _pageSize,
              onPageChanged: (page) {
                _currentPage = page;
                _fetchNotifications();
              },
              onPageSizeChanged: (size) {
                _pageSize = size;
                _fetchNotifications();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationList() {
    return RefreshIndicator(
      color: AppColor.accent,
      onRefresh: () async => _refreshNotificationList(),
      child: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) => NotificationCard(
          notification: _notifications[index],
          onNotificationTap: (notification) => _readNotification(notification),
          onMarkAsRead: (notification) => _toggleNotificationRead(notification),
        ),
      ),
    );
  }
}
