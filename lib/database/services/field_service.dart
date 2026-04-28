import 'package:atl_app/database/services/read/field_service_read.dart';
import 'package:atl_app/database/services/write/field_service_write.dart';

class FieldService {
  static final FieldServiceRead Read = FieldServiceRead();
  static final FieldServiceWrite Write = FieldServiceWrite();
}