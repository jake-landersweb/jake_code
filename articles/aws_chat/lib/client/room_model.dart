import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../amplifyconfiguration.dart' as config;
import 'root.dart';

class RoomModel extends ChangeNotifier {
  List<Room> rooms = [];
  String nextToken = "";
  bool isLoading = false;
  bool hasMore = true;

  late String id;

  RoomModel(this.id) {
    init();
  }

  Future<void> init() async {
    if (!Amplify.isConfigured) {
      Amplify.addPlugin(AmplifyAPI());

      try {
        await Amplify.configure(config.amplifyconfig);
      } on AmplifyAlreadyConfiguredException {
        print("Amplify is already configured!!");
      }
    }

    await getRooms();
  }

  Future<void> getRooms() async {
    try {
      if (hasMore) {
        isLoading = true;
        notifyListeners();

        const String qstring = r"""
          query ListRooms($id: String!, $limit: Int!, $nextToken: String!) {
            listRooms(id: $id, limit: $limit, nextToken: $nextToken) {
              items {
                created
                id
                title
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
              "id": id,
              "limit": 5,
              "nextToken": nextToken,
            },
          ),
        );

        var response = await operation.response;
        var data = response.data;

        print("Successfully fetched rooms: $data");

        dynamic json = jsonDecode(data);

        List<Room> items = [];
        for (var i in json['listRooms']['items']) {
          items.add(Room.fromJson(i));
        }
        rooms.addAll(items);
        if (json['listRooms']['nextToken'] == null) {
          hasMore = false;
        } else {
          nextToken = json['listRooms']['nextToken'];
        }
        isLoading = false;
        notifyListeners();
      }
    } catch (error) {
      print("There was an error: $error");
      isLoading = false;
      notifyListeners();
    }
  }
}
