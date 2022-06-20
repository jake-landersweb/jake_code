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
        print("Fetching messages with id: ${room.roomId}");
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
                user
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
              "roomId": room.roomId,
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
            user
            roomId
          }
        }
      """;

      // send operation
      operation = Amplify.API.subscribe(
        request: GraphQLRequest<String>(
          document: qstring,
          variables: {
            "roomId": room.roomId,
          },
        ),
        onData: (event) {
          // when recieving message
          print("Subscription event data recieved: ${event.data}");
          dynamic json = jsonDecode(event.data);
          try {
            Message recievedMessage = Message.fromJson(json['onCreateMessage']);
            if (recievedMessage.user != name) {
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
        mutation CreateMessage($message: String!, $user: String!, $roomId: String!) {
          createMessage(input: {message: $message, user: $user, roomId: $roomId}) {
            created
            message
            messageId
            user
            roomId
          }
        }
      """;

      // create the request
      var operation = Amplify.API.mutate(
        request: GraphQLRequest(
          document: qstring,
          variables: {
            "roomId": room.roomId,
            "user": name,
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
