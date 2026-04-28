import 'package:atl_app/database/services/read/team_service_read.dart';
import 'package:atl_app/database/services/write/team_service.write.dart';

class TeamService{
  static final TeamServiceRead Read = TeamServiceRead();
  static final TeamServiceWrite Write = TeamServiceWrite();
}