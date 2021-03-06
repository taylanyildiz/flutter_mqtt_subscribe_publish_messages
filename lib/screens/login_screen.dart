import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_exam/models/mqtt_model.dart';
import 'package:mqtt_exam/services/mqtt_service.dart';
import 'package:mqtt_exam/widgets/widget.dart';
import 'package:provider/provider.dart';
import 'screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({
    Key? key,
    this.title,
  }) : super(key: key);
  final String? title;
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  void _inputInitialized() {
    _formKeyHost = GlobalKey<FormState>();
    _formKeyUser = GlobalKey<FormState>();
    for (var i = 0; i < 5; i++) {
      _nodes.add(FocusNode());
      _textControllers.add(TextEditingController());
    }
  }

  @override
  void initState() {
    super.initState();
    _scaleController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        curve: Curves.elasticOut,
        parent: _scaleController,
      ),
    );
    _pageController = PageController();
    _inputInitialized();
    _model = MqttModel();
  }

  late PageController _pageController;

  late AnimationController _scaleController;

  late Animation<double> _scaleAnimation;

  late MqttModel _model;

  final _nodes = <FocusNode>[];

  final _textControllers = <TextEditingController>[];

  late GlobalKey<FormState> _formKeyHost;

  late GlobalKey<FormState> _formKeyUser;

  final _inputTypes = <TextInputType>[
    TextInputType.number,
    TextInputType.number,
    TextInputType.text,
    TextInputType.name,
    TextInputType.visiblePassword,
  ];

  int currentPage = 0;

  int pageCount = 2;

  bool haveUser = false;

  bool _visible = false;

  double _connection = -150.0;

  late MQTTService _mqttService;

  final _hints = <String>['Host', 'Port', 'Topic', 'User Name', 'Password'];

  Widget _inputText(BuildContext context, int index) {
    if (index == 0) {
      return InputWidget(
        exp:
            "The Message Queuing Telemetry Transport is a lightweight, publish-subscribe network protocol that transports messages between devices. The protocol usually runs over TCP/IP; however, any network protocol that provides ordered, lossless, bi-directional connections can support MQTT.",
        formKey: _formKeyHost,
        textControllers: [
          _textControllers[0],
          _textControllers[1],
          _textControllers[2]
        ],
        nodes: [_nodes[0], _nodes[1], _nodes[2]],
        inputTypes: [_inputTypes[0], _inputTypes[1], _inputTypes[2]],
        labels: [_hints[0], _hints[1], _hints[2]],
      );
    }
    if (pageCount > 2) {
      return index == 1
          ? InputWidget(
              exp: "Entry Server User Name and Password",
              formKey: _formKeyUser,
              textControllers: [_textControllers[3], _textControllers[4]],
              nodes: [_nodes[3], _nodes[4]],
              inputTypes: [_inputTypes[3], _inputTypes[4]],
              labels: [_hints[3], _hints[4]],
            )
          : MessageScreen();
    } else {
      return MessageScreen(service: _mqttService);
    }
  }

  late String _host;
  late String _port;
  late String _topic;
  late String _username;
  late String _password;

  void _nextPage() {
    if (currentPage == 0) {
      bool checkInput = _formKeyHost.currentState!.validate();
      _host = _textControllers[0].text;
      _port = _textControllers[1].text;
      _topic = _textControllers[2].text;
      if (_host.isNotEmpty && _port.isEmpty) {
        _nodes[1].requestFocus();
      } else if (_host.isNotEmpty && _port.isNotEmpty && _topic.isEmpty) {
        _nodes[2].requestFocus();
      }
      if (checkInput) {
        pageCount > 2
            ? _pageController.animateToPage(
                1,
                duration: Duration(milliseconds: 200),
                curve: Curves.linear,
              )
            : _connectionMqtt(_host, int.parse(_port), _topic);
      }
    } else if (pageCount > 2 && currentPage == 1) {
      bool checkInput = _formKeyUser.currentState!.validate();
      _username = _textControllers[3].text;
      _password = _textControllers[4].text;
      if (_username.isNotEmpty && _password.isEmpty) {
        _nodes[4].requestFocus();
      } else {
        _nodes[3].requestFocus();
      }
      if (checkInput) {
        _connectionMqtt(_host, int.parse(_port), _topic,
            username: _username, password: _password);
      }
    }
  }

  void _connectionMqtt(String host, int port, String topic,
      {String? username, String? password}) async {
    if (username != null && password != null) {
      _mqttService = MQTTService(
        model: _model,
        host: host,
        port: port,
        topic: topic,
        userName: username,
        passWord: password,
      );
    } else {
      _mqttService = MQTTService(
        host: host,
        port: port,
        topic: topic,
        model: _model,
      );
    }
    setState(() => _visible = true);
    final isConnect = await _mqttService.initializeMQTT();
    if (isConnect) {
      if (pageCount > 2) {
        await Future.delayed(Duration(seconds: 1), () {
          setState(() => _visible = false);
          _scaleController.forward();
        });
        await Future.delayed(
            Duration(milliseconds: 700), () => _scaleController.reset());
        _pageController.jumpToPage(2);
      } else {
        await Future.delayed(Duration(seconds: 1), () {
          setState(() => _visible = false);
          _scaleController.forward();
        });
        await Future.delayed(
            Duration(milliseconds: 700), () => _scaleController.reset());
        _pageController.jumpToPage(1);
      }
    } else {
      await Future.delayed(Duration(milliseconds: 300), () => _visible = false);
      setState(() {
        _connection = 0.0;
      });

      await Future.delayed(
          Duration(seconds: 4), () => setState(() => _connection = -150.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ChangeNotifierProvider(
      create: (_) => _model,
      child: ListenableProvider.value(
        value: _pageController,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            title: Consumer<PageController>(
              builder: (context, page, child) {
                double value = 0;
                if (page.position.hasContentDimensions) {
                  value = page.page!;
                }
                return Text(
                  pageCount <= 2
                      ? currentPage != 1
                          ? '${widget.title}'
                          : 'Messages'
                      : currentPage != 2
                          ? '${widget.title}'
                          : 'Messages',
                );
              },
            ),
            centerTitle: true,
            actions: [
              Consumer<PageController>(
                builder: (context, page, child) {
                  double value = 0;
                  if (page.position.hasContentDimensions) {
                    value = page.page!;
                  }
                  return Opacity(
                    opacity: pageCount > 2
                        ? value > 1
                            ? value - 1
                            : 0
                        : value > 0
                            ? value
                            : 0,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: 5.0 *
                            (pageCount > 2
                                ? value > 1
                                    ? value
                                    : 0.0
                                : value > 0
                                    ? 2 * value
                                    : 0.0),
                      ),
                      child: IgnorePointer(
                        ignoring: pageCount > 2 ? value != 2 : value != 1,
                        child: child,
                      ),
                    ),
                  );
                },
                child: IconButton(
                  onPressed: () async {
                    await _mqttService.disconnectionMQTT();
                    _pageController.jumpToPage(0);
                  },
                  icon: Icon(Icons.logout),
                ),
              ),
            ],
            leading: Consumer<PageController>(
              builder: (context, page, child) {
                double value = 0;
                if (page.position.hasContentDimensions) {
                  value = page.page!;
                }
                return Opacity(
                  opacity: pageCount <= 2
                      ? currentPage != 1
                          ? value
                          : 0.0
                      : currentPage != 2 && value <= 1
                          ? value
                          : 0.0,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 10.0 * (value <= 1 ? value : 1.0)),
                    child: IgnorePointer(
                      ignoring: value == 0,
                      child: IconButton(
                        onPressed: () => _pageController.animateToPage(
                          --currentPage,
                          duration: Duration(milliseconds: 400),
                          curve: Curves.linear,
                        ),
                        icon: Icon(Icons.arrow_back_ios),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          body: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                itemCount: pageCount,
                onPageChanged: (page) => currentPage = page,
                itemBuilder: (context, index) {
                  index == 1
                      ? _nodes[3].requestFocus()
                      : _nodes[0].requestFocus();
                  return _inputText(context, index);
                },
              ),
              CheckUserNameandPassword(
                checkColor: Colors.green,
                onPressed: (check) {
                  if (check) {
                    pageCount = 3;
                  } else {
                    pageCount = 2;
                  }
                  setState(() {});
                },
              ),
              AnimatedPositioned(
                right: _connection,
                bottom: size.height / 6,
                duration: Duration(milliseconds: 400),
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      topLeft: Radius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'Connection failed',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.0,
                    ),
                  ),
                ),
              ),
              Positioned(
                  bottom: 150.0,
                  left: 0.0,
                  right: 0.0,
                  child: Center(
                      child: Stack(
                    children: [
                      AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) => Transform(
                          transform: Matrix4.identity()
                            ..scale(_scaleAnimation.value),
                          child: child,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _visible,
                        child: CircularProgressIndicator(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ))),
              Consumer<PageController>(builder: (context, page, child) {
                double value = 0;
                if (page.position.hasContentDimensions) {
                  value = page.page!;
                }
                return Positioned(
                  bottom: pageCount > 2
                      ? currentPage == 2
                          ? (20 * (2 - value))
                          : 20.0
                      : currentPage == 1
                          ? (20 * (1 - value))
                          : 20.0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    ignoring:
                        pageCount > 2 ? currentPage == 2 : currentPage == 1,
                    child: Opacity(
                      opacity: pageCount > 2
                          ? currentPage == 2
                              ? (2 - value)
                              : 1.0
                          : currentPage == 1
                              ? (1 - value)
                              : 1.0,
                      child: Center(
                        child: SizedBox(
                          width: size.width * .8,
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            onPressed: () => _nextPage(),
                            child: Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 20.0,
                              ),
                            ),
                            color: Colors.blue,
                            textColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
