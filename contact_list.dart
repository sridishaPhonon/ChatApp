import 'dart:math';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class MyContacts extends StatefulWidget {
  const MyContacts({super.key});

  @override
  State<MyContacts> createState() => _MyContactsState();
}

class _MyContactsState extends State<MyContacts> {
  List<Contact> contacts = [];
  List<Contact> selectedContacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getContactPermission();
  }

  void getContactPermission() async {
    if (await Permission.contacts.isGranted) {
      fetchContacts();
    } else {
      var status = await Permission.contacts.request();
      if (status.isGranted) {
        fetchContacts();
      }
    }
  }

  void fetchContacts() async {
    contacts = (await ContactsService.getContacts()).toList();
    setState(() {
      isLoading = false;
    });
  }

  void toggleSelection(Contact contact) {
    setState(() {
      if (selectedContacts.contains(contact)) {
        selectedContacts.remove(contact);
      } else {
        selectedContacts.add(contact);
      }
    });
  }

  void shareToChat() {
    // Implement your sharing functionality here
    print("Sharing ${selectedContacts.length} contacts to chat");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Contacts"),
        backgroundColor: const Color.fromARGB(255, 229, 214, 254),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      String fullName = contacts[index].givenName ?? '';
                      if (contacts[index].familyName != null) {
                        fullName += ' ${contacts[index].familyName}';
                      }
                      bool isSelected = selectedContacts.contains(contacts[index]);
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: isSelected
                              ? Colors.green
                              : Colors.primaries[Random().nextInt(Colors.primaries.length)],
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white)
                              : Text(
                                  fullName.isNotEmpty ? fullName[0] : '',
                                  style: const TextStyle(
                                    fontSize: 21,
                                    color: Colors.white,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                        title: Text(
                          fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          contacts[index].phones?.isNotEmpty == true
                              ? contacts[index].phones![0].value ?? 'No phone number'
                              : 'No phone number',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        horizontalTitleGap: 12,
                        onTap: () => toggleSelection(contacts[index]),
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Selected Contacts:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: selectedContacts.length,
                    itemBuilder: (context, index) {
                      String fullName = selectedContacts[index].givenName ?? '';
                      if (selectedContacts[index].familyName != null) {
                        fullName += ' ${selectedContacts[index].familyName}';
                      }
                      return ListTile(
                        title: Text(fullName),
                        subtitle: Text(
                          selectedContacts[index].phones?.isNotEmpty == true
                              ? selectedContacts[index].phones![0].value ?? 'No phone number'
                              : 'No phone number',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: selectedContacts.isNotEmpty
          ? FloatingActionButton(
              onPressed: shareToChat,
              tooltip: 'Share to Chat',
              child: const Icon(Icons.share),
            )
          : null,
    );
  }
}
