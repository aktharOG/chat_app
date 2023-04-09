
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model.dart/message_model.dart';
import 'package:http/http.dart' as http;


class HomeProvider extends ChangeNotifier {
   List<Message> _messages = [];

    load()async{
      _messages =await loadModels();
      notifyListeners();
    }

  List<Message> get messages => _messages;

  addNewMessage(Message message)async {
    _messages.add(message);
   await saveModels(_messages);
    notifyListeners();
  }

  Future<void> saveModels(List<Message> models) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> modelsJson = models.map((model) => json.encode(model.toJson())).toList();
  await prefs.setStringList('models', modelsJson);
}
Future<List<Message>> loadModels() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> modelsJson = prefs.getStringList('models') ?? [];
  List<Message> models = modelsJson.map((modelJson) => Message.fromJson(json.decode(modelJson))).toList();
  return models;
}

 //List<dynamic> message= [];
   
//     fetchMessages()async{
//       try{
//         log("api callin...");
//        final response =await http.get(Uri.parse("http://192.168.1.2:3000/check")); 
//        var  res = jsonDecode(jsonEncode(response.body));
          
//           log(res.toString());
//         //  message = res;
//          log(message.length.toString());
//        //  List<dynamic> messageList = res['array_agg'];
           

//     //      final messages = List<Message>.from(res)
//     // map((res) => Message.fromJson(jsonDecode(res)));
//     //      notifyListeners();

//     //     List<Message> messages = (jsonDecode(response.body) as List)
//     // .map((messageJson) => Message.fromJson(jsonDecode(messageJson)))
//     // .toList();
//     //   log(messages.toString());
//     // Map data = jsonDecode(response.body);
//     // List<String> array = List<String>.from(data['array_agg']);
//     //      log(array.toString());
// //     List<Message> messages = [];
// // Map jsonList = jsonDecode(res)['array_agg'];
// // for (var json in jsonList) {
// //   if (json is String) {
// //     // Ignore empty strings
// //     if (json.trim().isEmpty) continue;

// //     messages.add(Message.fromJson(jsonDecode(json)));
// //   }
// // }
       

//       }catch(e){
//         log(e.toString());
//       }
//     }

  

//     Future<void> saveList(List<String> list) async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.setStringList('myList', list);
// }

// // Load a list of strings
// Future<List<String>> loadList() async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getStringList('myList') ?? [];
// }


       
}