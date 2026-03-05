import '/../models/referee_license.dart';
import '../../config/app_config.dart';
import 'base_repository.dart';

class RefereeLicensesRepository extends BaseRepository<RefereeLicense> {
  @override
  String get endpoint => 'referee_licenses';

  @override
  RefereeLicense fromJson(Map<String, dynamic> json) =>
      RefereeLicense.fromJson(json);

  @override
  Map<String, dynamic> toJson(RefereeLicense item) => item.toJson();

  List<RefereeLicense> _mockData = [];
}
