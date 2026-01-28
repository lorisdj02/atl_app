class Order{
  final int id;
  final int clientUserId;
  final double price;
  final int? bookingId;
  final bool vipSubscription;

  Order({
    required this.id,
    required this.clientUserId,
    required this.price,
    this.bookingId,
    this.vipSubscription = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_user_id': clientUserId,
      'price': price,
      'booking_id': bookingId,
      'vip_subscription': vipSubscription,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      clientUserId: json['client_user_id'],
      price: json['price'].toDouble(),
      bookingId: json['booking_id'],
      vipSubscription: json['vip_subscription'] ?? false,
    );
  }
}