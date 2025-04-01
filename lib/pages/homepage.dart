import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  bool isLoading = false;
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode(); // Add a FocusNode

  @override
  void initState() {
    super.initState();
    getPermission();
    searchController.addListener(filterContacts);
  }

  @override
  void dispose() {
    searchController.dispose();
    _searchFocus.dispose(); // Dispose the FocusNode
    super.dispose();
  }

  Future<void> getPermission() async {
    if (await Permission.contacts.request().isGranted) {
      await fetchContacts();
    }
  }

  Future<void> fetchContacts() async {
    if (isLoading) return;
    setState(() => isLoading = true);
    final permissionGranted = await FlutterContacts.requestPermission();
    if (permissionGranted) {
      final fetchedContacts =
          await FlutterContacts.getContacts(withProperties: true);
      fetchedContacts.sort((a, b) => a.displayName.compareTo(b.displayName));
      setState(() {
        contacts = fetchedContacts;
        filteredContacts = List.from(contacts);
      });
    }
    setState(() => isLoading = false);
  }

  void filterContacts() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredContacts = contacts.where((contact) {
        final nameMatch = contact.displayName.toLowerCase().contains(query);
        final phoneMatch = contact.phones.isNotEmpty &&
            contact.phones[0].number.toLowerCase().contains(query);
        return nameMatch || phoneMatch;
      }).toList();
    });
  }

  void callContact(String number) {
    final Uri uri = Uri(scheme: 'tel', path: number);
    launchUrl(uri);
  }

  void showContactBottomSheet(Contact contact) {
    Get.bottomSheet(
      Container(
        height: Get.height * 1 / 2,
        width: Get.width,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'contact_avatar_${contact.id}',
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[850],
                child: Text(
                  contact.displayName.isNotEmpty
                      ? contact.displayName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              contact.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (contact.phones.isNotEmpty)
              ...contact.phones.map(
                (phone) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.blueAccent),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              phone.number,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text(
                              "Mobile | India",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.call, color: Colors.greenAccent),
                        onPressed: () => callContact(phone.number),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: RefreshIndicator(
        onRefresh: fetchContacts,
        color: Colors.white,
        backgroundColor: Colors.grey[700],
        strokeWidth: 1.2,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              title: const Text('Contacts',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              backgroundColor: Colors.grey[900],
              floating: true,
              snap: true,
              pinned: false,
              elevation: 0,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: searchController,
                  focusNode: _searchFocus, // Assign the FocusNode
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search contacts',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              searchController.clear();
                              _searchFocus.unfocus(); // Unfocus the text field
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[850],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
            ),
            isLoading
                ? SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[800]!,
                          highlightColor: Colors.grey[700]!,
                          child: Container(
                            height: 70,
                            decoration: BoxDecoration(
                                color: Colors.grey[850],
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      childCount: 7,
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final contact = filteredContacts[index];
                        return ListTile(
                          onTap: () => showContactBottomSheet(contact),
                          title: Text(contact.displayName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500)),
                          subtitle: contact.phones.isNotEmpty
                              ? Text(contact.phones[0].number,
                                  style: TextStyle(color: Colors.grey[400]))
                              : null,
                          leading: Hero(
                            tag: 'contact_avatar_${contact.id}',
                            child: CircleAvatar(
                              backgroundColor: Colors.grey[800],
                              child: Text(contact.displayName[0].toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.phone, color: Colors.green),
                            onPressed: () => callContact(
                                contact.phones.isNotEmpty
                                    ? contact.phones[0].number
                                    : ''),
                          ),
                        );
                      },
                      childCount: filteredContacts.length,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
