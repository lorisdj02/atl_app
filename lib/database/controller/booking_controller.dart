import 'package:atl_app/database/controller/read/booking_controller_read.dart';
import 'package:atl_app/database/controller/write/booking_controller_write.dart';

class BookingController {
  static final BookingControllerRead Read = BookingControllerRead();
  static final BookingControllerWrite Write = BookingControllerWrite();
}
