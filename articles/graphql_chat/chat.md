# create api

appsync from console

create API

- build from scratch

# add data sources

Schema -> Create Resources
- define new type
- Room

```graphql
type Room {
  id: String!
  roomId: String!
  title: String!
  created: String!
}
```

- pirmaryKey: id
- sortKey: roomId

Create

Create Resources
- define new type
- Message

```graphql
type Message {
  roomId: String!
  messageId: String!
  message: String!
  name: String!
  created: String!
}
```

- primaryKey: roomId
- sortKey: messageId

Create

# edit resolvers

## list rooms

Resolvers, scroll down to list rooms, need to convert to a query

```json
{
  "version": "2017-02-28",
  "operation": "Query",
  "query" : {
    "expression": "id = :id",
      "expressionValues" : {
        ":id" : { "S" : "$context.arguments.id" },
      }
  },
  "limit": $util.defaultIfNull($ctx.args.limit, 20),
  "nextToken": $util.toJson($util.defaultIfNullOrEmpty($ctx.args.nextToken, null)),
  "scanIndexForward": true
}
```

## list messages

```json
{
  "version": "2017-02-28",
  "operation": "Query",
  "query" : {
    "expression": "roomId = :roomId",
      "expressionValues" : {
        ":roomId" : { "S" : "$context.arguments.roomId" },
      }
  },
  "limit": $util.defaultIfNull($ctx.args.limit, 20),
  "nextToken": $util.toJson($util.defaultIfNullOrEmpty($ctx.args.nextToken, null)),
  "scanIndexForward": false
}
```

scanIndexForward = false for searching in reverse order (newest messages first based on how we store them)

## create room

```json
{
  "version": "2017-02-28",
  "operation": "PutItem",
  
  #set( $body = {} )

  #set( $sortKey = "${util.time.nowEpochMilliSeconds()}${util.autoId()}")
  $!{body.put("id", $ctx.args.input.id)}
  $!{body.put("sortKey", $sortKey)}
  $!{body.put("title", $ctx.args.input.title)}
  $!{body.put("created", $util.time.nowISO8601())}
  
  "key": {
    "id": $util.dynamodb.toDynamoDBJson($ctx.args.input.id),
    "sortKey": $util.dynamodb.toDynamoDBJson($body.sortKey),
  },
  "attributeValues": $util.dynamodb.toMapValuesJson($body),
  "condition": {
    "expression": "attribute_not_exists(#id) AND attribute_not_exists(#sortKey)",
    "expressionNames": {
      "#id": "id",
      "#sortKey": "sortKey",
    },
  },
}
```

## create message

```json
{
  "version": "2017-02-28",
  "operation": "PutItem",
  
  #set( $body = {} )

  #set( $messageId = "${util.time.nowEpochMilliSeconds()}${util.autoId()}")
  $!{body.put("roomId", $ctx.args.input.roomId)}
  $!{body.put("messageId", $messageId)}
  $!{body.put("message", $ctx.args.input.message)}
  $!{body.put("name", $ctx.args.input.name)}
  $!{body.put("created", $util.time.nowISO8601())}
  
  "key": {
    "roomId": $util.dynamodb.toDynamoDBJson($ctx.args.input.roomId),
    "messageId": $util.dynamodb.toDynamoDBJson($body.messageId),
  },
  "attributeValues": $util.dynamodb.toMapValuesJson($body),
  "condition": {
    "expression": "attribute_not_exists(#roomId) AND attribute_not_exists(#messageId)",
    "expressionNames": {
      "#roomId": "roomId",
      "#messageId": "messageId",
    },
  },
}
```

# test out functions

# creat flutter project

get api id from api settings

```bash
flutter create chat_app

amplify init

amplify add codegen --apiId APIID
```

add two packages to flutter proj

```yaml
amplify_flutter: ^0.2.0
amplify_api: ^0.2.10
provider: ^6.0.2
```

need to change iOS version in xcode to 11.0 

## data files

