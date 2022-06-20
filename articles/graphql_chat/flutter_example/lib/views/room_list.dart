import 'package:chat_app/global.dart';
import 'package:chat_app/views/chat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../client/root.dart';
import 'root.dart';
import 'dart:io' show Platform;

class RoomList extends StatelessWidget {
  const RoomList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RoomModel rmodel = Provider.of<RoomModel>(context);
    return Scaffold(
      backgroundColor: backgroundColor(context),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // room list
          _roomList(context, rmodel),
          // header
          TopBar(
            title: "Room List",
            trailing: _createRoom(context, rmodel),
            leading: _reload(context, rmodel),
          ),
        ],
      ),
    );
  }

  Widget _roomList(BuildContext context, RoomModel rmodel) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // add padding to avoid top bar
        SizedBox(height: MediaQuery.of(context).padding.top + 40),
        // list through all rooms
        for (var room in rmodel.rooms)
          Column(children: [
            _roomCell(context, room),
            const SizedBox(height: 16),
          ]),
        const SizedBox(height: 16),
        if (rmodel.hasMore) _getMoreButton(context, rmodel),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _roomCell(BuildContext context, Room room) {
    return CupertinoButton(
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
      onPressed: () {
        // navigate to chat screen
        if (Platform.isIOS) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => Chat(room: room),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Chat(room: room),
            ),
          );
        }
      },
    );
  }

  Widget _getMoreButton(BuildContext context, RoomModel rmodel) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: Container(
        width: MediaQuery.of(context).size.width / 2.5,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: cellColor(context).withOpacity(0.5),
        ),
        child: Center(
          child: rmodel.isLoading
              ? const CircularProgressIndicator()
              : Text(
                  "Get More",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: textColor(context).withOpacity(0.5),
                  ),
                ),
        ),
      ),
      onPressed: () {
        // get more rooms, pagination handled in model
        rmodel.getRooms();
      },
    );
  }

  Widget _createRoom(BuildContext context, RoomModel rmodel) {
    return CupertinoButton(
      minSize: 0,
      padding: EdgeInsets.zero,
      child: const Icon(Icons.add),
      onPressed: () {
        // add a new room

        // if wanted, add a title text field for more customization and bind to title
        _createRoomFunc(rmodel);
      },
    );
  }

  Widget _reload(BuildContext context, RoomModel rmodel) {
    return CupertinoButton(
      minSize: 0,
      padding: EdgeInsets.zero,
      child: const Icon(Icons.refresh),
      onPressed: () {
        // refresh list
        _reloadFunc(rmodel);
      },
    );
  }

  Future<void> _createRoomFunc(RoomModel rmodel) async {
    await rmodel.createRoom("Room number: ${rmodel.rooms.length}");
  }

  Future<void> _reloadFunc(RoomModel rmodel) async {
    await rmodel.reload();
  }
}
