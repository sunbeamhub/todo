import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import '../models/step_model.dart';

class StepBloc {
  final _createStepSubject = PublishSubject<StepModel>();

  final _updateStepSubject = PublishSubject<StepModel>();

  final _deleteStepSubject = PublishSubject<String>();

  final _retrieveStepsSubject = BehaviorSubject<List<StepModel>>();

  final _deleteStepsSubject = PublishSubject<String>();

  StepBloc() {
    _createStepSubject.stream.listen((StepModel snapshot) {
      Firestore.instance.collection('steps').add(snapshot.toJson());
    });

    _updateStepSubject.stream.listen((StepModel snapshot) {
      Firestore.instance
          .collection('steps')
          .document(snapshot.id)
          .setData(snapshot.toJson());
    });

    _deleteStepSubject.stream.listen((String snapshot) {
      Firestore.instance.collection('steps').document(snapshot).delete();
    });

    _deleteStepsSubject.stream.listen((String snapshot) {
      Firestore.instance
          .collection('steps')
          .where('taskId', isEqualTo: snapshot)
          .getDocuments()
          .then((QuerySnapshot snapshot) => snapshot.documents
              .forEach((document) => document.reference.delete()));
    });

    Firestore.instance
        .collection('steps')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      List<StepModel> steps = snapshot.documents
          .map((document) => StepModel.fromJson({
                'id': document.documentID,
                'taskId': document.data['taskId'],
                'title': document.data['title'],
                'createTime': document.data['createTime'],
                'status': document.data['status']
              }))
          .toList();
      _retrieveStepsSubject.add(steps);
    });
  }

  get createStepSink => _createStepSubject.sink;

  get updateStepSink => _updateStepSubject.sink;

  get deleteStepSink => _deleteStepSubject.sink;

  get retrieveStepsStream => _retrieveStepsSubject.stream;

  get deleteStepsSink => _deleteStepsSubject.sink;
}
