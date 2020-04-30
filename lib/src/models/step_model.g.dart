// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StepModel _$StepModelFromJson(Map<String, dynamic> json) {
  return StepModel(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      title: json['title'] as String,
      createTime: json['createTime'] as int,
      status: json['status'] as bool);
}

Map<String, dynamic> _$StepModelToJson(StepModel instance) => <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'title': instance.title,
      'createTime': instance.createTime,
      'status': instance.status
    };
