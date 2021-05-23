import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckUserNameandPassword extends StatefulWidget {
  CheckUserNameandPassword({
    Key? key,
    this.onPressed,
    this.checkColor,
  }) : super(key: key);

  final Function(bool)? onPressed;

  final Color? checkColor;

  @override
  _CheckUserNameandPasswordState createState() =>
      _CheckUserNameandPasswordState();
}

class _CheckUserNameandPasswordState extends State<CheckUserNameandPassword> {
  Color _defaultColor = Colors.white;

  bool _checkBox = false;

  void _check() {
    _checkBox = !_checkBox;
    widget.onPressed!.call(_checkBox);
    if (_checkBox)
      _defaultColor = widget.checkColor!;
    else
      _defaultColor = Colors.white;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double opacity = 1.0;
    return Consumer<PageController>(
      builder: (context, page, child) {
        if (page.position.hasContentDimensions) {
          opacity = 1 - (page.page! <= 1 ? page.page! : 1.0);
        }
        return Positioned(
          left: 20 * opacity,
          bottom: size.height / 3.7,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => opacity == 1 ? _check() : null,
        child: Row(
          children: [
            AnimatedContainer(
              padding: EdgeInsets.all(3.0),
              duration: Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _defaultColor,
                shape: BoxShape.circle,
                border: Border.all(
                  width: .5,
                  color: _checkBox ? _defaultColor : Colors.black,
                ),
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 15.0,
              ),
            ),
            SizedBox(width: 5.0),
            Text(
              'You have user name and password',
              style: TextStyle(
                color: Colors.black,
                fontSize: 13.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
