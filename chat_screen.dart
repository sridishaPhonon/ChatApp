import 'package:chat_app2/api/apis.dart';
import 'package:chat_app2/helpers/my_date_util.dart';
import 'package:chat_app2/models/chat_user.dart';
import 'package:chat_app2/models/message.dart';
import 'package:chat_app2/screens/contact_list.dart';
import 'package:chat_app2/screens/speech_to_text.dart';
import 'package:chat_app2/widgets/message_card.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  ChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: APIs.getAllMessages(widget.user),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    case ConnectionState.active:
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }
                      final data = snapshot.data?.docs;
                      _list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

                      if (_list.isNotEmpty) {
                        return ListView.builder(
                          reverse: true,
                          itemCount: _list.length,
                          itemBuilder: (context, index) {
                            return MessageCard(message: _list[index]);
                          },
                        );
                      } else {
                        return const Center(child: Text('Say Hi!'));
                      }
                  }
                },
              ),
            ),
            _chatInput(),
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {},
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final data = snapshot.data?.docs;
          final list = data?.map((e) => ChatUser.fromJson(e.data() as Map<String, dynamic>)).toList() ?? [];

          return Card(
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                const CircleAvatar(),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.isNotEmpty ? list[0].name : widget.user.name,
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      list.isNotEmpty
                          ? list[0].isOnline
                              ? 'Online'
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: list[0].lastActive,
                                )
                          : MyDateUtil.getLastActiveTime(
                              context: context,
                              lastActive: widget.user.lastActive,
                            ),
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          IconButton(onPressed: () {
             Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SpeechToText()),
        );
          }, icon: const Icon(Icons.mic)),
          Expanded(
            child: TextField(
              controller: _textController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(hintText: 'Type something here... '),
            ),
          ),
          IconButton(
            onPressed: () async {
              await _checkAndRequestPermissions();
            },
            icon: const Icon(Icons.contact_page),
          ),
          IconButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                if (_list.isEmpty) {
                  APIs.sendFirstMessage(widget.user, _textController.text, Type.text);
                } else {
                  APIs.sendMessage(widget.user, _textController.text, Type.text);
                }
                _textController.clear();
              }
            },
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Future<void> _checkAndRequestPermissions() async {
    if (await Permission.contacts.isGranted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MyContacts()),
      );
    } else {
      PermissionStatus status = await Permission.contacts.request();
      if (status.isGranted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyContacts()),
        );
      } else {
        // Handle the case where the permission is denied
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Contacts permission is required to access the contact list."),
          ),
        );
      }
    }
  }
}
