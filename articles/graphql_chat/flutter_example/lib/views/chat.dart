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
          if (message.user == cmodel.name)
            const Spacer()
          else
            Container(
              height: double.infinity,
              width: 7,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(5)),
                color: randomColor(message.user),
              ),
            ),
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width / 1.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.horizontal(
                left: message.user == cmodel.name
                    ? const Radius.circular(25)
                    : const Radius.circular(0),
                right: message.user == cmodel.name
                    ? const Radius.circular(0)
                    : const Radius.circular(25),
              ),
              color: cellColor(context),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(message.user == cmodel.name ? 16 : 8,
                  10, message.user == cmodel.name ? 8 : 16, 10),
              child: Column(
                crossAxisAlignment: message.user == cmodel.name
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.user,
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
          if (message.user == cmodel.name)
            Container(
              height: double.infinity,
              width: 7,
              decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.horizontal(right: Radius.circular(5)),
                  color: randomColor(message.user)),
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
