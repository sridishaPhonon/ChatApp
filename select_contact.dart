import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';

class AnotherScreen extends StatelessWidget {
  final List<Contact> selectedContacts;

  const AnotherScreen({super.key, required this.selectedContacts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selected Contacts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: selectedContacts.length,
              itemBuilder: (context, index) {
                final contact = selectedContacts[index];
                return ListTile(
                  leading: Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 7,
                          color: Colors.white.withOpacity(0.1),
                          offset: const Offset(-3, -3),
                        ),
                        BoxShadow(
                          blurRadius: 7,
                          color: Colors.black.withOpacity(0.7),
                          offset: const Offset(3, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xff262626),
                    ),
                    child: Text(
                      contact.displayName != null && contact.displayName!.isNotEmpty
                          ? contact.displayName![0].toUpperCase()
                          : '',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.primaries[
                            contact.hashCode % Colors.primaries.length],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(contact.displayName ?? ''),
                  subtitle: Text(contact.phones != null && contact.phones!.isNotEmpty
                      ? contact.phones!.first.value ?? ''
                      : ''),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
