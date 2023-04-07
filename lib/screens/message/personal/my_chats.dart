import 'package:flutter/material.dart';

class MyChats extends StatelessWidget {
  const MyChats({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("My Chats",style: TextStyle(color: Colors.black),),
      ),
    );
  }
}