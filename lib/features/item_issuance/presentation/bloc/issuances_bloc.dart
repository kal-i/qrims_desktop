import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/ics_type.dart';
import '../../../../core/enums/issuance_item_status.dart';
import '../../domain/entities/inventory_custodian_slip.dart';
import '../../domain/entities/issuance.dart';
import '../../domain/entities/matched_item_with_pr.dart';
import '../../domain/entities/property_acknowledgement_receipt.dart';
import '../../domain/entities/requisition_and_issue_slip.dart';
import '../../domain/usecases/create_ics.dart';
import '../../domain/usecases/create_multiple_ics.dart';
import '../../domain/usecases/create_mutiple_par.dart';
import '../../domain/usecases/create_par.dart';
import '../../domain/usecases/create_ris.dart';
import '../../domain/usecases/generate_semi_expendable_property_card_data.dart';
import '../../domain/usecases/get_accountable_officer_id.dart';
import '../../domain/usecases/get_inventory_property_report.dart';
import '../../domain/usecases/get_inventory_semi_expendable_report.dart';
import '../../domain/usecases/get_inventory_supply_report.dart';
import '../../domain/usecases/get_issuance_by_id.dart';
import '../../domain/usecases/get_officer_accountability.dart';
import '../../domain/usecases/get_paginated_issuances.dart';
import '../../domain/usecases/match_item_with_pr.dart';
import '../../domain/usecases/receive_issuance.dart';
import '../../domain/usecases/resolve_issuance_item.dart';
import '../../domain/usecases/update_issuance_archive_status.dart';

part 'issuance_events.dart';
part 'issuance_states.dart';

class IssuancesBloc extends Bloc<IssuancesEvent, IssuancesState> {
  IssuancesBloc({
    required GetIssuanceById getIssuanceById,
    required GetPaginatedIssuances getPaginatedIssuances,
    required MatchItemWithPr matchItemWithPr,
    required CreateICS createICS,
    required CreateMultipleICS createMultipleICS,
    required CreatePAR createPAR,
    required CreateMultiplePAR createMultiplePAR,
    required CreateRIS createRIS,
    required UpdateIssuanceArchiveStatus updateIssuanceArchiveStatus,
    required GetInventorySupplyReport getInventorySupplies,
    required GetInventorySemiExpendablePropertyReport
        getInventorySemiExpendablePropertyReport,
    required GetInventoryPropertyReport getInventoryPropertyReport,
    required GenerateSemiExpendablePropertyCardData
        generateSemiExpendablePropertyCardData,
    required ReceiveIssuance receiveIssuance,
    required GetAccountableOfficerId getAccountableOfficerId,
    required GetOfficerAccountability getOfficerAccountability,
    required ResolveIssuanceItem resolveIssuanceItem,
  })  : _getIssuanceById = getIssuanceById,
        _getPaginatedIssuances = getPaginatedIssuances,
        _matchItemWithPr = matchItemWithPr,
        _createICS = createICS,
        _createMultipleICS = createMultipleICS,
        _createPar = createPAR,
        _createMultiplePAR = createMultiplePAR,
        _createRIS = createRIS,
        _updateIssuanceArchiveStatus = updateIssuanceArchiveStatus,
        _getInventorySupplies = getInventorySupplies,
        _getInventorySemiExpendablePropertyReport =
            getInventorySemiExpendablePropertyReport,
        _getInventoryPropertyReport = getInventoryPropertyReport,
        _generateSemiExpendablePropertyCardData =
            generateSemiExpendablePropertyCardData,
        _receiveIssuance = receiveIssuance,
        _getAccountableOfficerId = getAccountableOfficerId,
        _getOfficerAccountability = getOfficerAccountability,
        _resolveIssuanceItem = resolveIssuanceItem,
        super(IssuancesInitial()) {
    on<GetIssuanceByIdEvent>(_onGetIssuanceByIdEvent);
    on<GetPaginatedIssuancesEvent>(_onGetPaginatedIssuancesEvent);
    on<MatchItemWithPrEvent>(_onMatchItemWithPrEvent);
    on<CreateICSEvent>(_onCreateICS);
    on<CreateMultipleICSEvent>(_onCreateMultipleICS);
    on<CreatePAREvent>(_onCreatePAR);
    on<CreateMultiplePAREvent>(_onCreateMultiplePAR);
    on<CreateRISEvent>(_onCreateRIS);
    on<UpdateIssuanceArchiveStatusEvent>(_onUpdateIssuanceArchiveStatus);
    on<GetInventorySupplyReportEvent>(_onGetInventorySupplyReport);
    on<GetInventorySemiExpendablePropertyReportEvent>(
        _onGetInventorySemiExpendablePropertyReport);
    on<GetInventoryPropertyReportEvent>(_onGetInventoryPropertyReport);
    on<GenerateSemiExpendablePropertyCardDataEvent>(
        _onGenerateSemiExpendablePropertyCardData);
    on<ReceiveIssuanceEvent>(_onReceiveIssuance);
    on<GetAccountableOfficerIdEvent>(_onGetAccountableOfficerId);
    on<GetOfficerAccountabilityEvent>(_onGetOfficerAccountability);
    on<ResolveIssuanceItemEvent>(_onResolveIssuanceItem);
  }

