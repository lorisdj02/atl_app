import 'package:atl_app/config/api_json_keys.dart';

class ConfirmCallupsRequest {
  final int tournamentId;
  final int teamId;
  final List<int> selectedPlayerIds;

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
