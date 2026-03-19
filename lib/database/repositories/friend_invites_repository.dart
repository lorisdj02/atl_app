import 'package:atl_app/config/app_config.dart';

import 'base_repository.dart';
import '../../models/friend_invite.dart';

class FriendInvitesRepository extends BaseRepository<FriendInvite> {
  @override
  String get endpoint => 'friend_invites';

  List<FriendInvite> _mockData = [];

  @override
  List<FriendInvite> get mockData => _mockData;

  @override
  FriendInvite fromJson(Map<String, dynamic> json) {
    return FriendInvite.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(FriendInvite item) {
    return item.toJson();
  }

  Future<bool> addInvite({required int inviterAccountId,required int invitedAccountId}) async {
    if(AppConfig.isDebug){
      _mockData.add(FriendInvite(inviterAccountId: inviterAccountId, invitedAccountId: invitedAccountId));
      return true;
    }else{
      throw UnimplementedError();
    }
  }


  Future<bool> redeemInvite(int inviterAccountId, int invitedAccountId) async {
    if(AppConfig.isDebug){
      final invite = _mockData.firstWhere(
        (invite) => invite.inviterAccountId == inviterAccountId && invite.invitedAccountId == invitedAccountId,
        orElse: () => throw Exception('Invite not found'),
      );
      invite.redeemed = true;
      return true;
    }else{
      throw UnimplementedError();
    }
  }

  Future<int> countRedeemedInvitesByAccountId(int inviterAccountId) async {
    if(AppConfig.isDebug){
      return _mockData.where((invite) => invite.inviterAccountId == inviterAccountId && invite.redeemed).length;
    }else{
      throw UnimplementedError();
    }
  }

  Future<int> countInvitesByAccountId(int inviterAccountId) async {
    if(AppConfig.isDebug){
      return _mockData.where((invite) => invite.inviterAccountId == inviterAccountId).length;
    }else{
      throw UnimplementedError();
    }
  }

  Future<List<FriendInvite>> getInvitedForAccount(int inviterAccountId) async {
    if(AppConfig.isDebug){
      return _mockData.where((invite) => invite.inviterAccountId == inviterAccountId).toList();
    }else{
      throw UnimplementedError();
    }
  }
}
