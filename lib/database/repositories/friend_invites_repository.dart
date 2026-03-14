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

  Future<bool> addInvite({required int inviterUserId,required int invitedUserId}) async {
    if(AppConfig.isDebug){
      _mockData.add(FriendInvite(inviterId: inviterUserId, invitedId: invitedUserId));
      return true;
    }else{
      throw UnimplementedError();
    }
  }


  Future<bool> redeemInvite(int inviterId, int invitedId) async {
    if(AppConfig.isDebug){
      final invite = _mockData.firstWhere(
        (invite) => invite.inviterId == inviterId && invite.invitedId == invitedId,
        orElse: () => throw Exception('Invite not found'),
      );
      invite.redeemed = true;
      return true;
    }else{
      throw UnimplementedError();
    }
  }

  Future<int> countRedeemedInvitesByUserId(int inviterId) async {
    if(AppConfig.isDebug){
      return _mockData.where((invite) => invite.inviterId == inviterId && invite.redeemed).length;
    }else{
      throw UnimplementedError();
    }
  }

  Future<int> countInvitesByUserId(int inviterId) async {
    if(AppConfig.isDebug){
      return _mockData.where((invite) => invite.inviterId == inviterId).length;
    }else{
      throw UnimplementedError();
    }
  }

  Future<List<FriendInvite>> getInvitedForUser(int inviterId) async {
    if(AppConfig.isDebug){
      return _mockData.where((invite) => invite.inviterId == inviterId).toList();
    }else{
      throw UnimplementedError();
    }
  }
}
