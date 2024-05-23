import 'package:chat_app2/api/apis.dart';
import 'package:chat_app2/helpers/my_date_util.dart';
import 'package:chat_app2/models/message.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final List<Message> messages;

  ChatScreen({Key? key, required this.messages}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    // Sort messages by the 'sent' timestamp in ascending order
    widget.messages.sort((a, b) => a.sent.compareTo(b.sent));

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: ListView.builder(
        reverse: true, // Reverse the ListView to show latest messages at the bottom
        itemCount: widget.messages.length,
        itemBuilder: (context, index) {
          return MessageCard(message: widget.messages[index]);
        },
      ),
    );
  }
}

class MessageCard extends StatefulWidget {
  final Message message;

  MessageCard({Key? key, required this.message}) : super(key: key);

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user!.uid == widget.message.fromId
        ? _blueMessage()
        : _greenMessage();
  }

  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8, left: 80),
            decoration: BoxDecoration(
              color: Colors.blue[900],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.message.msg,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 90),
                    child: Text(
                      MyDateUtil.getFormattedTime(
                          context: context, time: widget.message.sent),
                      style: const TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8, right: 80),
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    widget.message.msg,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  if (widget.message.read.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 90),
                    child: Text(
                      MyDateUtil.getFormattedTime(
                          context: context, time: widget.message.sent),
                      style: const TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
