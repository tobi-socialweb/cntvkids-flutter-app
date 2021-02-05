import 'package:cntvkids_app/r.g.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:r_dart_library/asset_svg.dart';

typedef AssetSvg AssetSvgCallback({double width, double height});
typedef void VoidIndexCallback(int index);

class NavIconButton extends StatefulWidget {
  final AssetSvgCallback icon;
  final AssetSvgCallback iconWhenPressed;
  final double iconSize;

  final String buttonText;

  final EdgeInsets padding;

  final double splashRadius;

  final VoidIndexCallback onPressed;

  final int buttonIndex;
  final int currentSelectedIndex;

  final bool isLogo;

  NavIconButton({
    @required this.icon,
    @required this.iconSize,
    @required this.buttonIndex,
    @required this.currentSelectedIndex,
    @required this.onPressed,
    this.padding = const EdgeInsets.all(0.0),
    this.isLogo = false,
    this.splashRadius = 0.01,
    this.iconWhenPressed,
    this.buttonText,
  });

  @override
  _NavIconButtonState createState() => _NavIconButtonState();
}

class _NavIconButtonState extends State<NavIconButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => widget.onPressed(widget.buttonIndex),
          icon: widget.currentSelectedIndex == widget.buttonIndex &&
                  !widget.isLogo
              ? SvgPicture.asset(
                  widget.iconWhenPressed(width: 0.0, height: 0.0).asset)
              : SvgPicture.asset(widget.icon(width: 0.0, height: 0.0).asset),
          iconSize: widget.iconSize,
          splashRadius: widget.splashRadius,
          padding: widget.padding,
          alignment: Alignment.centerLeft,
        ),
        widget.isLogo
            ? Container()
            : Padding(
                padding: EdgeInsets.only(bottom: 7.5),
                child: Text(widget.buttonText),
              )
      ],
    );
  }
}
