import 'package:chat_app2/models/chat_user.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 2,
          title: const Text('Profile Screen'),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_outlined)),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            
          },
          child: const Icon(Icons.add_box_outlined),
        ),
        body: const Center(child: CircleAvatar())
  );
  
  }
}