  final GetIssuanceById _getIssuanceById;
  final GetPaginatedIssuances _getPaginatedIssuances;
  final MatchItemWithPr _matchItemWithPr;
  final CreateICS _createICS;
  final CreateMultipleICS _createMultipleICS;
  final CreatePAR _createPar;
  final CreateMultiplePAR _createMultiplePAR;
  final CreateRIS _createRIS;
  final UpdateIssuanceArchiveStatus _updateIssuanceArchiveStatus;
  final GetInventorySupplyReport _getInventorySupplies;
  final GetInventorySemiExpendablePropertyReport
      _getInventorySemiExpendablePropertyReport;
  final GetInventoryPropertyReport _getInventoryPropertyReport;
  final GenerateSemiExpendablePropertyCardData
      _generateSemiExpendablePropertyCardData;
  final ReceiveIssuance _receiveIssuance;
  final GetAccountableOfficerId _getAccountableOfficerId;
  final GetOfficerAccountability _getOfficerAccountability;
  final ResolveIssuanceItem _resolveIssuanceItem;

  void _onGetIssuanceByIdEvent(
    GetIssuanceByIdEvent event,
    Emitter<IssuancesState> emit,
  ) async {
    emit(IssuancesLoading());

    final response = await _getIssuanceById(event.id);

    response.fold(
      (l) => emit(
        IssuancesError(message: l.message),
      ),
      (r) => emit(
        IssuanceLoaded(
          issuance: r!,
        ),
      ),
    );
  }

  void _onGetPaginatedIssuancesEvent(
    GetPaginatedIssuancesEvent event,
    Emitter<IssuancesState> emit,
  ) async {
    emit(IssuancesLoading());

    final response = await _getPaginatedIssuances(
      GetPaginatedIssuancesParams(
        page: event.page,
        pageSize: event.pageSize,
        searchQuery: event.searchQuery,
        issueDateStart: event.issueDateStart,
        issueDateEnd: event.issueDateEnd,
        type: event.type,
        isArchived: event.isArchived,
      ),
    );

    print('iss bloc: $response');

    response.fold(
      (l) => emit(
        IssuancesError(message: l.message),
      ),
      (r) => emit(
        IssuancesLoaded(
          issuances: r.issuances,
          totalIssuancesCount: r.totalIssuanceCount,
        ),
      ),
    );
  }

  void _onMatchItemWithPrEvent(
    MatchItemWithPrEvent event,
    Emitter<IssuancesState> emit,
  ) async {
    emit(IssuancesLoading());

    final response = await _matchItemWithPr(
      event.prId,
    );

    response.fold(
      (l) => emit(
        IssuancesError(message: l.message),
      ),
      (r) => emit(
        MatchedItemWithPr(
          matchedItemWithPrEntity: r,
        ),
      ),
    );
  }

