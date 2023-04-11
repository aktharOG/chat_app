import 'dart:developer';

import 'package:chat_app/model.dart/message_model.dart';
import 'package:chat_app/provider/home_provider.dart';
import 'package:chat_app/provider/image_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class GroupMessage extends StatefulWidget {
  final String name;
  const GroupMessage({super.key, required this.name});

  @override
  State<GroupMessage> createState() => _MessageDetailsState();
}

class _MessageDetailsState extends State<GroupMessage> {
  late HomeProvider provider;
  TextEditingController message = TextEditingController();
  late IO.Socket _socket;
  int? ind;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    peer();

    provider = Provider.of<HomeProvider>(context, listen: false);
    provider.load();
  }

  peer() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var token = preferences.getString("token");
    //
    //http://192.168.29.28:3000
    _socket = IO.io(
        "https://my-chat-app-1slx.onrender.com",
        IO.OptionBuilder().setTransports(['websocket']).setQuery(
            {'username': widget.name, 'token': token}).build());
    connetSocket();
    provider.setUserLoggedIn(true, widget.name);
     WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  sendMessage() async {
    final vm = Provider.of<STImageProvider>(context, listen: false);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var token = preferences.getString("token");
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
    log("sending....");
    _socket.emit('message', {
      'sender': widget.name,
      'message': message.text.trim(),
      'token': token,
      'image': vm.url
    });
    vm.url = '';
    message.clear();
    FocusManager.instance.primaryFocus!.unfocus();
  }

  connetSocket() {
    _socket.onConnect((data) => log('connection established'));
    _socket.onConnectError((data) => log("Connection Error $data"));
    _socket.onDisconnect((data) => log('socket io disconnected'));
    _socket.on('message', (data) {
      final vm = Provider.of<HomeProvider>(context, listen: false);
      vm.addNewMessage(Message.fromMap(data));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _socket.close();
    _socket.clearListeners();

    super.dispose();
  }

  DateTime? currentBackPressTime;

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<STImageProvider>(context, listen: true);
    final home = Provider.of<HomeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime!) >
                const Duration(seconds: 2)) {
          currentBackPressTime = now;
          Fluttertoast.showToast(
              msg: "Press back again to exit",
              backgroundColor: Colors.black,
              textColor: Colors.white);
          return false;
        }
        return true;
      },
      child: GestureDetector(
        onTap: (){
          home.cancelOption();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            iconTheme: const IconThemeData(),
            leading: InkWell(
                onTap: () {
                  //  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back_ios)),
            elevation: 0,
            backgroundColor: Colors.white,
            // centerTitle: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(color: Colors.black),
                ),
                const Text(
                  "Ui/Ux designer",
                  style: TextStyle(color: Colors.grey),
                )
              ],
            ),
            actions: const [
              Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.more_vert))
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    Consumer<HomeProvider>(
                      builder: (_, provider, __) => ListView.separated(
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final message = provider.messages[index];
                          //Map data = provider.message[index];
                          //  log(data['message'] +'akthar');
      
                          return Wrap(
                            alignment: message.sender == widget.name
                                ? WrapAlignment.end
                                : WrapAlignment.start,
                            children: [
                              InkWell(
                                // onTapCancel: () {
                                //   home.showOptions();
                                // },
                                onLongPress: () {
                                  ind = index;
                                  home.showOptions();
                                },
                                child: Card(
                                  color: message.sender == widget.name
                                      ? Theme.of(context).primaryColorLight
                                      : Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          message.sender == widget.name
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          message.sender,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: message.sender == widget.name
                                                ? Colors.black
                                                : Colors.red,
                                          ),
                                        ),
                                        Text(message.message),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (message.image != '')
                                InstaImageViewer(
                                  child: Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 2,color: message.sender==widget.name?Theme.of(context).primaryColorLight:Colors.red),
                                      borderRadius: BorderRadius.circular(15)
                                    ),
                                    child: ClipRRect(
                                      
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image(
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                        //fit: BoxFit.cover,
                                        image: Image.network(
                                          message.image,
                                        ).image,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                        separatorBuilder: (_, index) => const SizedBox(
                          height: 5,
                        ),
                        itemCount: provider.messages.length,
                      ),
                    ),
                  ],
                ),
              ),
              if (provider.showDeleteOptions)
                Positioned(
                  bottom: 10,
                  left: MediaQuery.of(context).size.width / 2,
                  child: InkWell(
                      onTap: () {
                        home.deleteMessage(provider.messages[ind!]);
                        home.showOptions();
                      },
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      )),
                )
                
            ],
            
          ),
          bottomNavigationBar: BottomAppBar(
            child: Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: message,
                          decoration: const InputDecoration(
                            hintText: 'Type your message here...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      vm.isloading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ))
                          : IconButton(
                              onPressed: () {
                                final vm = Provider.of<STImageProvider>(context,
                                    listen: false);
                                vm.pickImages().then((value) {
                                  vm.uploadImageToCloud(context);
                                });
                              },
                              icon: const Icon(Icons.camera)),
                      IconButton(
                        onPressed: () {
                          if (message.text.trim().isNotEmpty) {
                            sendMessage();
                          }
                        },
                        icon: const Icon(Icons.send),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
