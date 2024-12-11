import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/purchase_request_status.dart';
import '../../../../core/enums/unit.dart';
import '../../domain/entities/feedback.dart';
import '../../domain/entities/feedbacks.dart';
import '../../domain/entities/purchase_request.dart';
import '../../domain/entities/purchase_request_with_notification_trail.dart';
import '../../domain/usecases/get_paginated_purchase_requests.dart';
import '../../domain/usecases/get_purchase_request_by_id.dart';
import '../../domain/usecases/register_purchase_request.dart';
import '../../domain/usecases/update_purchase_request_status.dart';

part 'purchase_requests_event.dart';
part 'purchase_requests_state.dart';

class PurchaseRequestsBloc
    extends Bloc<PurchaseRequestsEvent, PurchaseRequestsState> {
  PurchaseRequestsBloc({
    required GetPaginatedPurchaseRequests getPaginatedPurchaseRequests,
    required RegisterPurchaseRequest registerPurchaseRequest,
    required UpdatePurchaseRequestStatus updatePurchaseRequestStatus,
    required GetPurchaseRequestById getPurchaseRequestById,
  })  : _getPaginatedPurchaseRequests = getPaginatedPurchaseRequests,
        _registerPurchaseRequest = registerPurchaseRequest,
        _updatePurchaseRequestStatus = updatePurchaseRequestStatus,
        _getPurchaseRequestById = getPurchaseRequestById,
      super(PurchaseRequestsInitial()) {
    on<GetPurchaseRequestsEvent>(_onGetPurchaseRequests);
    on<RegisterPurchaseRequestEvent>(_onRegisterPurchaseRequest);
    on<UpdatePurchaseRequestEvent>(_onUpdatePurchaseRequestEvent);
    on<GetPurchaseRequestByIdEvent>(_onGetPurchaseRequestById);
  }

  final GetPaginatedPurchaseRequests _getPaginatedPurchaseRequests;
  final RegisterPurchaseRequest _registerPurchaseRequest;
  final UpdatePurchaseRequestStatus _updatePurchaseRequestStatus;
  final GetPurchaseRequestById _getPurchaseRequestById;

  void _onGetPurchaseRequests(
    GetPurchaseRequestsEvent event,
    Emitter<PurchaseRequestsState> emit,
  ) async {
    emit(PurchaseRequestsLoading());

    final response = await _getPaginatedPurchaseRequests(
      GetPaginatedPurchaseRequestsParams(
        page: event.page,
        pageSize: event.pageSize,
        prId: event.prId,
        unitCost: event.unitCost,
        date: event.date,
        prStatus: event.prStatus,
        isArchived: event.isArchived,
      ),
    );

    response.fold(
      (l) => emit(
        PurchaseRequestsError(
          message: l.message,
        ),
      ),
      (r) => emit(
        PurchaseRequestsLoaded(
          totalPurchaseRequestsCount: r.totalItemsCount,
          pendingRequestsCount: r.pendingRequestCount,
          incompleteRequestCount: r.incompleteRequestCount,
          completeRequestsCount: r.completeRequestCount,
          cancelledRequestsCount: r.cancelledRequestCount,
          feedbacks: r.feedbacks,
          purchaseRequests: r.purchaseRequests,
        ),
      ),
    );
  }

  void _onRegisterPurchaseRequest(
    RegisterPurchaseRequestEvent event,
    Emitter<PurchaseRequestsState> emit,
  ) async {
    emit(PurchaseRequestsLoading());

    final response = await _registerPurchaseRequest(
      RegisterPurchaseRequestParams(
        entityName: event.entityName,
        fundCluster: event.fundCluster,
        officeName: event.officeName,
        date: event.date,
        productName: event.productName,
        productDescription: event.productDescription,
        unit: event.unit,
        quantity: event.quantity,
        unitCost: event.unitCost,
        purpose: event.purpose,
        requestingOfficerOffice: event.requestingOfficerOffice,
        requestingOfficerPosition: event.requestingOfficerPosition,
        requestingOfficerName: event.requestingOfficerName,
        approvingOfficerOffice: event.approvingOfficerOffice,
        approvingOfficerPosition: event.approvingOfficerPosition,
        approvingOfficerName: event.approvingOfficerName,
      ),
    );

    response.fold(
      (l) => emit(
        PurchaseRequestsError(
          message: l.message,
        ),
      ),
      (r) {
        emit(
          PurchaseRequestRegistered(
            purchaseRequest: r,
          ),
        );
      },
    );
  }

  void _onUpdatePurchaseRequestEvent(
    UpdatePurchaseRequestEvent event,
    Emitter<PurchaseRequestsState> emit,
  ) async {
    emit(PurchaseRequestsLoading());

    final response = await _updatePurchaseRequestStatus(
      UpdatePurchaseRequestsStatusParams(
        id: event.id,
        status: event.status,
      ),
    );

    response.fold(
      (l) => emit(PurchaseRequestsError(message: l.message)),
      (r) => emit(
        PurchaseRequestStatusUpdated(isSuccessful: r),
      ),
    );
  }

  void _onGetPurchaseRequestById(
      GetPurchaseRequestByIdEvent event,
      Emitter<PurchaseRequestsState> emit,
      ) async {
    emit(PurchaseRequestsLoading());

    final response = await _getPurchaseRequestById(event.prId);

    response.fold(
          (l) => emit(
        PurchaseRequestsError(
          message: l.message,
        ),
      ),
          (r) {
        emit(
          PurchaseRequestLoaded(
            purchaseRequestWithNotificationTrailEntity: r,
          ),
        );
      },
    );
  }
}
