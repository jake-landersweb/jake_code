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
                title
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