  void _onCreateICS(
    CreateICSEvent event,
    Emitter<IssuancesState> emit,
  ) async {
    emit(IssuancesLoading());

    final response = await _createICS(
      CreateICSParams(
        issuedDate: event.issuedDate,
        type: event.type,
        issuanceItems: event.issuanceItems,
        prId: event.prId,
        entityName: event.entityName,
        fundCluster: event.fundCluster,
        supplierName: event.supplierName,
        deliveryReceiptId: event.deliveryReceiptId,
        prReferenceId: event.prReferenceId,
        inventoryTransferReportId: event.inventoryTransferReportId,
        inspectionAndAcceptanceReportId: event.inspectionAndAcceptanceReportId,
        contractNumber: event.contractNumber,
        purchaseOrderNumber: event.purchaseOrderNumber,
        dateAcquired: event.dateAcquired,
        receivingOfficerOffice: event.receivingOfficerOffice,
        receivingOfficerPosition: event.receivingOfficerPosition,
        receivingOfficerName: event.receivingOfficerName,
        issuingOfficerOffice: event.issuingOfficerOffice,
        issuingOfficerPosition: event.issuingOfficerPosition,
        issuingOfficerName: event.issuingOfficerName,
      ),
    );

    response.fold(
      (l) => emit(
        IssuancesError(message: l.message),
      ),
      (r) => emit(
        ICSRegistered(
          ics: r,
        ),
      ),
    );
  }

  void _onCreateMultipleICS(
    CreateMultipleICSEvent event,
    Emitter<IssuancesState> emit,
  ) async {
    emit(IssuancesLoading());

    final response = await _createMultipleICS(
      CreateMultipleICSParams(
        issuedDate: event.issuedDate,
        type: event.type,
        receivingOfficers: event.receivingOfficers,
        entityName: event.entityName,
        fundCluster: event.fundCluster,
        supplierName: event.supplierName,
        deliveryReceiptId: event.deliveryReceiptId,
        prReferenceId: event.prReferenceId,
        inventoryTransferReportId: event.inventoryTransferReportId,
        inspectionAndAcceptanceReportId: event.inspectionAndAcceptanceReportId,
        contractNumber: event.contractNumber,
        purchaseOrderNumber: event.purchaseOrderNumber,
        dateAcquired: event.dateAcquired,
        issuingOfficerOffice: event.issuingOfficerOffice,
        issuingOfficerPosition: event.issuingOfficerPosition,
        issuingOfficerName: event.issuingOfficerName,
      ),
    );

    response.fold(
      (l) => emit(
        IssuancesError(message: l.message),
      ),
      (r) => emit(
        MultipleICSRegistered(
          icsItems: r,
        ),
      ),
    );
  }

  void _onCreatePAR(
    CreatePAREvent event,
    Emitter<IssuancesState> emit,
  ) async {
    emit(IssuancesLoading());

    final response = await _createPar(
      CreatePARParams(
        issuedDate: event.issuedDate,
        issuanceItems: event.issuanceItems,
        prId: event.prId,
        entityName: event.entityName,
        fundCluster: event.fundCluster,
        supplierName: event.supplierName,
        deliveryReceiptId: event.deliveryReceiptId,
        prReferenceId: event.prReferenceId,
        inventoryTransferReportId: event.inventoryTransferReportId,
        inspectionAndAcceptanceReportId: event.inspectionAndAcceptanceReportId,
        contractNumber: event.contractNumber,
        purchaseOrderNumber: event.purchaseOrderNumber,
        dateAcquired: event.dateAcquired,
        receivingOfficerOffice: event.receivingOfficerOffice,
        receivingOfficerPosition: event.receivingOfficerPosition,
        receivingOfficerName: event.receivingOfficerName,
        issuingOfficerOffice: event.issuingOfficerOffice,
        issuingOfficerPosition: event.issuingOfficerPosition,
        issuingOfficerName: event.issuingOfficerName,
      ),
    );

    response.fold(
      (l) => emit(
        IssuancesError(message: l.message),
      ),
      (r) => emit(
        PARRegistered(
          par: r,
        ),
      ),
    );
  }

