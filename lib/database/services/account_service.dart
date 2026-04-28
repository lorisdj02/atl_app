import 'package:atl_app/database/services/read/account_service_read.dart';
import 'package:atl_app/database/services/write/account_service_write.dart';

class AccountService {
  static final AccountServiceRead Read = AccountServiceRead();
  static final AccountServiceWrite Write = AccountServiceWrite();
}
