import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'provider.dart';
import 'screens/list_screen.dart';
import 'screens/task_screen.dart';
import 'theme.dart';

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      child: MaterialApp(
        title: 'todo',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', 'US'),
          const Locale('zh', 'CH'),
        ],
        theme: lightThemeData,
        initialRoute: '/',
        routes: {
          '/': (context) => ListScreen(),
          '/task': (context) => TaskScreen()
        },
      ),
    );
  }
}
