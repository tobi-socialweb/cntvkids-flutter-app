import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/common/constants.dart';

class InheritedTopNavigationBar extends InheritedWidget {
  final int Function() getSelectedIndex;

  InheritedTopNavigationBar({this.getSelectedIndex, child})
      : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;

  static InheritedTopNavigationBar of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedTopNavigationBar>();
}

/// Lays a top nav with a row of [NavigationBarButton]s.
class TopNavigationBar extends StatefulWidget {
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final List<NavigationBarButton> children;
  final int Function() getSelectedIndex;
  final EdgeInsets padding;
  final double defaultIconSizes;
  final double defaultTextScaleFactor;
  final void Function(int index) defaultOnPressed;
  final EdgeInsets defaultPadding;

  TopNavigationBar(
      {this.children = const [],
      this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
      this.crossAxisAlignment = CrossAxisAlignment.center,
      this.getSelectedIndex,
      this.defaultIconSizes = 10.0,
      this.defaultOnPressed = _defaultOnPressed,
      this.defaultTextScaleFactor = 1.0,
      this.defaultPadding = EdgeInsets.zero,
      this.padding = EdgeInsets.zero});

  @override
  _TopNavigationBarState createState() => _TopNavigationBarState();

  static void _defaultOnPressed(int index) {}
}

class _TopNavigationBarState extends State<TopNavigationBar> {
  /// Generate a new list of children to use default values if needed.
  List<NavigationBarButton> _children;

  @override
  void initState() {
    super.initState();
    _children = [];

    /// Will store the currently visited child.
    NavigationBarButton child;
    int index = widget.getSelectedIndex();
    int j = 0;

    /// Iterate through all children.
    for (int i = 0; i < widget.children.length; i++) {
      /// Get the current child.
      child = widget.children[i];

      /// Add newly created [NavigationBarButton] child.
      _children.add(NavigationBarButton(
        icon: child.icon,
        activeIcon: child.activeIcon,
        isPressed: child.hasIndex() ? child.index == index : j == index,
        text: child.text,
        realIndex: i,
        index: child.hasIndex() ? child.index : j,
        onPressed:
            child.hasOnPressed() ? child.onPressed : widget.defaultOnPressed,
        size: child.hasIconSize() ? child.size : widget.defaultIconSizes,
        textScaleFactor: child.hasTextScaleFactor()
            ? child.textScaleFactor
            : widget.defaultTextScaleFactor,
        padding: child.hasPadding() ? child.padding : widget.defaultPadding,
      ));

      /// If count should be reset, keep real count with [j].
      j += child.doesResetCount() ? -j : 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InheritedTopNavigationBar(
      getSelectedIndex: widget.getSelectedIndex,
      child: Padding(
        padding: widget.padding,
        child: Row(
          mainAxisAlignment: widget.mainAxisAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
          children: _children,
        ),
      ),
    );
  }
}

/// A single button for the [TopNavigationBar] widget.
class NavigationBarButton extends StatefulWidget {
  final AssetResource icon;
  final AssetResource activeIcon;
  final bool isPressed;
  final double size;
  final int index;
  final int realIndex;
  final void Function(int index) onPressed;
  final String text;
  final double textScaleFactor;
  final EdgeInsets padding;
  final bool resetCount;

  NavigationBarButton(
      {this.icon,
      this.activeIcon,
      this.isPressed,
      this.size,
      this.index,
      this.realIndex,
      this.onPressed,
      this.text,
      this.textScaleFactor,
      this.padding,
      this.resetCount = false});

  @override
  _NavigationBarButtonState createState() => _NavigationBarButtonState();

  bool hasIndex() {
    return this.index != null;
  }

  bool hasOnPressed() {
    return this.onPressed != null;
  }

  bool hasTextScaleFactor() {
    return this.textScaleFactor != null && this.textScaleFactor != 0.0;
  }

  bool hasPadding() {
    return this.padding != null;
  }

  bool hasIconSize() {
    return this.size != null && this.size != 0.0;
  }

  bool doesResetCount() {
    return this.resetCount;
  }
}

class _NavigationBarButtonState extends State<NavigationBarButton> {
  bool isPressed;

  @override
  void initState() {
    isPressed = widget.isPressed;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgButton(
          padding: widget.padding,
          size: widget.size,
          asset: (isPressed && widget.activeIcon != null)
              ? widget.activeIcon
              : widget.icon,
          onPressed: _onPressed,
        ),
        (widget.text != null && widget.text != "")
            ? Padding(
                padding: widget.padding,
                child: Text(
                  widget.text,
                  textScaleFactor: widget.textScaleFactor,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: FontAsset.fredoka_one,
                  ),
                ),
              )
            : Container()
      ],
    );
  }

  void _onPressed() {
    setState(() {
      isPressed = true;
    });
    widget.onPressed(widget.index);
  }

  @override
  void didChangeDependencies() {
    setState(() {
      isPressed = InheritedTopNavigationBar.of(context).getSelectedIndex() ==
          widget.index;
    });
    super.didChangeDependencies();
  }
}
