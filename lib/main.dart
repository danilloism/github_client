import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'github_login.dart';

void main() async {
  if (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia || kIsWeb) {
    throw Exception(
        'Only desktop platforms have build support for this application.');
  }

  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'GitHub Client'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return GithubLoginWidget(builder: (context, httpClient) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: const Center(
          child: Text('You are logged in to GitHub!'),
        ),
      );
    });
  }
}
