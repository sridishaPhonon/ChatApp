import 'package:chat_app2/api/apis.dart';
import 'package:chat_app2/helpers/my_date_util.dart';
import 'package:chat_app2/models/chat_user.dart';
import 'package:chat_app2/models/message.dart';
import 'package:chat_app2/screens/chat_screen.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ChatScreen(
              user: widget.user,
            ),
          ));
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list = data
                ?.map((e) => Message.fromJson(e.data() as Map<String, dynamic>))
                .toList() ?? [];
            if (list.isNotEmpty) _message = list[0];
            return ListTile(
              leading: const CircleAvatar(),
              title: Text(widget.user.name),
              subtitle: Text(
                _message != null ? _message!.msg : widget.user.about,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: _message == null
                  ? null
                  : _message!.read.isEmpty &&
                          _message!.fromId != APIs.user!.uid
                      ? Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        )
                      : SizedBox(
                          width: 60, // Adjust the width as needed
                          child: Text(
                            MyDateUtil.getLastMessageTime(
                              context: context,
                              time: _message!.sent,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
            );
          },
        ),
      ),
    );
  }
}
