
import 'dart:developer';

import 'package:chat_app/helpers/navigation_helpers.dart';
import 'package:chat_app/provider/home_provider.dart';
import 'package:chat_app/screens/message/group/get_started.dart';
import 'package:chat_app/screens/message/group/group_messages.dart';
import 'package:chat_app/screens/message/personal/my_chats.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool login = false;

  check(context)async{
           final vm = Provider.of<HomeProvider>(context,listen: false);
             SharedPreferences prefs = await SharedPreferences.getInstance();
                  var name = prefs.getString('is_logged_in');
                  log(name!);
         login  = await  vm.isUserLoggedIn();
         log(login.toString());
         if(name!=null){
          pushAndReplace(context, GroupMessage(name: name));
         }else{
          pushAndReplace(context, const HomePage());
         }
  }
   @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    

  }
  DateTime? currentBackPressTime;
  @override
  Widget build(BuildContext context) {
    check(context);
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
          currentBackPressTime = now;
          Fluttertoast.showToast(
              msg: "Press back again to exit",
              backgroundColor: Colors.black,
              textColor: Colors.white);
          return false;
        }
        return true;
      },
      child: Scaffold(
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
      ),
    );
  }
}
