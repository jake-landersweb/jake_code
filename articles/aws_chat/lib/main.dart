import 'package:aws_chat/views/room_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'client/root.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => RoomModel("1"),
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

class Temp extends StatelessWidget {
  const Temp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RoomModel rmodel = Provider.of<RoomModel>(context);
    return Container(
      color: Colors.red,
      height: 300,
      width: 300,
    );
  }
}
