import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

/// In-app notification.
@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    /// 'new_job', 'bid_accepted', 'job_matched', 'wallet', 'subscription', 'review', 'system'
    required String type,
    required String title,
    String? body,
    @Default(false) @JsonKey(name: 'is_read') bool isRead,
    Map<String, dynamic>? data,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}
