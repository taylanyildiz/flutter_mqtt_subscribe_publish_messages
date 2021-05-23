import 'package:flutter/material.dart';
import 'package:mqtt_exam/models/messages_model.dart';

class MqttModel with ChangeNotifier {
  var _message = <Messages>[];

  List<Messages> get message => _message;

  void addMessage(Messages message) {
    _message.add(message);
    notifyListeners();
  }
}
