import 'package:chat_app/helpers/navigation_helpers.dart';
import 'package:chat_app/screens/message/group/get_started.dart';
import 'package:chat_app/screens/message/personal/my_chats.dart';
import 'package:flutter/material.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(onPressed: () {
                 push(context,const GetStarted());
              }, child: const Text("Group Chat")),
              const SizedBox(
                height: 30,
              ),
              OutlinedButton(onPressed: () {
                push(context,const MyChats());
              }, child: const Text("My Chats")),
            ],
          ),
        ),
      ),
    );
  }
}
