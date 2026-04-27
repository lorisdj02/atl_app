import 'package:atl_app/database/controller/read/account_controller_read.dart';
import 'package:atl_app/database/controller/write/account_controller_write.dart';

class AccountController {
  static final AccountControllerRead Read = AccountControllerRead();
  static final AccountControllerWrite Write = AccountControllerWrite();
}
