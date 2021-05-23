import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_exam/models/messages_model.dart';
import 'package:mqtt_exam/models/mqtt_model.dart';

/// Service class
class MQTTService with ChangeNotifier {
  /// Constructor for client and subscribe or publisher.
  MQTTService({
    this.host,
    this.port,
    this.topic,
    this.userName,
    this.passWord,
  });

  /// Connection server host adress.
  final String? host;

  /// Connection server host port
  final int? port;

  /// Server topic name
  final String? topic;

  /// If server you want client have secure
  /// you must entry username
  final String? userName;

  /// If server you want client have secure
  /// you must entry password
  final String? passWord;

  late MqttServerClient _client;

  /// [MQTTService] initialize
  Future<void> initializeMQTT() async {
    _client = MqttServerClient(host!, 'taylanyildiz')
      ..logging(on: false)
      ..port = port!
      ..keepAlivePeriod = 20
      ..onDisconnected = onDisconnected
      ..onSubscribed = onSubscribed
      ..onConnected = onConnected;

    final mqttMsg = MqttConnectMessage()
        .withClientIdentifier('clientIdentifier')
        .withWillTopic('willTopic')
        .withWillMessage('willMessage')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    log('Connecting....');
    _client.connectionMessage = mqttMsg;
  }

  /// Connection server
  Future<bool> connectionMQTT() async {
    try {
      await _client.connect(
        userName,
        passWord,
      );
      return true;
    } catch (e) {
      log('Connection failed ${e.toString()}');
      _client.disconnect();
      return false;
    }
  }

  /// Disconnection Server
  Future<void> disconnectionMQTT() async {
    try {
      _client.disconnect();
    } catch (e) {
      log(e.toString());
    }
  }

  void onDisconnected() {
    print('disconnected');
  }

  void onSubscribed(String topic) {
    log(topic);
  }

  void onConnected() {
    print('onConnected');
    MqttModel().addMessage(Messages(id: 0, message: 'message'));
    listenServer();
  }

  /// MQTT listen server message[s]
  void listenServer() {
    try {
      _client.subscribe(topic!, MqttQos.atLeastOnce);
      _client.updates!.listen((dynamic t) {
        final MqttPublishMessage recMess = t[0].payload;
        final message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message!);
      });
    } catch (e) {
      log('listen message : ${e.toString()}');
    }
  }

  void publis(String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client.publishMessage(topic!, MqttQos.atLeastOnce, builder.payload!);
    builder.clear();
  }
}
