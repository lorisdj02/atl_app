import 'package:atl_app/database/controller/read/field_controller_read.dart';
import 'package:atl_app/database/controller/write/field_controller_write.dart';

class FieldController {
  static final FieldControllerRead Read = FieldControllerRead();
  static final FieldControllerWrite Write = FieldControllerWrite();
}