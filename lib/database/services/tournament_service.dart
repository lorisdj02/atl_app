import 'package:atl_app/database/services/read/tournament_service_read.dart';
import 'package:atl_app/database/services/write/tournament_service_write.dart';

class TournamentService {
  static final TournamentServiceRead Read = TournamentServiceRead();
  static final TournamentServiceWrite Write = TournamentServiceWrite();
}
