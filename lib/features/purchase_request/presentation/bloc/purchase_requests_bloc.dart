import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/purchase_request_status.dart';
import '../../../../core/enums/unit.dart';
import '../../domain/entities/purchase_request.dart';
import '../../domain/usecases/get_paginated_purchase_requests.dart';
import '../../domain/usecases/register_purchase_request.dart';

part 'purchase_requests_event.dart';
part 'purchase_requests_state.dart';

class PurchaseRequestsBloc
    extends Bloc<PurchaseRequestsEvent, PurchaseRequestsState> {
  PurchaseRequestsBloc({
    required GetPaginatedPurchaseRequests getPaginatedPurchaseRequests,
    required RegisterPurchaseRequest registerPurchaseRequest,
  })  : _getPaginatedPurchaseRequests = getPaginatedPurchaseRequests,
        _registerPurchaseRequest = registerPurchaseRequest,
        super(PurchaseRequestsInitial()) {
    on<GetPurchaseRequestsEvent>(_onGetPurchaseRequests);
    on<RegisterPurchaseRequestEvent>(_onRegisterPurchaseRequest);
  }

  final GetPaginatedPurchaseRequests _getPaginatedPurchaseRequests;
  final RegisterPurchaseRequest _registerPurchaseRequest;

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
          purchaseRequests: r.purchaseRequests,
          totalPurchaseRequestsCount: r.totalItemsCount,
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
        responsibilityCenterCode: event.responsibilityCenterCode,
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
}
