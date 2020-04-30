import 'package:json_annotation/json_annotation.dart';

part 'step_model.g.dart';

@JsonSerializable()
class StepModel {
  String id;
  String taskId;
  String title;
  int createTime;
  bool status;

  StepModel(
      {this.id, this.taskId, this.title, this.createTime, this.status = false});

  factory StepModel.fromJson(Map<String, dynamic> json) =>
      _$StepModelFromJson(json);

  Map<String, dynamic> toJson() => _$StepModelToJson(this);

  @override
  String toString() {
    return 'StepModel(id: $id, taskId: $taskId, title: $title, createTime: $createTime,status: $status)';
  }
}
