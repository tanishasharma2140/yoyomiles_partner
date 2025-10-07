import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/model/cities_model.dart';
import 'package:yoyomiles_partner/repo/cities_repo.dart';

class CitiesViewModel with ChangeNotifier {
  final _citiesRepo = CitiesRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  CitiesModel? _citiesModel;
  CitiesModel? get citiesModel => _citiesModel;

  setModelData(CitiesModel value) {
    _citiesModel = value;
    notifyListeners();
  }

  Future<void> citiesApi() async {
    setLoading(true);

    _citiesRepo.citiesApi().then((value) {
      debugPrint('value:$value');
      if (value.status == 200) {
        setModelData(value);
      }
    }).onError((error, stackTrace) {
      setLoading(false);
      if (kDebugMode) {
        print('error: $error');
      }
    });
  }
}
