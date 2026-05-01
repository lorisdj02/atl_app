enum MatchSlotType{
  home,
  away;

  String get apiName {
    switch (this) {
      case MatchSlotType.home:
        return 'HOME';
      case MatchSlotType.away:
        return 'AWAY';
    }
  }
}

extension MatchSlotTypeExtension on MatchSlotType {
  static MatchSlotType fromJson(String json) {
    final normalized = json.toUpperCase();
    return MatchSlotType.values.firstWhere(
      (e) => e.apiName == normalized,
      orElse: () => throw ArgumentError('Unknown match slot type: $json'),
    );
  }
}