import 'package:flutter/material.dart';

import '../models/list_model.dart';
import '../models/task_model.dart';
import '../provider.dart';
import '../widgets/standard_input.dart';

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() {
    return _ListScreenState();
  }
}

class _ListScreenState extends State<ListScreen> {
  bool _completedTaskVisible = true;

  _menu(context) {
    final provider = Provider.of(context);

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Theme.of(context).hintColor,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16.0))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  StreamBuilder<ListModel>(
                    stream: provider.listBloc.retrieveListStream,
                    initialData: provider.listBloc.list,
                    builder: (context, snapshot) {
                      return ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('重命名清单'),
                        onTap: () {
                          Navigator.pop(context);
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return StandardInput(
                                  hintText: '重命名清单',
                                  initialValue: snapshot.data.title,
                                  save: (title) {
                                    provider.listBloc.updateListSink.add(
                                        ListModel(
                                            id: snapshot.data.id,
                                            title: title));
                                  });
                            },
                          );
                        },
                        enabled: snapshot.hasData &&
                            snapshot.data.id != provider.listBloc.list.id,
                      );
                    },
                  ),
                  StreamBuilder<ListModel>(
                    stream: provider.listBloc.retrieveListStream,
                    initialData: provider.listBloc.list,
                    builder: (context, snapshot) {
                      return ListTile(
                        leading: Icon(Icons.delete),
                        title: Text('删除清单'),
                        onTap: () {
                          Navigator.pop(context);
                          _delete(context);
                        },
                        enabled: snapshot.hasData &&
                            snapshot.data.id != provider.listBloc.list.id,
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.radio_button_checked),
                    title: Text(_completedTaskVisible ? '隐藏完成任务' : '显示完成任务'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _completedTaskVisible = !_completedTaskVisible;
                      });
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  _delete(context) {
    final provider = Provider.of(context);
    showDialog(
        context: context,
        builder: (context) {
          return StreamBuilder<ListModel>(
            stream: provider.listBloc.retrieveListStream,
            initialData: provider.listBloc.list,
            builder: (context, snapshot) {
              return AlertDialog(
                title: Text('删除清单？'),
                content: Text(
                    '"${snapshot.hasData ? snapshot.data.title : ''}"将永久删除'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('取消'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  FlatButton(
                    child: Text('确定'),
                    onPressed: () {
                      Navigator.pop(context);
                      provider.listBloc.deleteListSink.add(snapshot.data.id);
                    },
                  )
                ],
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of(context);

    var appBar = AppBar(
      title: StreamBuilder<ListModel>(
          stream: provider.listBloc.retrieveListStream,
          initialData: provider.listBloc.list,
          builder: (context, snapshot) =>
              Text(snapshot.hasData ? snapshot.data.title : '')),
      actions: <Widget>[
        IconButton(
          icon: Theme(
            data: Theme.of(context)
                .copyWith(iconTheme: IconThemeData(color: Colors.white)),
            child: Icon(
              Icons.more_vert,
            ),
          ),
          tooltip: '清单选项',
          onPressed: () => _menu(context),
        )
      ],
    );

    var drawer = Drawer(
      child: StreamBuilder<List<ListModel>>(
        stream: provider.listBloc.retrieveListsStream,
        initialData: [provider.listBloc.list],
        builder: (context, listsSnapshot) {
          final lists = listsSnapshot.data.map((list) {
            return ListTile(
              title: Text(list.title),
              trailing: StreamBuilder<List>(
                  stream: provider.taskBloc.retrieveTasksStream,
                  initialData: [],
                  builder: (context, tasksSnapshot) {
                    return Text(tasksSnapshot.data
                        .where((task) => task.listId == list.id)
                        .where((task) => _completedTaskVisible || !task.status)
                        .length
                        .toString());
                  }),
              onTap: () {
                Navigator.pop(context);
                provider.listBloc.retrieveListSink.add(list);
              },
            );
          });
          return ListView(
            children: List.from(lists)
              ..add(Divider(
                indent: 16.0,
              ))
              ..add(ListTile(
                leading: Icon(Icons.add),
                title: Text('添加清单'),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return StandardInput(
                          hintText: '添加清单',
                          save: (title) {
                            provider.listBloc.createListSink
                                .add(ListModel(title: title));
                          });
                    },
                  );
                },
              )),
          );
        },
      ),
    );

    var body = StreamBuilder<ListModel>(
        stream: provider.listBloc.retrieveListStream,
        initialData: provider.listBloc.list,
        builder: (context, listSnapshot) => StreamBuilder<List>(
            stream: provider.taskBloc.retrieveTasksStream,
            initialData: [],
            builder: (context, tasksSnapshot) => ListView(
                  children: ListTile.divideTiles(
                      context: context,
                      tiles: tasksSnapshot.data
                          .where((task) =>
                              task.listId ==
                              (listSnapshot.hasData
                                  ? listSnapshot.data.id
                                  : ''))
                          .where(
                              (task) => _completedTaskVisible || !task.status)
                          .map((task) => StreamBuilder<List>(
                              stream: provider.stepBloc.retrieveStepsStream,
                              initialData: [],
                              builder: (context, stepsSnapshot) {
                                final steps = stepsSnapshot.data
                                    .where((step) => step.taskId == task.id);
                                final completedSteps =
                                    steps.where((step) => step.status);
                                return ListTile(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 4.0),
                                  leading: IconButton(
                                      icon: task.status
                                          ? Icon(Icons.radio_button_checked)
                                          : Icon(Icons.radio_button_unchecked),
                                      onPressed: () {
                                        provider.taskBloc.updateTaskSink.add(
                                            TaskModel(
                                                id: task.id,
                                                listId: task.listId,
                                                title: task.title,
                                                createTime: task.createTime,
                                                status: !task.status,
                                                remark: task.remark,
                                                endTime: task.endTime));
                                      }),
                                  title: Text(
                                    '${task.title}',
                                    style: TextStyle(
                                        decoration: task.status
                                            ? TextDecoration.lineThrough
                                            : null),
                                  ),
                                  subtitle: steps.length != 0
                                      ? Text(
                                          '${completedSteps.length}/${steps.length}')
                                      : null,
                                  onTap: () {
                                    provider.taskBloc.retrieveTaskSink
                                        .add(task);
                                    Navigator.pushNamed(context, '/task');
                                  },
                                );
                              }))).toList(),
                )));

    var floatingActionButton = StreamBuilder<ListModel>(
      stream: provider.listBloc.retrieveListStream,
      initialData: provider.listBloc.list,
      builder: (context, snapshot) {
        return FloatingActionButton(
            child: Icon(Icons.add),
            tooltip: '添加任务',
            onPressed: () {
              return showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return StandardInput(
                        hintText: '添加任务',
                        save: (title) {
                          provider.taskBloc.createTaskSink.add(TaskModel(
                              listId: snapshot.data.id,
                              title: title,
                              createTime:
                                  DateTime.now().millisecondsSinceEpoch));
                        });
                  });
            });
      },
    );

    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
