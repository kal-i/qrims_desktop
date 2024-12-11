import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/app_routing_constants.dart';
import '../../../../../config/sizing/sizing_config.dart';
import '../../../../core/common/components/custom_message_box.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../../../navigation/domain/domain/entities/notification.dart';
import '../../../officer/data/models/officer.dart';
import '../../data/models/purchase_request.dart';
import '../bloc/purchase_requests_bloc.dart';
import '../components/request_time_line_tile.dart';

class ViewPurchaseRequest extends StatefulWidget {
  const ViewPurchaseRequest({
    super.key,
    required this.prId,
  });

  final String prId;

  @override
  State<ViewPurchaseRequest> createState() => _ViewPurchaseRequestState();
}

class _ViewPurchaseRequestState extends State<ViewPurchaseRequest> {
  late PurchaseRequestsBloc _purchaseRequestsBloc;

  @override
  void initState() {
    super.initState();
    _purchaseRequestsBloc = context.read<PurchaseRequestsBloc>();
    _fetchPurchaseRequest();
  }

  void _fetchPurchaseRequest() {
    _purchaseRequestsBloc.add(
      GetPurchaseRequestByIdEvent(
        prId: widget.prId,
      ),
    );
  }

  void _onTrackingIdTapped(BuildContext context, String trackingId) {
    print('tracking id: $trackingId');
    final Map<String, dynamic> extra = {
      'issuance_id': trackingId.toString().split(' ').last,
    };

    // if (widget.initLocation ==
    //     RoutingConstants.nestedHomePurchaseRequestViewRoutePath) {
    //   context.go(RoutingConstants.nestedHomeIssuanceViewRoutePath,
    //       extra: extra);
    // }
    //
    // if (widget.initLocation ==
    //     RoutingConstants.nestedHistoryPurchaseRequestViewRoutePath) {
    //   context.go(RoutingConstants.nestedHistoryIssuanceViewRoutePath,
    //       extra: extra);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 30.0,
                  ),
                  child:
                      BlocBuilder<PurchaseRequestsBloc, PurchaseRequestsState>(
                          builder: (context, state) {
                    return _buildMainView(
                      state,
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            _buildBackButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainView(PurchaseRequestsState state) {
    if (state is PurchaseRequestsLoading) {
      return _buildLoadingStateView();
    }

    if (state is PurchaseRequestsError) {
      return CustomMessageBox.error(
        message: state.message,
      );
    }

    if (state is PurchaseRequestLoaded) {
      return _buildRequestDetails(
        state,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildRequestDetails(PurchaseRequestLoaded state) {
    final purchaseRequest =
        state.purchaseRequestWithNotificationTrailEntity.purchaseRequestEntity;
    final requestingOfficer = purchaseRequest.requestingOfficerEntity;
    final approvingOfficer = purchaseRequest.approvingOfficerEntity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTitle(),
        const SizedBox(
          height: 10.0,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildPurchaseRequestInfo(
                    purchaseRequest as PurchaseRequestModel,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  _buildRequestedItemSection(
                    purchaseRequest,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  _buildPurposeSection(
                    purchaseRequest.purpose,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  _buildOfficerSection(
                    'Requesting Officer',
                    requestingOfficer as OfficerModel,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  _buildOfficerSection(
                    'Approving Officer',
                    approvingOfficer as OfficerModel,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 800.0,
                child: _buildTimeline(
                  state.purchaseRequestWithNotificationTrailEntity
                      .notificationEntities,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      'Purchase Request',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
          ),
    );
  }

  Widget _buildPurchaseRequestInfo(PurchaseRequestModel purchaseRequest) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoText(
          'PR No. ${purchaseRequest.id}',
        ),
        _buildInfoText(purchaseRequest.entity.name),
        _buildInfoText(
          readableEnumConverter(
            purchaseRequest.fundCluster,
          ),
        ),
        _buildInfoText(
          capitalizeWord(
            purchaseRequest.officeEntity.officeName,
          ),
        ),
        if (purchaseRequest.responsibilityCenterCode != null)
          _buildInfoText(
            purchaseRequest.responsibilityCenterCode!,
          ),
        _buildInfoText(
          dateFormatter(
            purchaseRequest.date,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10.0,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
            ),
      ),
    );
  }

  Widget _buildRequestedItemSection(PurchaseRequestModel purchaseRequest) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTitleSection(
          'Item Details',
        ),
        _buildInfoText(
          capitalizeWord(
            purchaseRequest.productNameEntity.name,
          ),
        ),
        _buildInfoText(
            purchaseRequest.productDescriptionEntity.description ?? ''),
        _buildInfoText(
          readableEnumConverter(
            purchaseRequest.unit,
          ),
        ),
        _buildInfoText(
          'QTY: ${purchaseRequest.quantity}',
        ),
        _buildInfoText(
          'UNIT COST: ${purchaseRequest.unitCost}',
        ),
        _buildInfoText(
          'TOTAL: ${purchaseRequest.totalCost}',
        ),
      ],
    );
  }

  Widget _buildTitleSection(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildPurposeSection(String purpose) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTitleSection(
          'Purpose:',
        ),
        _buildInfoText(
          purpose,
        ),
      ],
    );
  }

  Widget _buildOfficerSection(String title, OfficerModel officer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTitleSection(
          title,
        ),
        _buildInfoText(
          capitalizeWord(
            officer.name,
          ),
        ),
        _buildInfoText(
          capitalizeWord(
            '${officer.officeName} - ${officer.positionName}',
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(List<NotificationEntity> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTitleSection('Request Timeline:'),
        Expanded(
          child: ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final isFirst = index == 0 ? true : false;
              final isLast = index == notifications.length - 1 ? true : false;

              return RequestTimeLineTile(
                isFirst: isFirst,
                isLast: isLast,
                isPast: true,
                title: readableEnumConverter(notification.type),
                message: notification.message,
                date: notification.createdAt!,
                onTrackingIdTapped: (trackingId) =>
                    _onTrackingIdTapped(context, trackingId),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingStateView() {
    return Center(
      child: Column(
        children: [
          //const CustomCircularLoader(),
          Text(
            'Fetching purchase request...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomOutlineButton(
          onTap: () => context.pop(),
          text: 'Back',
          width: 180.0,
          height: 40.0,
        ),
      ],
    );
  }
}
