import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MenuDrawer extends StatefulWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final List<Widget> children;

  const MenuDrawer(
      {Key key,
      this.width,
      this.height,
      this.backgroundColor,
      this.children = const []})
      : super(key: key);

  @override
  _MenuDrawerState createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// Get size of the current context widget.
    final Size size = MediaQuery.of(context).size;

    return Container(
        height: widget.height ?? size.height,
        width: widget.width ?? 0.6 * size.width,
        color: widget.backgroundColor ?? Theme.of(context).accentColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widget.children,
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class MenuDrawerItem extends StatefulWidget {
  @override
  _MenuDrawerItemState createState() => _MenuDrawerItemState();
}

class _MenuDrawerItemState extends State<MenuDrawerItem> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
