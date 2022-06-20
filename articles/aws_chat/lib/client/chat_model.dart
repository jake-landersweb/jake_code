import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../amplifyconfiguration.dart' as config;
import 'root.dart';

class ChatModel extends ChangeNotifier {
  late Room room;
  late String name;
  List<Message> messages = [];
  String nextToken = "";
  bool hasMore = true;
  bool isLoading = false;

  GraphQLSubscriptionOperation<String>? opertation;

  ChatModel(this.room, this.name) {
    init();
  }

  Future<void> init() async {
    //
  }

  Future<void> getMessages() async {
    try {
      //

      if (hasMore) {
        isLoading = true;
        notifyListeners();
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

        var response = await operation.response;
        var data = response.data;

        dynamic json = jsonDecode(data);

        List<Message> items = [];
        for (var i in json['listMessages']['items']) {
          items.add(Message.fromJson(i));
        }
        messages.addAll(items);

        if (json['listMessages']['nextToken'] == null) {
          hasMore = false;
        } else {
          nextToken = json['listMessages']['nextToken'];
        }
        isLoading = false;
        notifyListeners();
      }
    } catch (error) {
      print("There was an error: $error");
    }
  }
}
