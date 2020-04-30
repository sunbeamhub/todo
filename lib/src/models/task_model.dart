import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel {
  String id;
  String listId;
  String title;
  int createTime;
  bool status;
  String remark;
  int endTime;

  TaskModel(
      {this.id,
      this.listId,
      this.title,
      this.createTime,
      this.status = false,
      this.remark,
      this.endTime});

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  @override
  String toString() {
    return 'TaskModel(id: $id, listId: $listId, title: $title, createTime: $createTime, status: $status, remark: $remark, endTime: $endTime)';
  }
}
