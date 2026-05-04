class ConversationModel {
  final int otherUserId;
  final String otherUserName;
  final String? otherUserProfilePicture;
  final String otherUserRole;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ConversationModel({
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserProfilePicture,
    required this.otherUserRole,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      otherUserId: json['otherUserId'] as int,
      otherUserName: json['otherUserName'] as String,
      otherUserProfilePicture: json['otherUserProfilePicture'] as String?,
      otherUserRole: json['otherUserRole'] as String,
      lastMessage: json['lastMessage'] as String,
      lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
      unreadCount: json['unreadCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'otherUserId': otherUserId,
      'otherUserName': otherUserName,
      'otherUserProfilePicture': otherUserProfilePicture,
      'otherUserRole': otherUserRole,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }
}
