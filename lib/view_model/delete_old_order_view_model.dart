// import 'package:flutter/foundation.dart';
// import 'package:yoyomiles_partner/model/delete_old_order_model.dart';
// import 'package:yoyomiles_partner/repo/delete_old_order_repo.dart';
//
// class DeleteOldOrderViewModel with ChangeNotifier {
//   final _deleteOldOrderRepo = DeleteOldOrderRepo();
//
//   bool _loading = false;
//   bool get loading => _loading;
//
//   setLoading(bool value) {
//     _loading = value;
//     notifyListeners();
//   }
//
//   DeleteOldOrderModel? _deleteOldOrderModel;
//   DeleteOldOrderModel? get deleteOldOrderModel => _deleteOldOrderModel;
//
//   setContactListData(DeleteOldOrderModel value) {
//     _deleteOldOrderModel = value;
//     notifyListeners();
//   }
//
//   Future<void> deleteOldOrderApi() async {
//     setLoading(true);
//
//     _deleteOldOrderRepo.deleteOldOrderApi().then((value) {
//       debugPrint('value:$value');
//       if (value.status == 200) {
//         setContactListData(value);
//       }
//       setLoading(false);
//     }).onError((error, stackTrace) {
//       setLoading(false);
//       if (kDebugMode) {
//         print('error: $error');
//       }
//     });
//   }
//
// }
