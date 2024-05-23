import 'package:chat_app2/api/apis.dart';
import 'package:chat_app2/helpers/dialogs.dart';
import 'package:chat_app2/models/chat_user.dart';
import 'package:chat_app2/screens/profile_screen.dart';
import 'package:chat_app2/widgets/chat_user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<ChatUser> list = [];

  @override
  void initState() {
    APIs.getSelfInfo();
    super.initState();
    APIs.updateActiveStatus(true);
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (message.toString().contains('resume')) APIs.updateActiveStatus(true);
      if (message.toString().contains('pause')) APIs.updateActiveStatus(false);

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 2,
          title: const Text('Chat App'),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfileScreen(user: APIs.me)));
                },
                icon: const Icon(Icons.more_vert_outlined)),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // await APIs.auth.signOut();
            // await GoogleSignIn().signOut();
            _addChatUserDialog();
          },
          child: const Icon(Icons.add_box_outlined),
        ),
        body: StreamBuilder(
          stream: APIs.getMyUsersId(),
          builder: (context, snapshot) {
             switch (snapshot.connectionState) {
            case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );  
                    case ConnectionState.active:
                    case ConnectionState.done:
              return StreamBuilder(
                stream: APIs.getAllUsers(
                    snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );  
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;

                      list = data
                              ?.map((e) => ChatUser.fromJson(e.data()))
                              .toList() ??
                          [];
                      //   for(var i in data!){
                      //     log('Data: ${jsonEncode(i.data())}');
                      //     list.add(i.data()['name']);
                      // }
                      if (list.isNotEmpty) {
                        return ListView.builder(
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              // return Text('Name: ${list[index]}');
                              return ChatUserCard(user: list[index]);
                            });
                      } else {
                        return const Text('No connections found!');
                      }
                  }
                },
              );
            }
          },
        ));
  }

  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: const Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: Colors.black,
                    size: 28,
                  ),
                  Text('  Add User')
                ],
              ),

              //content
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email Id',
                    prefixIcon: const Icon(Icons.email, color: Colors.black),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.black, fontSize: 16))),

                //add button
                MaterialButton(
                    onPressed: () async {
                      //hide alert dialog
                      Navigator.pop(context);
                      if (email.isNotEmpty) {
                        await APIs.addChatUser(email).then((value) {
                          if (!value) {
                            Dialogs.showSnackBar(
                                context, 'User does not Exists!');
                          }
                        });
                      }
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ))
              ],
            ));
  }
}
