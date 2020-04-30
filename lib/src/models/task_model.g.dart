// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) {
  return TaskModel(
      id: json['id'] as String,
      listId: json['listId'] as String,
      title: json['title'] as String,
      createTime: json['createTime'] as int,
      status: json['status'] as bool,
      remark: json['remark'] as String,
      endTime: json['endTime'] as int);
}

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
      'id': instance.id,
      'listId': instance.listId,
      'title': instance.title,
      'createTime': instance.createTime,
      'status': instance.status,
      'remark': instance.remark,
      'endTime': instance.endTime
    };