```dart
class Room {
  late String id;
  late String sortKey;
  late String title;
  late String created;

  Room({
    required this.id,
    required this.sortKey,
    required this.title,
    required this.created,
  });

  Room.empty() {
    id = '';
    sortKey = "";
    title = "";
    created = "";
  }

  Room.fromJson(dynamic json) {
    id = json['id'];
    sortKey = json['sortKey'];
    title = json['title'];
    created = json['created'];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "sortKey": sortKey,
      "title": title,
      "created": created,
    };
  }
}
```

> room.dart

```dart
class Message {
  late String roomId;
  late String messageId;
  late String message;
  late String name;
  late String created;

  Message({
    required this.roomId,
    required this.messageId,
    required this.message,
    required this.name,
    required this.created,
  });

  Message.empty() {
    roomId = "";
    messageId = "";
    message = "";
    name = "";
    created = "";
  }

  Message.fromJson(dynamic json) {
    roomId = json['roomId'];
    messageId = json['messageId'];
    message = json['message'];
    name = json['name'];
    created = json['created'];
  }

  Map<String, dynamic> toMap() {
    return {
      "roomId": roomId,
      "messageId": messageId,
      "message": message,
      "name": name,
      "created": created,
    };
  }
}
```

> message.dart

## room model

```dart
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../amplifyconfiguration.dart' as config;
import 'root.dart';

class RoomModel extends ChangeNotifier {
  // all rooms
  List<Room> rooms = [];
  // next token
  String nextToken = "";
  // keep track of load
  bool isLoading = false;
  // check is there are more to grab
  bool hasMore = true;

  // static id
  late String id;

  // constructor
  RoomModel(this.id) {
    init();
  }

  Future<void> init() async {
    // set up amplify if it has not been configured
    if (!Amplify.isConfigured) {
      Amplify.addPlugin(AmplifyAPI());

      try {
        await Amplify.configure(config.amplifyconfig);
      } on AmplifyAlreadyConfiguredException {
        print(
            "Tried to reconfigure Amplify; this can occur when your app restarts on Android.");
      }
    }

    // get rooms
    await getRooms();
  }

  // get all rooms with an id
  Future<void> getRooms() async {
    try {
      if (hasMore) {
        print("Fetching rooms with id: $id");
        isLoading = true;
        notifyListeners();
        // set up query string
        const String qstring = r"""
          query ListRooms($id: String!, $limit: Int!, $nextToken: String!) {
            listRooms(id: $id, limit: $limit, nextToken: $nextToken) {
              items {
                created
                id
                sortKey
                title
              }
              nextToken
            }
          }
        """;

        // set up request
        var operation = Amplify.API.query(
          request: GraphQLRequest<String>(
            document: qstring,
            variables: {
              "id": id,
              "limit": 5,
              "nextToken": nextToken,
            },
          ),
        );

        // send the request
        var response = await operation.response;
        var data = response.data;

        print("Successfully fetched room list: $data");

        // convert response to json
        dynamic json = jsonDecode(data);

        // set the fields
        List<Room> items = [];
        for (var i in json['listRooms']['items']) {
          items.add(Room.fromJson(i));
        }
        // add to main list separately
        rooms.addAll(items);
        // if there is a next token set it
        if (json['listRooms']['nextToken'] == null) {
          hasMore = false;
        } else {
          nextToken = json['listRooms']['nextToken'];
        }
        isLoading = false;
        // update the view
        notifyListeners();
      }
    } catch (error) {
      print("There was an error getting rooms: $error");
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createRoom(String title) async {
    try {
      // configure body
      const String qstring = r"""
        mutation CreateRoom($id: String!, $title: String!) {
          createRoom(input: {id: $id, title: $title}) {
            created
            id
            sortKey
            title
          }
        }
      """;

      // create request
      var operation = Amplify.API.mutate(
        request: GraphQLRequest<String>(
          document: qstring,
          variables: {
            "id": id,
            "title": title,
          },
        ),
      );

      // send the request
      var response = await operation.response;
      var data = response.data;

      // convert string to json
      dynamic json = jsonDecode(data);
      print("Successfully created room: $json");
      // add to list
      rooms.add(Room.fromJson(json['createRoom']));
      notifyListeners();
    } catch (error) {
      print("There was an error creating room: $error");
    }
  }

  Future<void> reload() async {
    nextToken = "";
    hasMore = true;
    rooms = [];
    await getRooms();
  }
}
```

