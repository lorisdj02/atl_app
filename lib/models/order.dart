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
      'clientUserId': clientUserId,
      'price': price,
      'bookingId': bookingId,
      'vipSubscription': vipSubscription,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      clientUserId: json['clientUserId'],
      price: json['price'].toDouble(),
      bookingId: json['bookingId'],
      vipSubscription: json['vipSubscription'] ?? false,
    );
  }
}