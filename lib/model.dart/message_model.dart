import 'dart:convert';

class Message {
  final String message;
final String sender;
final String image;
final int sentAt;
  Message({
    required this.message,
    required this.sender,
    required this.image,
    required this.sentAt,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'message': message});
    result.addAll({'sender': sender});
    result.addAll({'sentAt': sentAt});
    result.addAll({'image':image});
  
    return result;
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      message: map['message'] ?? '',
      sender: map['sender'] ?? '',
      sentAt: map['sentAt']??0, 
      image: map['image']??'',
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) => Message.fromMap(json.decode(source));
}
