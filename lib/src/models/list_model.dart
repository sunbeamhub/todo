import 'package:json_annotation/json_annotation.dart';

part 'list_model.g.dart';

@JsonSerializable()
class ListModel {
  String id;
  String title;

  ListModel({this.id, this.title});

  factory ListModel.fromJson(Map<String, dynamic> json) =>
      _$ListModelFromJson(json);

  Map<String, dynamic> toJson() => _$ListModelToJson(this);
}
