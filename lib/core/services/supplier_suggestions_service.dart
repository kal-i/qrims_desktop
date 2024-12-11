// import 'http_service.dart';
//
// class SupplierSuggestionsService {
//   const SupplierSuggestionsService({
//     required this.httpService,
//   });
//
//   final HttpService httpService;
//
//   Future<List<String>?> fetchSupplierNames({
//     required String? supplierName,
//   }) async {
//     final Map<String, dynamic> queryParam = {
//       // 'page': page,
//       // 'page_size': 2,
//       if (supplierName != null && supplierName.isNotEmpty)
//         'supplier_name': supplierName,
//     };
//
//     final response = await httpService.get(
//       endpoint: officesEP,
//       queryParams: queryParam,
//     );
//
//     final officeNames = (response.data['offices'] as List<dynamic>?)
//         ?.map((officeName) => capitalizeWord(officeName))
//         .toList();
//
//     return officeNames;
//   }
// }
