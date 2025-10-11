import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/model/help_topics_model.dart';
import 'package:yoyomiles_partner/repo/help_topics_repo.dart';

class HelpTopicsViewModel with ChangeNotifier {
  final _helpTopicsRepo = HelpTopicsRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  HelpTopicsModel? _helpTopicsModel;
  HelpTopicsModel? get helpTopicsModel => _helpTopicsModel;

  setModelData(HelpTopicsModel value) {
    _helpTopicsModel = value;
    notifyListeners();
  }

  Future<void> helpTopicApi() async {
    setLoading(true);
    try {
      final value = await _helpTopicsRepo.helpTopicApi();
      debugPrint('value: $value');

      if (value.status == 200) {
        setModelData(value);
      } else {
        debugPrint('API returned non-200: ${value.status}');
      }
    } catch (error) {
      debugPrint('error: $error');
    } finally {
      setLoading(false);
    }
  }


}
