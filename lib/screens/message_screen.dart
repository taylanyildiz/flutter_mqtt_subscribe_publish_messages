import 'package:flutter/material.dart';
import 'package:mqtt_exam/models/mqtt_model.dart';
import 'package:mqtt_exam/services/mqtt_service.dart';
import 'package:provider/provider.dart';

class MessageScreen extends StatefulWidget {
  final MQTTService? service;

  const MessageScreen({
    Key? key,
    this.service,
  }) : super(key: key);
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late TextEditingController _message;
  @override
  void initState() {
    super.initState();
    _message = TextEditingController();
  }

  void _sendMessage() {
    if (_message.text.isNotEmpty) {
      widget.service!.publish(_message.text);
      _message.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MqttModel>(
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: Colors.blue,
          body: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  child: ListView.builder(
                    itemCount: model.message.length,
                    padding: EdgeInsets.only(top: 20.0),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 25.0, vertical: 15.0),
                        decoration: BoxDecoration(
                          color: Colors.pink[200],
                          borderRadius: model.message[index].id != 0
                              ? BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  bottomLeft: Radius.circular(20.0),
                                )
                              : BorderRadius.only(
                                  topRight: Radius.circular(20.0),
                                  bottomRight: Radius.circular(20.0),
                                ),
                        ),
                        margin: model.message[index].id != 0
                            ? EdgeInsets.only(top: 8.0, bottom: 8.0, left: 80.0)
                            : EdgeInsets.only(
                                top: 8.0, bottom: 8.0, right: 80.0),
                        child: Text(
                          model.message[index].message,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                height: 70.0,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _message,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Send message...',
                          hintStyle: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        color: Colors.white,
                        onPressed: () => _sendMessage(),
                        icon: Icon(Icons.send),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
