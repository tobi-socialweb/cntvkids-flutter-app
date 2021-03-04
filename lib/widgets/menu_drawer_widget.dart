import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MenuDrawer extends StatefulWidget {
  _MenuDrawerState createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  @override
  Widget build(BuildContext context) {
    /// Get size of the current context widget.
    final Size size = MediaQuery.of(context).size;

    return Container(
        height: size.height,
        width: 0.75 * size.width,
        color: Colors.orange,
        child: Expanded(child: Text("test")));
  }
}
