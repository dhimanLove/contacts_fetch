import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class Testing extends StatefulWidget {
  const Testing({super.key});

  @override
  State<Testing> createState() => _TestingState();
}

class _TestingState extends State<Testing> {
  List <Contact> contacts=[];
  @override
  void initState() {
    super.initState();
    getpermission();
  }
  void getpermission() async
  {
    if (await Permission.contacts.isGranted)
    {
      contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withGroups: true,
      );
      setState(() {
        getpermission();
      });
    }

    else
      {
        await Permission.contacts.request();
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Testing'),
        centerTitle: true,
      ),
      body: contacts.isEmpty
        ?CircularProgressIndicator()
          :Card(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(contacts[index].displayName),
                  subtitle: Text(contacts[index].phones.isNotEmpty
                      ? contacts[index].phones.first.number
                      : 'No Number'),

                );
              },
            ),
      )
    );
  }
}

