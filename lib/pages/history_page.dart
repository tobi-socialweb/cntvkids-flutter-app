import 'dart:async';

import 'package:cntvkids_app/pages/history/favorites_card_list.dart';
import 'package:cntvkids_app/pages/history/history_card_list.dart';

/// Menu pages
import 'package:cntvkids_app/pages/home/lists_card_list.dart';
import 'package:cntvkids_app/pages/home/series_card_list.dart';
import 'package:cntvkids_app/pages/home/featured_card_list.dart';
import 'package:cntvkids_app/pages/home/games_card_list.dart';
import 'package:cntvkids_app/pages/search_page.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/common/sound_controller.dart';
import 'package:cntvkids_app/widgets/menu_drawer_widget.dart';

/// Widget
import 'package:cntvkids_app/widgets/top_navigation_bar_widget.dart';

/// General plugins
import 'package:flutter/material.dart';
import 'package:cntvkids_app/common/constants.dart';

/// The first page to be shown when starting the app.
class HistoryPage extends StatefulWidget {
  const HistoryPage({
    Key key,
  }) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with WidgetsBindingObserver {
  /// toll bar settings
  final double length = 15.0;
  final double innerRadius = 5.0;
  final double outerRadius = 30.0;

  /// Currently selected index for navigation bar.
  int _selectedIndex = 0;

  /// All options from the navigation bar
  List<Widget> _widgetOptions;
  Widget _cardList;

  /// Volume controls variables
  Timer timer;

  @override
  void initState() {
    
    _widgetOptions = [
      HistoryCardList(
        leftMargin: innerRadius + outerRadius,
      ),
      FavoriteCardList(
        leftMargin: innerRadius + outerRadius,
      ),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// Get size of the current context widget.
    final Size size = MediaQuery.of(context).size;
    final double navHeight = NAVBAR_HEIGHT_PROP * size.height;

    _cardList = _widgetOptions.elementAt(_selectedIndex);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      drawerScrimColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// The colored curved blob in the background (white, yellow, etc.).
          BottomColoredBlob(
            size: size,
            currentSelectedIndex: _selectedIndex,
            colors: [
              Colors.white,
              Colors.cyan,
              Colors.yellow,
              Theme.of(context).accentColor,
              Colors.white,
              Colors.green,
              Colors.blueGrey
            ],
            getCurrentSelectedIndex: getCurrentSelectedIndex,
          ),

          /// Top Navigation Bar.
          Container(
            width: size.width - length,
            height: navHeight,
            child: TopNavigationBar(
              width: size.width - length,
              getSelectedIndex: getCurrentSelectedIndex,
              defaultIconSizes: 0.4 * navHeight,
              defaultOnPressed: _onNavButtonTapped,
              defaultTextScaleFactor: 0.00275 * size.height,
              children: [
                NavigationBarButton(
                  icon: SvgAsset.back_icon,
                  text: "",
                  size: 0.415 * navHeight,
                  onPressed: (index) {
                    Audio.play(MediaAsset.mp3.go_back);
                    Navigator.of(context).pop();
                  },
                ),
                NavigationBarButton(
                  icon: SvgAsset.videos_icon,
                  activeIcon: SvgAsset.videos_active_icon,
                  text: "Videos Vistos",
                ),
                NavigationBarButton(
                  icon: SvgAsset.series_icon,
                  activeIcon: SvgAsset.series_active_icon,
                  text: "Favoritos",
                ),
              ],
            ),
          ),

          /// Video & Game Cards' List.
          Expanded(
            child: Center(
              child: _cardList,
            ),
          ),
        ],
      ),
    );
  }

  /// Change the selected index when button is tapped.
  void _onNavButtonTapped(int index) {
    Audio.play(MediaAsset.mp3.click);
    setState(() {
      _selectedIndex = index;
    });
  }

  int getCurrentSelectedIndex() {
    return _selectedIndex;
  }
}

/// Custom painter for the colored bottom blob.
class BottomColoredBlob extends StatefulWidget {
  final Size size;
  final int currentSelectedIndex;
  final List<Color> colors;
  final int Function() getCurrentSelectedIndex;

  BottomColoredBlob(
      {this.size,
      this.currentSelectedIndex,
      this.colors,
      this.getCurrentSelectedIndex});

  @override
  _BottomColoredBlobState createState() => _BottomColoredBlobState();
}

class _BottomColoredBlobState extends State<BottomColoredBlob> {
  int currentSelectedIndex;

  @override
  void initState() {
    currentSelectedIndex = widget.getCurrentSelectedIndex();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    updateSelectedIndex();
    return CustomPaint(
      foregroundPainter: BottomColoredBlobPainter(
        size: widget.size,
        color: widget.colors[currentSelectedIndex],
      ),
    );
  }

  void updateSelectedIndex() {
    setState(() {
      currentSelectedIndex = widget.getCurrentSelectedIndex();
    });
  }
}

class BottomColoredBlobPainter extends CustomPainter {
  final Size size;
  final Color color;

  BottomColoredBlobPainter({this.size, this.color});

  @override
  void paint(Canvas canvas, Size _) {
    Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Path path = Path()..moveTo(0.5 * -size.width, 0.65 * size.height);

    path.quadraticBezierTo(
        0.0, 0.5 * size.height, 0.5 * size.width, 0.775 * size.height);
    path.lineTo(0.5 * size.width, size.height);
    path.lineTo(-0.5 * size.width, size.height);
    path.close();

    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
