import 'package:flutter/widgets.dart';

import 'blocs/list_bloc.dart';
import 'blocs/step_bloc.dart';
import 'blocs/task_bloc.dart';

class Provider extends InheritedWidget {
  final listBloc = ListBloc();
  final taskBloc = TaskBloc();
  final stepBloc = StepBloc();

  Provider({Key key, Widget child}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static Provider of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(Provider) as Provider;
  }
}
