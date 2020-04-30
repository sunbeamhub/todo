import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import '../models/list_model.dart';
import '../models/step_model.dart';
import '../models/task_model.dart';
import '../provider.dart';
import '../widgets/standard_input.dart';

class TaskScreen extends StatelessWidget {
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
                  StreamBuilder<TaskModel>(
                    stream: provider.taskBloc.retrieveTaskStream,
                    initialData: null,
                    builder: (context, snapshot) {
                      return ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('重命名任务'),
                        onTap: () {
                          Navigator.pop(context);
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return StandardInput(
                                  hintText: '重命名任务',
                                  initialValue: snapshot.data.title,
                                  save: (title) {
                                    provider.taskBloc.updateTaskSink.add(
                                        TaskModel(
                                            id: snapshot.data.id,
                                            listId: snapshot.data.listId,
                                            title: title,
                                            createTime:
                                                snapshot.data.createTime,
                                            status: snapshot.data.status,
                                            remark: snapshot.data.remark,
                                            endTime: snapshot.data.endTime));
                                  });
                            },
                          );
                        },
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('删除任务'),
                    onTap: () {
                      Navigator.pop(context);
                      _delete(context);
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
          return StreamBuilder<TaskModel>(
            stream: provider.taskBloc.retrieveTaskStream,
            initialData: provider.taskBloc.task,
            builder: (context, snapshot) {
              return AlertDialog(
                title: Text('删除任务？'),
                content: Text(
                    '"${snapshot.hasData ? snapshot.data.title : ''}"将被永久删除'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('取消'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  FlatButton(
                    child: Text('确认'),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      provider.taskBloc.deleteTaskSink.add(snapshot.data.id);
                    },
                  )
                ],
              );
            },
          );
        });
  }

  _addEndDate(context, {@required TaskModel task}) {
    final provider = Provider.of(context);

    showDatePicker(
            locale: Locale('zh'),
            context: context,
            initialDate: task.endTime != null
                ? DateTime.fromMillisecondsSinceEpoch(task.endTime)
                : DateTime.now(),
            firstDate: DateTime.now().subtract(Duration(days: 1)),
            lastDate: DateTime(DateTime.now().year + 1))
        .then((dateTime) {
      if (dateTime != null) {
        provider.taskBloc.updateTaskSink.add(TaskModel(
            id: task.id,
            listId: task.listId,
            title: task.title,
            createTime: task.createTime,
            status: task.status,
            remark: task.remark,
            endTime: dateTime.millisecondsSinceEpoch));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of(context);

    var appBar = AppBar(
      title: StreamBuilder<ListModel>(
          stream: provider.listBloc.retrieveListStream,
          initialData: provider.listBloc.list,
          builder: (context, snapshot) {
            return Text(snapshot.hasData ? snapshot.data.title : '');
          }),
      centerTitle: false,
      actions: <Widget>[
        IconButton(
          icon: Theme(
            data: Theme.of(context)
                .copyWith(iconTheme: IconThemeData(color: Colors.white)),
            child: Icon(
              Icons.more_vert,
            ),
          ),
          tooltip: '任务选项',
          onPressed: () => _menu(context),
        )
      ],
    );

    var body = StreamBuilder<TaskModel>(
      stream: provider.taskBloc.retrieveTaskStream,
      initialData: provider.taskBloc.task,
      builder: (context, taskSnapshot) {
        return ListView(
          children: <Widget>[
            ListTile(
              title: Text(
                taskSnapshot.data.title ?? '',
                style: TextStyle(
                    decoration: taskSnapshot.hasData && taskSnapshot.data.status
                        ? TextDecoration.lineThrough
                        : null,
                    fontSize: 30.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Icon(
                      Icons.sort,
                      color: Theme.of(context).hintColor,
                    ),
                    margin: EdgeInsets.only(top: 12.0, right: 16.0),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        decoration: InputDecoration(
                            hintText: '添加详细信息', border: InputBorder.none),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.done,
                        controller: TextEditingController(
                            text: taskSnapshot.data.remark),
                        onSubmitted: (remark) {
                          provider.taskBloc.updateTaskSink.add(TaskModel(
                              id: taskSnapshot.data.id,
                              listId: taskSnapshot.data.listId,
                              title: taskSnapshot.data.title,
                              createTime: taskSnapshot.data.createTime,
                              status: taskSnapshot.data.status,
                              remark: remark,
                              endTime: taskSnapshot.data.endTime));
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.event_available),
              title: GestureDetector(
                child: Text(taskSnapshot.data.endTime != null
                    ? DateFormat.yMd().format(
                        DateTime.fromMillisecondsSinceEpoch(
                            taskSnapshot.data.endTime))
                    : '添加截止日期'),
                onTap: () => _addEndDate(context, task: taskSnapshot.data),
              ),
              trailing: taskSnapshot.data.endTime != null
                  ? IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: () {
                        provider.taskBloc.updateTaskSink.add(TaskModel(
                            id: taskSnapshot.data.id,
                            listId: taskSnapshot.data.listId,
                            title: taskSnapshot.data.title,
                            createTime: taskSnapshot.data.createTime,
                            status: taskSnapshot.data.status,
                            remark: taskSnapshot.data.remark,
                            endTime: null));
                      })
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Icon(
                      Icons.subdirectory_arrow_right,
                      color: Theme.of(context).hintColor,
                    ),
                    margin: EdgeInsets.only(top: 12.0, right: 16.0),
                  ),
                  Expanded(
                    child: StreamBuilder<List>(
                        stream: provider.stepBloc.retrieveStepsStream,
                        initialData: [],
                        builder: (context, stepSnapshot) {
                          final steps = stepSnapshot.data
                              .where((step) =>
                                  step.taskId ==
                                  (taskSnapshot.hasData
                                      ? taskSnapshot.data.id
                                      : ''))
                              .map((step) => Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          IconButton(
                                            icon: step.status
                                                ? Icon(
                                                    Icons.radio_button_checked,
                                                    color: Theme.of(context)
                                                        .hintColor,
                                                  )
                                                : Icon(
                                                    Icons
                                                        .radio_button_unchecked,
                                                    color: Theme.of(context)
                                                        .hintColor,
                                                  ),
                                            onPressed: () {
                                              provider.stepBloc.updateStepSink
                                                  .add(StepModel(
                                                      id: step.id,
                                                      taskId: step.taskId,
                                                      title: step.title,
                                                      createTime:
                                                          step.createTime,
                                                      status: !step.status));
                                            },
                                          ),
                                          Container(
                                            width: 200,
                                            child: TextField(
                                              decoration: InputDecoration(
                                                  hintText: '编辑子任务',
                                                  border: InputBorder.none),
                                              maxLines: null,
                                              keyboardType:
                                                  TextInputType.multiline,
                                              textInputAction:
                                                  TextInputAction.done,
                                              controller: TextEditingController(
                                                  text: step.title),
                                              onSubmitted: (title) {
                                                provider.stepBloc.updateStepSink
                                                    .add(StepModel(
                                                        id: step.id,
                                                        taskId: step.taskId,
                                                        title: title,
                                                        createTime:
                                                            step.createTime,
                                                        status: step.status));
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.cancel,
                                          color: Theme.of(context).hintColor,
                                        ),
                                        onPressed: () {
                                          provider.stepBloc.deleteStepSink
                                              .add(step.id);
                                        },
                                      )
                                    ],
                                  ));

                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.of(steps)
                                ..add(Container(
                                  margin: EdgeInsets.all(16.0),
                                  child: GestureDetector(
                                    child: Text(
                                      '添加子任务',
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                    onTap: () {
                                      provider.stepBloc.createStepSink.add(
                                          StepModel(
                                              taskId: taskSnapshot.data.id,
                                              createTime: DateTime.now()
                                                  .millisecondsSinceEpoch));
                                    },
                                  ),
                                )));
                        }),
                  )
                ],
              ),
            )
          ],
        );
      },
    );

    return Scaffold(appBar: appBar, body: body);
  }
}
