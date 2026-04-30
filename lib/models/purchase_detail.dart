// OK
class PurchaseDetail{
  final String title;
  final String description;

  PurchaseDetail({
    required this.title,
    required this.description,
  });

  factory PurchaseDetail.fromJson(Map<String, dynamic> json) {
    return PurchaseDetail(
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}