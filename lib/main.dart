import 'package:contacts_fetch/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contacts',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
    );
  }
}
///  void callContact(String number) {
//     final Uri uri = Uri(scheme: 'tel', path: number);
//     launchUrl(uri);
//   }