## global functions

```dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

Color cellColor(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.light
      ? Colors.white
      : const Color.fromRGBO(80, 80, 80, 1);
}

Color backgroundColor(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.light
      ? const Color.fromRGBO(240, 240, 250, 1)
      : const Color.fromRGBO(40, 40, 40, 1);
}

Color textColor(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.light
      ? const Color.fromRGBO(15, 15, 25, 1)
      : const Color.fromRGBO(240, 240, 250, 1);
}

Color randomColor(String seed) {
  // create number representation of string seed
  double num = 1;
  for (var i = 0; i < seed.length; i++) {
    try {
      num += seed.codeUnitAt(i) / 1.9;
    } catch (error) {
      // ignore invalid characters
    }
  }
  return Color((math.Random(num.toInt()).nextDouble() * 0xFFFFFF).toInt())
      .withOpacity(1.0);
}
```

## top bar

create a nice blurred top bar

```dart
import 'dart:ui';
import 'package:chat_app/global.dart';
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  const TopBar({
    Key? key,
    required this.title,
    this.leading,
    this.trailing,
  }) : super(key: key);
  final String title;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).padding.top + 40,
      width: double.infinity,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5,
            sigmaY: 5,
          ),
          child: Container(
            color: backgroundColor(context).withOpacity(0.5),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: leading,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: textColor(context),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: trailing,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

```

## room view

compose the room view

```dart
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
          color: randomColor(room.sortKey),
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
```

## create chat model

