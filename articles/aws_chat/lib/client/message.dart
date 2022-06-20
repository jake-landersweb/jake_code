class Message {
  late String roomId;
  late String messageId;
  late String message;
  late String user;
  late String created;

  Message({
    required this.roomId,
    required this.messageId,
    required this.message,
    required this.user,
    required this.created,
  });

  Message.empty() {
    roomId = "";
    messageId = "";
    message = "";
    user = "";
    created = "";
  }

  Message.fromJson(dynamic json) {
    roomId = json['roomId'];
    messageId = json['messageId'];
    message = json['message'];
    user = json['user'];
    created = json['created'];
  }

  Map<String, dynamic> toMap() {
    return {
      "roomId": roomId,
      "messageId": messageId,
      "message": message,
      "user": user,
      "created": created,
    };
  }
}
