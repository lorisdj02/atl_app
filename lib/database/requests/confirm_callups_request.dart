import 'package:atl_app/config/api_json_keys.dart';

class ConfirmCallupsRequest {
  final double tournamentId;
  final double teamId;
  final List<double> selectedPlayerIds;

  ConfirmCallupsRequest({
    required this.tournamentId,
    required this.teamId,
    required this.selectedPlayerIds,
  });

  Map<String, dynamic> toJson() {
    return {
      ApiJsonKeys.tournamentId: tournamentId,
      ApiJsonKeys.teamId: teamId,
      ApiJsonKeys.selectedPlayerIds: selectedPlayerIds,
    };
  }
}
