import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import '../models/list_model.dart';
import 'step_bloc.dart';
import 'task_bloc.dart';

class ListBloc {
  final ListModel list = ListModel(id: '-LWEZ8FWDx_RqDEdP3OI', title: '我的清单');

  final _createListSubject = PublishSubject<ListModel>();

  final _updateListSubject = PublishSubject<ListModel>();

  final _retrieveListSubject = BehaviorSubject<ListModel>();

  final _deleteListSubject = PublishSubject<String>();

  final _retrieveListsSubject = BehaviorSubject<List<ListModel>>();

  ListBloc() {
    _createListSubject.stream.listen((ListModel snapshot) {
      Firestore.instance
          .collection('lists')
          .add(snapshot.toJson())
          .then((DocumentReference reference) {
        ListModel list =
            ListModel(id: reference.documentID, title: snapshot.title);
        _retrieveListSubject.add(list);
      });
    });

    _updateListSubject.stream.listen((ListModel snapshot) {
      Firestore.instance
          .collection('lists')
          .document(snapshot.id)
          .setData(snapshot.toJson());
      _retrieveListSubject.add(snapshot);
    });

    _deleteListSubject.stream.listen((String snapshot) {
      Firestore.instance.collection('lists').document(snapshot).delete();

      TaskBloc().deleteTasksSink.add(snapshot);

      Firestore.instance
          .collection('tasks')
          .where('listId', isEqualTo: snapshot)
          .getDocuments()
          .then((QuerySnapshot querySnapshot) => querySnapshot.documents
              .forEach((document) =>
                  StepBloc().deleteStepsSink.add(document.data['id'])));

      _retrieveListSubject.add(list);
    });

    Firestore.instance
        .collection('lists')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      List<ListModel> lists = snapshot.documents
          .map((document) => ListModel.fromJson(
              {'id': document.documentID, 'title': document.data['title']}))
          .toList();
      _retrieveListsSubject.add(lists);
    });
  }

  get createListSink => _createListSubject.sink;

  get updateListSink => _updateListSubject.sink;

  get retrieveListSink => _retrieveListSubject.sink;

  get retrieveListStream => _retrieveListSubject.stream;

  get deleteListSink => _deleteListSubject.sink;

  get retrieveListsStream => _retrieveListsSubject.stream;
}
