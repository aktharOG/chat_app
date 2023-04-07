import 'dart:developer';

import 'package:chat_app/model.dart/message_model.dart';
import 'package:chat_app/provider/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


class GroupMessage extends StatefulWidget { 
  final String name;
  const GroupMessage({super.key,required this.name});

  @override
  State<GroupMessage> createState() => _MessageDetailsState();
}

class _MessageDetailsState extends State<GroupMessage> {
  late HomeProvider provider;
         TextEditingController message = TextEditingController();
 late IO.Socket  _socket;
        
            final ScrollController _scrollController = ScrollController();

         @override
  void initState() {
    // TODO: implement initState
    super.initState();
  _socket =  IO.io("https://my-chat-app-1slx.onrender.com",IO.OptionBuilder().setTransports(['websocket']).setQuery({'username':widget.name}).build());
  connetSocket();
  provider = Provider.of<HomeProvider>(context,listen: false);
  }

  sendMessage(){
     _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds:1 ),
        curve: Curves.easeInOut,
      );
            log("sending....");
            _socket.emit('message',{
              'sender':widget.name,
            'message': message.text.trim()
            });
            message.clear();
           FocusManager.instance.primaryFocus!.unfocus();
          
          }

       connetSocket(){
        _socket.onConnect((data) => log('connection established'));
        _socket.onConnectError((data) => log("Connection Error ${data}"));
        _socket.onDisconnect((data) => log('socket io disconnected'));
        _socket.on('message', (data) {
          final vm = Provider.of<HomeProvider>(context,listen: false);
          vm.addNewMessage(Message.fromMap(data));
          _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds:1 ),
        curve: Curves.easeInOut,
      );

        });
               }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:  AppBar(
              iconTheme: const IconThemeData(),
              leading: InkWell(
                  onTap: () {
                    Navigator.pop(context);
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
                const Text("Ui/Ux designer",style: TextStyle(color: Colors.grey),)
                ],
              ),
              actions: const [
                Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.more_vert)
                )
              ],
            ),
      body: SingleChildScrollView(
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
                  return Wrap(
                    alignment: message.sender == widget.name
                        ? WrapAlignment.end
                        : WrapAlignment.start,
                    children: [
                      Card(
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
                              Text(message.sender,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold,color: message.sender == widget.name
                            ? Colors.black
                            : Colors.red,),),
                              Text(message.message),
                              Text(
                                DateFormat('hh:mm a').format(message.sentAt),
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                        ),
                      )
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
      bottomNavigationBar: BottomAppBar(child: Padding(
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
      ),),
    );
  }
}