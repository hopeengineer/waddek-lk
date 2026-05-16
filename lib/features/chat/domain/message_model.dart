import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

/// Chat conversation between matched customer and worker.
@freezed
class ConversationModel with _$ConversationModel {
  const factory ConversationModel({
    required String id,
    // Nullable: a conversation can exist before a job is created
    // (the customer taps "Message" on a worker's profile; the job is
    // only created later from inside the chat via "Propose Job").
    @JsonKey(name: 'job_id') String? jobId,
    @JsonKey(name: 'customer_id') required String customerId,
    @JsonKey(name: 'worker_id') required String workerId,
    @JsonKey(name: 'last_message_at') DateTime? lastMessageAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    // Joined data
    @JsonKey(name: 'customer') Map<String, dynamic>? customerData,
    @JsonKey(name: 'worker') Map<String, dynamic>? workerData,
    @JsonKey(name: 'job') Map<String, dynamic>? jobData,
  }) = _ConversationModel;

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);
}

/// Individual chat message.
@freezed
class MessageModel with _$MessageModel {
  const factory MessageModel({
    required String id,
    @JsonKey(name: 'conversation_id') required String conversationId,
    @JsonKey(name: 'sender_id') required String senderId,
    required String content,
    /// 'text', 'image', 'location', 'system'
    @Default('text') String type,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);
}
