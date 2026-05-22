class ChatMessageModel {
  final int id;
  final int senderId;
  final String senderName;
  final int receiverId;
  final String receiverName;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final bool isFailed;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.message,
    required this.timestamp,
    required this.isRead,
    this.isFailed = false,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: (json['id'] ?? json['Id']) as int? ?? 0,
      senderId: (json['senderId'] ?? json['SenderId']) as int? ?? 0,
      senderName: (json['senderName'] ?? json['SenderName']) as String? ?? 'Unknown',
      receiverId: (json['receiverId'] ?? json['ReceiverId']) as int? ?? 0,
      receiverName: (json['receiverName'] ?? json['ReceiverName']) as String? ?? 'Unknown',
      message: (json['message'] ?? json['Message']) as String? ?? '',
      timestamp: (json['timestamp'] ?? json['Timestamp']) != null
          ? DateTime.parse((json['timestamp'] ?? json['Timestamp']) as String)
          : DateTime.now(),
      isRead: (json['isRead'] ?? json['IsRead']) as bool? ?? false,
      isFailed: (json['isFailed'] ?? json['IsFailed']) as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'isFailed': isFailed,
    };
  }

  ChatMessageModel copyWith({
    int? id,
    int? senderId,
    String? senderName,
    int? receiverId,
    String? receiverName,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    bool? isFailed,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isFailed: isFailed ?? this.isFailed,
    );
  }
}