  void _onCreateMultiplePAR(
    CreateMultiplePAREvent event,
    Emitter<IssuancesState> emit,
  ) async {
    emit(IssuancesLoading());

    final response = await _createMultiplePAR(
      CreateMultiplePARParams(
        issuedDate: event.issuedDate,
        receivingOfficers: event.receivingOfficers,
        entityName: event.entityName,
        fundCluster: event.fundCluster,
        supplierName: event.supplierName,
        deliveryReceiptId: event.deliveryReceiptId,
        prReferenceId: event.prReferenceId,
        inventoryTransferReportId: event.inventoryTransferReportId,
        inspectionAndAcceptanceReportId: event.inspectionAndAcceptanceReportId,
        contractNumber: event.contractNumber,
        purchaseOrderNumber: event.purchaseOrderNumber,
        dateAcquired: event.dateAcquired,
        issuingOfficerOffice: event.issuingOfficerOffice,
        issuingOfficerPosition: event.issuingOfficerPosition,
        issuingOfficerName: event.issuingOfficerName,
      ),
    );

    response.fold(
      (l) => emit(
        IssuancesError(message: l.message),
      ),
      (r) => emit(
        MultiplePARRegistered(
          parItems: r,
        ),
      ),
    );
  }

  void _onCreateRIS(
    CreateRISEvent event,
    Emitter<IssuancesState> emit,
  ) async {
    emit(IssuancesLoading());

    print('on create ris event: ${event.issuingOfficerPosition}');

    final response = await _createRIS(
      CreateRISParams(
        issuedDate: event.issuedDate,
        issuanceItems: event.issuanceItems,
        prId: event.prId,
        entityName: event.entityName,
        fundCluster: event.fundCluster,
        division: event.division,
        responsibilityCenterCode: event.responsibilityCenterCode,
        officeName: event.officeName,
        purpose: event.purpose,
        receivingOfficerOffice: event.receivingOfficerOffice,
        receivingOfficerPosition: event.receivingOfficerPosition,
        receivingOfficerName: event.receivingOfficerName,
        issuingOfficerOffice: event.issuingOfficerOffice,
        issuingOfficerPosition: event.issuingOfficerPosition,
        issuingOfficerName: event.issuingOfficerName,
        approvingOfficerOffice: event.approvingOfficerOffice,
        approvingOfficerPosition: event.approvingOfficerPosition,
        approvingOfficerName: event.approvingOfficerName,
        requestingOfficerOffice: event.requestingOfficerOffice,
        requestingOfficerPosition: event.requestingOfficerPosition,
        requestingOfficerName: event.requestingOfficerName,
      ),
    );

    response.fold(
      (l) => emit(
        IssuancesError(message: l.message),
      ),
      (r) => emit(
        RISRegistered(
          ris: r,
        ),
      ),
    );
  }

  void _onUpdateIssuanceArchiveStatus(
    UpdateIssuanceArchiveStatusEvent event,
    Emitter<IssuancesState> emit,
  ) async {
    emit(IssuancesLoading());

    final response = await _updateIssuanceArchiveStatus(
      UpdateIssuanceArchiveStatusParams(
        id: event.id,
        isArchived: event.isArchived,
      ),
    );

    response.fold(
      (l) => emit(IssuancesError(message: l.message)),
      (r) => emit(
        IssuanceArchiveStatusUpdated(
          isSuccessful: r,
        ),
      ),
    );
  }

  void _onGetInventorySupplyReport(
    GetInventorySupplyReportEvent event,
    Emitter<IssuancesState> emit,
  ) async {
    print('Processing get inventory supply report...');
    emit(IssuancesLoading());

    print('loading get inventory supply report...');

    final response = await _getInventorySupplies(
      GenerateRPCIParams(
        startDate: event.startDate,
        endDate: event.endDate,
        fundCluster: event.fundCluster,
      ),
    );

    print('Processed response...');

    response.fold(
      (l) => emit(IssuancesError(message: l.message)),
      (r) => emit(
        FetchedInventoryReport(
          inventoryReport: r,
        ),
      ),
    );
  }

  void _onGetInventorySemiExpendablePropertyReport(
    GetInventorySemiExpendablePropertyReportEvent event,
    Emitter<IssuancesState> emit,
  ) async {
    emit(IssuancesLoading());

    final response = await _getInventorySemiExpendablePropertyReport(
      GenerateRPSEPParams(
        startDate: event.startDate,
        endDate: event.endDate,
        assetSubClass: event.assetSubClass,
        fundCluster: event.fundCluster,
      ),
    );

    response.fold(
      (l) => emit(IssuancesError(message: l.message)),
      (r) => emit(
        FetchedInventoryReport(
          inventoryReport: r,
        ),
      ),
    );
  }

