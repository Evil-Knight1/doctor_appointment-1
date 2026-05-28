import 'package:doctor_appointment/features/chatbot/domain/entities/ai_chat_entity.dart';

class AIChatRequestModel {
  final String sessionId;
  final String message;
  final String? type;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? medicalContext;
  final Map<String, dynamic>? toolResult;

  AIChatRequestModel({
    required this.sessionId,
    required this.message,
    this.type,
    this.metadata,
    this.medicalContext,
    this.toolResult,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'sessionId': sessionId,
      'message': message,
    };
    if (type != null) data['type'] = type;
    if (metadata != null) data['metadata'] = metadata;
    if (medicalContext != null) data['medicalContext'] = medicalContext;
    if (toolResult != null) data['toolResult'] = toolResult;
    return data;
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
    super.type,
    super.ui,
    super.searchParams,
    required super.createdAt,
  });

  factory AIChatResponseModel.fromJson(Map<String, dynamic> json) {
    UiComponent? uiComponent;
    if (json['ui'] != null) {
      uiComponent = UiComponent(
        type: json['ui']['type'] as String? ?? 'text',
        options: (json['ui']['options'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        allowOther: json['ui']['allowOther'] as bool? ?? true,
      );
    }

    DoctorSearchParams? searchParamsModel;
    if (json['searchParams'] != null) {
      final params = json['searchParams'] as Map<String, dynamic>;
      searchParamsModel = DoctorSearchParams(
        specialization: params['specialization'] as String?,
        location: params['location'] as String?,
        minRating: (params['minRating'] as num?)?.toDouble(),
      );
    }

    return AIChatResponseModel(
      sessionId: json['sessionId'] as String,
      userMessage: json['userMessage'] as String,
      aiMessage: json['aiMessage'] as String,
      riskLevel: json['riskLevel'] as String?,
      followUpQuestions: (json['followUpQuestions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      structured: json['structured'] as Map<String, dynamic>?,
      type: json['type'] as String?,
      ui: uiComponent,
      searchParams: searchParamsModel,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class NewChatResponseModel extends NewChatResponse {
  const NewChatResponseModel({
    required super.sessionId,
    required super.welcomeMessageEn,
    required super.welcomeMessageAr,
  });

  factory NewChatResponseModel.fromJson(Map<String, dynamic> json) {
    return NewChatResponseModel(
      sessionId: json['sessionId'] as String,
      welcomeMessageEn: json['welcomeMessage']['en'] as String,
      welcomeMessageAr: json['welcomeMessage']['ar'] as String,
    );
  }
}

class AIChatHistoryModel extends AIChatMessage {
  const AIChatHistoryModel({
    super.id,
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
