import 'package:chat_app/views/root.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'client/root.dart';

void main() {
  runApp(
    ChangeNotifierProvider<RoomModel>(
      create: (_) => RoomModel("1"),
      // we use `builder` to obtain a new `BuildContext` that has access to the provider
      builder: (context, child) {
        return const MyApp();
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const RoomList(),
    );
  }
}
