import 'dart:developer';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_exam/models/messages_model.dart';
import 'package:mqtt_exam/models/mqtt_model.dart';

/// Service class
class MQTTService {
  /// Constructor for client and subscribe or publisher.
  MQTTService({
    this.host,
    this.port,
    this.topic,
    this.userName,
    this.passWord,
    this.model,
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

  /// Listenin message model.
  final MqttModel? model;

  late MqttServerClient _client;

  /// [MQTTService] initialize
  Future<bool> initializeMQTT() async {
    _client = MqttServerClient(host!, 'taylanyildz')
      ..logging(on: false)
      ..port = port!
      ..keepAlivePeriod = 20
      ..onDisconnected = onDisconnected
      ..onSubscribed = onSubscribed
      ..onConnected = onConnected;

    final mqttMsg = MqttConnectMessage()
        .withClientIdentifier('taylanyildz')
        .withWillTopic('withWillTopic')
        .withWillMessage('willMessage')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    log('Connecting....');
    _client.connectionMessage = mqttMsg;
    return await connectionMQTT();
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
    print('Connected');
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
        print('message id : ${recMess.variableHeader?.messageIdentifier}');
        print('message : $message');
        int id = recMess.variableHeader!.messageIdentifier!;
        model!.addMessage(Messages(id: id, message: message));
      });
    } catch (e) {
      log(e.toString());
    }
  }

  void publish(String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client.publishMessage(topic!, MqttQos.atLeastOnce, builder.payload!);
    builder.clear();
  }
}
