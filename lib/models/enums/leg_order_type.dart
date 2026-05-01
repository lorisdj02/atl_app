enum LegOrderType {
  firstLeg,
  secondLeg;

  String get apiName {
    switch (this) {
      case LegOrderType.firstLeg:
        return 'FIRST_LEG';
      case LegOrderType.secondLeg:
        return 'SECOND_LEG';
    }
  }
}

extension LegOrderTypeExtension on LegOrderType {
  static LegOrderType fromJson(String json) {
    final normalized = json.toUpperCase();
    return LegOrderType.values.firstWhere((e) => e.apiName == normalized);
  }
}
