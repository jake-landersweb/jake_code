class Room {
  late String id;
  late String roomId;
  late String title;
  late String created;

  Room({
    required this.id,
    required this.roomId,
    required this.title,
    required this.created,
  });

  Room.empty() {
    id = '';
    roomId = "";
    title = "";
    created = "";
  }

  Room.fromJson(dynamic json) {
    id = json['id'];
    roomId = json['roomId'];
    title = json['title'];
    created = json['created'];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "roomId": roomId,
      "title": title,
      "created": created,
    };
  }
}