  void _onGetInventoryPropertyReport(
    GetInventoryPropertyReportEvent event,
    Emitter<IssuancesState> emit,
  ) async {
    emit(IssuancesLoading());

    final response = await _getInventoryPropertyReport(
      GenerateRPPEParams(
        startDate: event.startDate,
        endDate: event.endDate,
        assetSubClass: event.assetSubClass,
        fundCluster: event.fundCluster,
      ),
    );

    response.fold(
      (l) => emit(IssuancesError(message: l.message)),
      (r) => emit(
        FetchedInventoryReport(
          inventoryReport: r,
        ),
      ),
    );
  }

  void _onGenerateSemiExpendablePropertyCardData(
    GenerateSemiExpendablePropertyCardDataEvent event,
    Emitter<IssuancesState> emit,
  ) async {
    emit(IssuancesLoading());

    final response = await _generateSemiExpendablePropertyCardData(
      GenerateSemiExpendablePropertyCardDataParams(
        icsId: event.icsId,
        fundCluster: event.fundCluster,
      ),
    );

    response.fold(
      (l) => emit(IssuancesError(message: l.message)),
      (r) => emit(
        GeneratedSemiExpendablePropertyCardData(
          semiExpendablePropertyCardData: r,
        ),
      ),
    );
  }

  void _onReceiveIssuance(
    ReceiveIssuanceEvent event,
    Emitter<IssuancesState> emit,
  ) async {
    emit(IssuancesLoading());

    final response = await _receiveIssuance(
      ReceiveIssuanceParams(
        baseIssuanceId: event.baseIssuanceId,
        entity: event.entity,
        receivingOfficerOffice: event.receivingOfficerOffice,
        receivingOfficerPosition: event.receivingOfficerPosition,
        receivingOfficerName: event.receivingOfficerName,
        receivedDate: event.receivedDate,
      ),
    );

    response.fold(
      (l) => emit(IssuancesError(message: l.message)),
      (r) => emit(
        ReceivedIssuance(
          isSuccessful: r,
        ),
      ),
    );
  }

  void _onGetAccountableOfficerId(
    GetAccountableOfficerIdEvent event,
    Emitter<IssuancesState> emit,
  ) async {
    emit(IssuancesLoading());

    final response = await _getAccountableOfficerId(
      GetAccountableOfficerIdParams(
        office: event.office,
        position: event.position,
        name: event.name,
      ),
    );

    response.fold(
      (l) => emit(
        IssuancesError(message: l.message),
      ),
      (r) => emit(
        FetchedAccountableOfficerId(
          officerId: r,
        ),
      ),
    );
  }

  void _onGetOfficerAccountability(
    GetOfficerAccountabilityEvent event,
    Emitter<IssuancesState> emit,
  ) async {
    emit(IssuancesLoading());

    final response = await _getOfficerAccountability(
      GetOfficerAccountabilityParams(
        officerId: event.officerId,
        startDate: event.startDate,
        endDate: event.endDate,
        searchQuery: event.searchQuery,
      ),
    );

    response.fold(
      (l) => emit(IssuancesError(message: l.message)),
      (r) => emit(
        FetchedOfficerAccountability(
          officerAccountability: r,
        ),
      ),
    );
  }

  void _onResolveIssuanceItem(
    ResolveIssuanceItemEvent event,
    Emitter<IssuancesState> emit,
  ) async {
    emit(IssuancesLoading());

    final response = await _resolveIssuanceItem(
      ResolveIssuanceItemParams(
        baseItemId: event.baseItemId,
        status: event.status,
        date: event.date,
        remarks: event.remarks,
      ),
    );

    response.fold(
      (l) => emit(IssuancesError(message: l.message)),
      (r) => emit(
        ResolvedIssuanceItem(
          isSuccessful: r,
        ),
      ),
    );
  }
}
