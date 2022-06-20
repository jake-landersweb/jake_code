import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../client/root.dart';
import '../global.dart';
import 'package:provider/provider.dart';

class RoomList extends StatefulWidget {
  const RoomList({Key? key}) : super(key: key);

  @override
  _RoomListState createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  @override
  Widget build(BuildContext context) {
    RoomModel rmodel = Provider.of<RoomModel>(context);
    return Scaffold(
      backgroundColor: backgroundColor(context),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 50),
            child: Column(
              children: [
                for (var i in rmodel.rooms)
                  Column(
                    children: [
                      _roomCell(context, rmodel, i),
                      const SizedBox(height: 16),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roomCell(BuildContext context, RoomModel rmodel, Room room) {
    return CupertinoButton(
      onPressed: () {
        //
      },
      padding: EdgeInsets.zero,
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: randomColor(room.roomId),
        ),
        child: Center(
          child: Text(
            room.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
