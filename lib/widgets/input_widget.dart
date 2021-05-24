import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class InputVisibility with ChangeNotifier {
  bool _visibility = true;

  bool get visibility => _visibility;

  void changeVisibility() {
    _visibility = !_visibility;
    notifyListeners();
  }
}

class InputWidget extends StatelessWidget {
  InputWidget({
    Key? key,
    required this.formKey,
    required this.textControllers,
    required this.nodes,
    required this.inputTypes,
    required this.labels,
    required this.exp,
  }) : super(key: key);

  final GlobalKey<FormState> formKey;

  final List<TextEditingController> textControllers;

  final List<TextInputType> inputTypes;

  final List<String> labels;

  final List<FocusNode> nodes;

  final String exp;

  final content = <Widget>[];

  String? _validators(input) {
    if (input.isEmpty)
      return 'Please entry';
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    for (var i = 0; i < textControllers.length; i++) {
      content.add(
        Consumer<InputVisibility>(
          builder: (context, notifier, child) {
            return TextFormField(
                obscureText: inputTypes[i] == TextInputType.visiblePassword
                    ? notifier.visibility
                    : false,
                controller: textControllers[i],
                focusNode: nodes[i],
                autofocus: true,
                keyboardType: inputTypes[i],
                validator: _validators,
                decoration: InputDecoration(
                  labelText: labels[i],
                  labelStyle: TextStyle(
                    color: Colors.blue,
                    fontSize: 20.0,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  prefixIcon: Icon(
                    inputTypes[i] == TextInputType.visiblePassword
                        ? Icons.lock
                        : inputTypes[i] == TextInputType.number
                            ? Icons.confirmation_number
                            : inputTypes[i] == TextInputType.text
                                ? Icons.topic
                                : Icons.person,
                    color: Colors.blue,
                  ),
                  suffixIcon: inputTypes[i] == TextInputType.visiblePassword
                      ? IconButton(
                          onPressed: () => notifier.changeVisibility(),
                          icon: Icon(
                            notifier.visibility
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          color: Colors.red,
                        )
                      : SizedBox.shrink(),
                ));
          },
        ),
      );
      if (nodes.length > 1) {
        content.add(SizedBox(height: 20.0));
      }
    }
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exp,
            style: TextStyle(
              color: Colors.black,
              fontSize: 15.0,
            ),
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 40.0),
          Form(
            key: formKey,
            child: Column(
              children: content,
            ),
          ),
          SizedBox(height: 20.0),
          RichText(
            text: TextSpan(
              text: 'You need ',
              style: TextStyle(
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: '${labels[0]} Adress ',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: 'and ',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: '${labels[1]} Adress',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
