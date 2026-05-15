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
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}