import 'package:atl_app/database/services/read/match_service_read.dart';
import 'package:atl_app/database/services/write/match_service_write.dart';

class MatchService {
  static final MatchServiceRead Read = MatchServiceRead();
  static final MatchServiceWrite Write = MatchServiceWrite();
}