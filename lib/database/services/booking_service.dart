import 'package:atl_app/database/services/read/booking_service_read.dart';
import 'package:atl_app/database/services/write/booking_service_write.dart';

class BookingService {
  static final BookingServiceRead Read = BookingServiceRead();
  static final BookingServiceWrite Write = BookingServiceWrite();
}