```dart
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../amplifyconfiguration.dart' as config;
import 'root.dart';

class ChatModel extends ChangeNotifier {
  // passed room
  late Room room;
  // passed name
  late String name;
  // list messages
  List<Message> messages = [];
  // next token if applicable
  String nextToken = "";
  // whether there are more messages to fetch
  bool hasMore = true;
  // load status
  bool isLoading = false;

  // for subscriptions
  GraphQLSubscriptionOperation<String>? operation;

  // constructor
  ChatModel(this.room, this.name) {
    init();
  }

  Future<void> init() async {
    // make sure amplify is set up
    if (!Amplify.isConfigured) {
      Amplify.addPlugin(AmplifyAPI());

      try {
        await Amplify.configure(config.amplifyconfig);
      } on AmplifyAlreadyConfiguredException {
        print(
            "Tried to reconfigure Amplify; this can occur when your app restarts on Android.");
      }
    }

    // get the most recent messages
    await getMessages();

    // set up the subscription
    subSetUp();
  }

  Future<void> getMessages() async {
    try {
      if (hasMore) {
        print("Fetching messages with id: ${room.sortKey}");
        isLoading = true;
        notifyListeners();
        // set up query string
        const String qstring = r"""
          query ListMessages($roomId: String!, $limit: Int!, $nextToken: String!) {
            listMessages(roomId: $roomId, nextToken: $nextToken, limit: $limit) {
              items {
                created
                message
                messageId
                name
                roomId
              }
              nextToken
            }
          }
        """;

        // set up request
        var operation = Amplify.API.query(
          request: GraphQLRequest<String>(
            document: qstring,
            variables: {
              "roomId": room.sortKey,
              "limit": 20,
              "nextToken": nextToken,
            },
          ),
        );

        // send the request
        var response = await operation.response;
        var data = response.data;

        print("Successfully fetched message list: $data");

        // convert response to json
        dynamic json = jsonDecode(data);

        // set the fields
        List<Message> items = [];
        for (var i in json['listMessages']['items']) {
          items.add(Message.fromJson(i));
        }
        // add to main list separately
        messages.addAll(items);
        // if there is a next token set it
        if (json['listMessages']['nextToken'] == null) {
          hasMore = false;
        } else {
          nextToken = json['listMessages']['nextToken'];
        }
        isLoading = false;
        // update the view
        notifyListeners();
      }
    } catch (error) {
      print("There was an error getting rooms: $error");
      isLoading = false;
      notifyListeners();
    }
  }

  void subSetUp() async {
    try {
      // compose query
      const qstring = r"""
        subscription OnCreateMessage($roomId: String!) {
          onCreateMessage(roomId: $roomId) {
            created
            message
            messageId
            name
            roomId
          }
        }
      """;

      // send operation
      operation = Amplify.API.subscribe(
        request: GraphQLRequest<String>(
          document: qstring,
          variables: {
            "roomId": room.sortKey,
          },
        ),
        onData: (event) {
          // when recieving message
          print("Subscription event data recieved: ${event.data}");
          dynamic json = jsonDecode(event.data);
          try {
            Message recievedMessage = Message.fromJson(json['onCreateMessage']);
            if (recievedMessage.name != name) {
              // add to message list if not sent from this sender
              messages.insert(0, recievedMessage);
              notifyListeners();
              print("updated view");
            } else {
              print("Recieved message successful, but sent from this device");
            }
          } catch (error) {
            print("There was an issue decoding the response: $error");
          }
        },
        onEstablished: () {
          print("Subscription established");
        },
        onError: (error) {
          print("Subscription failed with error: $error");
        },
        onDone: () {
          print("Subscription has been closed successfully");
        },
      );
    } catch (error) {
      print("There was an error setting up subscription: $error");
    }
  }

  Future<void> createMessage(String message) async {
    try {
      // compose the query
      const qstring = r"""
        mutation CreateMessage($message: String!, $name: String!, $roomId: String!) {
          createMessage(input: {message: $message, name: $name, roomId: $roomId}) {
            created
            message
            messageId
            name
            roomId
          }
        }
      """;

      // create the request
      var operation = Amplify.API.mutate(
        request: GraphQLRequest(
          document: qstring,
          variables: {
            "roomId": room.sortKey,
            "name": name,
            "message": message,
          },
        ),
      );

      // send the request
      var response = await operation.response;
      var data = response.data;
      dynamic json = jsonDecode(data);
      print("Successfully created message: $json");
      // add to beginning of list
      messages.insert(0, Message.fromJson(json['createMessage']));
      notifyListeners();
    } catch (error) {
      print("There was an issue creating the message: $error");
    }
  }

  // close all connections when class is disposed
  @override
  void dispose() {
    // close the connection
    if (operation != null) {
      operation!.cancel();
    }
    messages = [];
    super.dispose();
  }
}
```

## chat view

