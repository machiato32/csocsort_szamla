class Member{
  double balance;
  String nickname;
  String username;
  String apiToken;
  int memberId;
  bool isAdmin;
  Member({this.username, this.nickname, this.balance, this.isAdmin, this.memberId, this.apiToken});
  factory Member.fromJson(Map<String, dynamic> json){
    return Member(
      username: json['username'],
      memberId: json['user_id'],
      nickname: json['nickname'],
      balance: json['balance']*1.0,
      isAdmin: json['is_admin']==1
    );
  }

  @override
  String toString() {
    return nickname;
  }

  Map toJson(){
    return {
      'user_id':memberId
    };
  }

}
class Group{
  String groupCurrency;
  String groupName;
  int groupId;
  Group({this.groupName, this.groupId, this.groupCurrency});
}