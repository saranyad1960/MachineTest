import 'package:flutter/material.dart';

import 'main.dart';


//Task 5
class ProfilePageRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int userId = args['userId'];
    return MaterialApp(
      title: 'Flutter Tasks',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text('Flutter Tasks'),
        ),
        body: ProfileInfo(userId: userId),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => MyApp(),
      '/user': (context) => ProfilePageRoute(),
    },
    onGenerateRoute: (settings) {
      if (settings.name == '/user') {
        final Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (context) => ProfilePageRoute());
      }
      return null;
    },
  ));
}
