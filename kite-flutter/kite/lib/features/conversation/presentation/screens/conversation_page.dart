import 'package:flutter/material.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() {
    return _ConversationState();
  }
}

class _ConversationState extends State<ConversationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return Text("test");
        },
      ),
    );
  }
}
