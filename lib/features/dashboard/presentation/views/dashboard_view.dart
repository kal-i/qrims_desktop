import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/components/base_container.dart';
import '../../../../core/common/components/loader.dart';
import '../../domain/entities/user_activity.dart';
import '../bloc/user_activity/user_activity_bloc.dart';
import '../components/activity_log_card.dart';
import '../../../../core/common/components/kpi_card.dart';
import '../components/limited_item_card.dart';

// TODO: extract later
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// left
        Expanded(
          flex: 5,
          child: Column(
            children: [
              /// KPI Overview
              const Row(
                children: [
                  Expanded(
                    child: KPICard(
                      icon: Icons.inventory_2_outlined,
                      title: 'Inventory Items',
                      data: '50',
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: KPICard(
                      icon: Icons.notes_outlined,
                      title: 'Purchase Requests',
                      data: '5',
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: KPICard(
                      icon: Icons.inventory_2_outlined,
                      title: 'Low-stock Items',
                      data: '3',
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 10.0,
              ),

              /// Inventory Overview
              Expanded(
                child: BaseContainer(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Inventory Overview',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 10.0,
              ),

              /// In-demand Items Overview
              Expanded(
                child: BaseContainer(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'In-demand Overview',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          width: 10.0,
        ),

        /// right
        Expanded(
          flex: 2,
          child: Column(
            children: [
              /// Activity Overview
              Expanded(
                child: BaseContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Recent Activity Logs',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const Divider(),
                      Expanded(
                        child: BlocBuilder<UserActivityBloc, UserActivityState>(
                            builder: (context, state) {
                          if (state is UserActivityLoading &&
                              state.isFirstFetch) {
                            return const Loader();
                          }

                          final activities = state is UserActivityLoaded
                              ? state.userActivities
                              : <UserActivityEntity>[];

                          return NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification scrollInfo) {
                              // if reached the scroll end and state is not loading, invoke fetch next page
                              if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && state is! UserActivityLoading) {
                                context.read<UserActivityBloc>().fetchNextPage(1); // todo: replace later using auth bloc builder to get user info
                              }
                              return false;
                            },
                            child: ListView.builder(
                              itemCount: activities.length + (state is UserActivityLoading ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index < activities.length) {
                                  final activity = activities[index];
                                  return ActivityLogCard(userActivityEntity: activity);
                                } else {
                                  return const Loader();
                                }
                              },
                            ),
                          );
                          // return ListView(
                          //   // physics: const NeverScrollableScrollPhysics(), // this will disable the scrollable if fixed height
                          //   shrinkWrap: true,
                          //   children: const [
                          //     ActivityLogCard(),
                          //     ActivityLogCard(),
                          //     ActivityLogCard(),
                          //     ActivityLogCard(),
                          //     ActivityLogCard(),
                          //   ],
                          // );
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 10.0,
              ),

              /// Limited Items Overview
              Expanded(
                child: BaseContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Running Out of Stocks',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const Divider(),
                      Expanded(
                        child: ListView(
                          // physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: const [
                            LimitedItemCard(),
                            LimitedItemCard(),
                            LimitedItemCard(),
                            LimitedItemCard(),
                            LimitedItemCard(),
                            LimitedItemCard(),
                            LimitedItemCard(),
                            LimitedItemCard(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
