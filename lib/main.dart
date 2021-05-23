import 'package:flutter/material.dart';
import 'package:mqtt_exam/models/mqtt_model.dart';
import 'package:mqtt_exam/widgets/input_widget.dart';
import 'package:provider/provider.dart';
import 'screens/screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InputVisibility()),
        ChangeNotifierProvider(create: (_) => MqttModel()),
      ],
      child: MaterialApp(
        title: 'Flutter MQTT Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginScreen(title: 'Flutter MQTT Exam'),
      ),
    );
  }
}
