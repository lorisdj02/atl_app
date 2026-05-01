enum GrowthStepType {
  referee,
  coordinator;

  String get apiName {
    switch (this) {
      case GrowthStepType.referee:
        return 'REFEREE';
      case GrowthStepType.coordinator:
        return 'COORDINATOR';
    }
  }
}