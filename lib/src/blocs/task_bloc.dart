import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import '../models/task_model.dart';
import 'step_bloc.dart';

class TaskBloc {
  final task = TaskModel();

  final _createTaskSubject = PublishSubject<TaskModel>();

  final _updateTaskSubject = PublishSubject<TaskModel>();

  final _retrieveTaskSubject = BehaviorSubject<TaskModel>();

  final _deleteTaskSubject = PublishSubject<String>();

  final _retrieveTasksSubject = BehaviorSubject<List<TaskModel>>();

  final _deleteTasksSubject = PublishSubject<String>();

  TaskBloc() {
    _createTaskSubject.stream.listen((TaskModel snapshot) {
      Firestore.instance.collection('tasks').add(snapshot.toJson());
    });

    _updateTaskSubject.stream.listen((TaskModel snapshot) {
      Firestore.instance
          .collection('tasks')
          .document(snapshot.id)
          .setData(snapshot.toJson());
      _retrieveTaskSubject.add(snapshot);
    });

    _deleteTaskSubject.stream.listen((String snapshot) {
      Firestore.instance.collection('tasks').document(snapshot).delete();

      StepBloc().deleteStepsSink.add(snapshot);
    });

    _deleteTasksSubject.stream.listen((String snapshot) {
      Firestore.instance
          .collection('tasks')
          .where('listId', isEqualTo: snapshot)
          .getDocuments()
          .then((QuerySnapshot snapshot) => snapshot.documents
              .forEach((document) => document.reference.delete()));
    });

    Firestore.instance
        .collection('tasks')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      List<TaskModel> tasks = snapshot.documents
          .map((document) => TaskModel.fromJson({
                'id': document.documentID,
                'listId': document.data['listId'],
                'title': document.data['title'],
                'createTime': document.data['createTime'],
                'status': document.data['status'],
                'remark': document.data['remark'],
                'endTime': document.data['endTime']
              }))
          .toList();
      _retrieveTasksSubject.add(tasks);
    });
  }

  get createTaskSink => _createTaskSubject.sink;

  get updateTaskSink => _updateTaskSubject.sink;

  get retrieveTaskSink => _retrieveTaskSubject.sink;

  get retrieveTaskStream => _retrieveTaskSubject.stream;

  get deleteTaskSink => _deleteTaskSubject.sink;

  get retrieveTasksStream => _retrieveTasksSubject.stream;

  get deleteTasksSink => _deleteTasksSubject.sink;
}