```dart
import 'package:chat_app/global.dart';
import 'package:chat_app/views/root.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';
import '../client/root.dart';
import 'package:provider/provider.dart';

class Chat extends StatefulWidget {
  const Chat({
    Key? key,
    required this.room,
  }) : super(key: key);
  final Room room;

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    _controller.text = "";
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatModel>(
      create: (_) => ChatModel(widget.room, "ryan"),
      // we use `builder` to obtain a new `BuildContext` that has access to the provider
      builder: (context, child) {
        return _body(context);
      },
    );
  }

  Widget _body(BuildContext context) {
    ChatModel cmodel = Provider.of<ChatModel>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor(context),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              // expanded list of messages to fill the view
              Expanded(
                child: _messageList(context, cmodel),
              ),
              // message text field below the messages
              _messageInput(context, cmodel),
              // for artificial safe area, prevents screen jitter
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Sprung.custom(damping: 36),
                width: double.infinity,
                height: MediaQuery.of(context).viewInsets.bottom == 0
                    ? MediaQuery.of(context).padding.bottom
                    : 0,
              ),
              // push view up to reveal keyboard
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Sprung.custom(damping: 36),
                width: double.infinity,
                height: MediaQuery.of(context).viewInsets.bottom == 0
                    ? 0
                    : (MediaQuery.of(context).viewInsets.bottom + 8),
              ),
            ],
          ),
          // top bar on top of entire view
          TopBar(title: widget.room.title, leading: _backButton(context))
        ],
      ),
    );
  }

  Widget _messageList(BuildContext context, ChatModel cmodel) {
    return ListView(
      shrinkWrap: true,
      reverse:
          true, // when list is reversed, all data is shown correctly. i.e lowest message is the most recent
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        // loop through all messages
        for (var message in cmodel.messages)
          Column(children: [
            _messageCell(context, cmodel, message),
            const SizedBox(height: 8),
          ]),
        // padding from top
        const SizedBox(height: 16),
        // for fetching more messages
        if (cmodel.hasMore)
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: () {
              cmodel.getMessages();
            },
            child: Container(
              decoration: BoxDecoration(
                color: cellColor(context).withOpacity(0.5),
                borderRadius: BorderRadius.circular(25),
              ),
              height: 50,
              width: MediaQuery.of(context).size.width / 3,
              child: Center(
                child: cmodel.isLoading
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
          ),

        // padding from app bar
        SizedBox(height: MediaQuery.of(context).padding.top + 40),
      ],
    );
  }

  Widget _messageCell(BuildContext context, ChatModel cmodel, Message message) {
    // intrinsic height for dynamic sized accent color side
    return IntrinsicHeight(
      child: Row(
        children: [
          if (message.name == cmodel.name)
            const Spacer()
          else
            Container(
              height: double.infinity,
              width: 7,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(5)),
                color: randomColor(message.name),
              ),
            ),
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width / 1.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.horizontal(
                left: message.name == cmodel.name
                    ? const Radius.circular(25)
                    : const Radius.circular(0),
                right: message.name == cmodel.name
                    ? const Radius.circular(0)
                    : const Radius.circular(25),
              ),
              color: cellColor(context),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(message.name == cmodel.name ? 16 : 8,
                  10, message.name == cmodel.name ? 8 : 16, 10),
              child: Column(
                crossAxisAlignment: message.name == cmodel.name
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                      color: textColor(context).withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.message,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                      color: textColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.name == cmodel.name)
            Container(
              height: double.infinity,
              width: 7,
              decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.horizontal(right: Radius.circular(5)),
                  color: randomColor(message.name)),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }

  Widget _messageInput(BuildContext context, ChatModel cmodel) {
    return Column(
      children: [
        Divider(
            height: 0.5,
            indent: 0,
            endIndent: 0,
            color: textColor(context).withOpacity(0.15)),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Container(
            decoration: BoxDecoration(
              color: cellColor(context),
              borderRadius: BorderRadius.circular(25),
            ),
            height: 50,
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // text field
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Theme(
                      // to remove the border on the field
                      data: Theme.of(context).copyWith(
                        colorScheme: ThemeData()
                            .colorScheme
                            .copyWith(primary: Colors.blue),
                        inputDecorationTheme: const InputDecorationTheme(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              style: BorderStyle.solid,
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                      child: TextFormField(
                        controller: _controller,
                        onChanged: (value) {
                          setState(() {});
                        },
                        style: TextStyle(
                          color: textColor(context),
                        ),
                        decoration: InputDecoration(
                          hintText: "Type your message ...",

                          hintStyle: TextStyle(
                              color: textColor(context).withOpacity(0.5)),
                          // to remove the underline on the field
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Opacity(
                  opacity: _controller.text.isEmpty ? 0.5 : 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: CupertinoButton(
                      color: Colors.transparent,
                      disabledColor: Colors.transparent,
                      minSize: 0,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        if (_controller.text.isEmpty) {
                          print("text input was empty");
                        } else {
                          // send the message
                          _createMessage(cmodel);
                        }
                      },
                      child: Container(
                        height: 44,
                        width: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        child: const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _createMessage(ChatModel cmodel) async {
    await cmodel.createMessage(_controller.text);
    setState(() {
      _controller.clear();
    });
  }

  Widget _backButton(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 0,
      child: const Icon(Icons.arrow_back_ios, size: 20),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}
```

done

