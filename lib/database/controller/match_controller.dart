import 'package:atl_app/database/controller/read/match_controller_read.dart';
import 'package:atl_app/database/controller/write/match_controller_write.dart';

class MatchController {
  static final MatchControllerRead Read = MatchControllerRead();
  static final MatchControllerWrite Write = MatchControllerWrite();
}