import 'package:atl_app/database/services/read/payment_service_read.dart';
import 'package:atl_app/database/services/write/payment_service_write.dart';

class PaymentService {
  static final PaymentServiceWrite Write = PaymentServiceWrite();
  static final PaymentServiceRead Read = PaymentServiceRead();
}
