import 'package:doctor_appointment/features/chatbot/domain/entities/ai_chat_entity.dart';

class AIChatRequestModel {
  final String sessionId;
  final String message;

  AIChatRequestModel({
    required this.sessionId,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'message': message,
    };
  }
}

class AIChatResponseModel extends AIChatResponse {
  const AIChatResponseModel({
    required super.sessionId,
    required super.userMessage,
    required super.aiMessage,
    super.riskLevel,
    super.followUpQuestions,
    super.structured,
    required super.createdAt,
  });

  factory AIChatResponseModel.fromJson(Map<String, dynamic> json) {
    return AIChatResponseModel(
      sessionId: json['sessionId'] as String,
      userMessage: json['userMessage'] as String,
      aiMessage: json['aiMessage'] as String,
      riskLevel: json['riskLevel'] as String?,
      followUpQuestions: (json['followUpQuestions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      structured: json['structured'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class AIChatHistoryModel extends AIChatMessage {
  const AIChatHistoryModel({
    required super.id,
    required super.sessionId,
    required super.userMessage,
    required super.aiMessage,
    required super.createdAt,
  });

  factory AIChatHistoryModel.fromJson(Map<String, dynamic> json) {
    return AIChatHistoryModel(
      id: json['id'] as int?,
      sessionId: json['sessionId'] as String,
      userMessage: json['userMessage'] as String,
      aiMessage: json['aiMessage'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
