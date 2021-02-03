import 'dart:convert';
import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/pages/articles.dart';
import 'package:cntvkids_app/pages/local_articles.dart';
import 'package:cntvkids_app/pages/search.dart';
import 'package:cntvkids_app/pages/settings.dart';
import 'package:cntvkids_app/pages/single_article.dart';
import 'package:cntvkids_app/pages/featured.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common/helpers.dart';
import 'models/article.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Set mobile orientations as landscape only.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  /// Currently, this setting will get lost after UI changes (when writing on
  /// a text box, for example). Needs the use of restoreSystemUIOverlays.
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

  runApp(
    ChangeNotifierProvider<AppStateNotifier>(
      create: (context) => AppStateNotifier(),
      child: MyApp(),
    ),
  );
}

/// Main app widget class.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateNotifier>(builder: (context, appState, child) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CNTV Kids',
        theme: ThemeData(
            brightness: Brightness.light,
            primaryColorLight: Colors.white,
            primaryColorDark: Colors.black,
            primaryColor: Colors.red,
            accentColor: Colors.purple,
            canvasColor: Color(0xFFE3E3E3),
            textTheme: TextTheme(
              headline1: TextStyle(
                fontSize: 17,
                color: Colors.black,
                height: 1.2,
                fontWeight: FontWeight.w500,
                fontFamily: "Soleil",
              ),
              headline2: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'Poppins'),
              caption: TextStyle(color: Colors.black45, fontSize: 10),
              bodyText1: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
              bodyText2: TextStyle(
                fontSize: 14,
                height: 1.2,
                color: Colors.black54,
              ),
            ),
            backgroundColor: Colors.white,
            scaffoldBackgroundColor: Colors.white),
        home: HomePage(),
      );
    });
  }
}

/// The first page to be shown when starting the app.
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Currently selected index for navigation bar.
  int _selectedIndex = 0;

  /// Firebase Cloud Messeging setup.
  Article _notificationArticle;
  Article _deepLinkArticle;

  /// All options from the navigation bar.
  final List<Widget> _widgetOptions = [
    Featured(),
    Articles(),
    LocalArticles(),
    Settings(),
    Search(),
  ];

  @override
  void initState() {
    super.initState();
    _startOneSignal();
    if (ENABLE_DYNAMIC_LINK) _startDynamicLinkService();
    if (ENABLE_ADS) _startAdMob();
  }

  _startAdMob() {
    Admob.initialize(ADMOB_ID);
  }

  _startDynamicLinkService() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    _handleDeepLink(data);

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      _handleDeepLink(dynamicLink);
    }, onError: (OnLinkErrorException e) async {
      print('Link Failed: ${e.message}');
    });
  }

  void _handleDeepLink(PendingDynamicLinkData data) async {
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      print('_handleDeepLink | deeplink: $deepLink');

      var isPost = deepLink.pathSegments.contains('post');

      if (isPost) {
        var postId = deepLink.queryParameters['post_id'];

        if (postId != null) {
          await _fetchDeepLinkArticle(postId);
          if (_deepLinkArticle != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SingleArticle(_deepLinkArticle, postId),
              ),
            );
          }
        }
      }
    }
  }

  _startOneSignal() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'notification';
    final value = prefs.getInt(key) ?? 1;

    onesignal.init(
      ONE_SIGNAL_APP_ID,
      iOSSettings: {
        OSiOSSettings.autoPrompt: true,
        OSiOSSettings.inAppLaunchUrl: true
      },
    );
    onesignal.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    onesignal.setInFocusDisplayType(OSNotificationDisplayType.notification);

    await enableNotification(context, value == 1);

    onesignal.setNotificationOpenedHandler(
        (OSNotificationOpenedResult result) async {
      String url = result.notification.payload.additionalData['url'].toString();
      if (result.action.actionId == "openbrowser") {
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw ERROR_MESSAGE["NO_LAUNCH"] + url;
        }
        return;
      } else if (result.action.actionId == "share") {
        Share.share('$url');
        return;
      }

      String postId =
          result.notification.payload.additionalData['postId'].toString();
      await _fetchNotificationArticle(postId);
      if (_notificationArticle != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SingleArticle(_notificationArticle, postId),
          ),
        );
      }
    });
  }

  Future<Article> _fetchNotificationArticle(String id) async {
    try {
      http.Response response =
          await http.get("$WORDPRESS_URL/wp-json/wp/v2/posts/$id");
      if (this.mounted) {
        if (response.statusCode == 200) {
          Map<String, dynamic> articleRes = json.decode(response.body);
          setState(() {
            _notificationArticle = Article.fromJson(articleRes);
          });
          return _notificationArticle;
        }
      }
    } on SocketException {
      throw ERROR_MESSAGE["NO_CONNECTION"];
    }
    return _notificationArticle;
  }

  Future<Article> _fetchDeepLinkArticle(String id) async {
    try {
      http.Response response =
          await http.get("$WORDPRESS_URL/wp-json/wp/v2/posts/$id");
      if (this.mounted) {
        if (response.statusCode == 200) {
          Map<String, dynamic> articleRes = json.decode(response.body);
          setState(() {
            _deepLinkArticle = Article.fromJson(articleRes);
          });
          return _deepLinkArticle;
        }
      }
    } on SocketException {
      throw ERROR_MESSAGE["NO_CONNECTION"];
    }
    return _deepLinkArticle;
  }

  @override
  Widget build(BuildContext context) {
    /// Get size of the current context widget.
    final Size size = MediaQuery.of(context).size;

    /// TODO: Use navigator and app bar for routing.
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
            width: size.width,
            height: 0.20 * size.height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      _onNavButtonTapped(0);
                    },
                    child: Text("LOGO")),
                TextButton(
                    onPressed: () {
                      _onNavButtonTapped(0);
                    },
                    child: Text("Destacados")),
                TextButton(
                    onPressed: () {
                      _onNavButtonTapped(1);
                    },
                    child: Text("Series")),
                TextButton(
                    onPressed: () {
                      _onNavButtonTapped(2);
                    },
                    child: Text("Listas")),
                TextButton(
                    onPressed: () {
                      _onNavButtonTapped(3);
                    },
                    child: Text("Juegos")),
                TextButton(
                    onPressed: () {
                      _onNavButtonTapped(4);
                    },
                    child: Text("Buscar")),
              ],
            )),
        Expanded(
          child: Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
        ),
        Container(
          width: size.width,
          height: 0.20 * size.height,
        )
      ],
    ));
  }

  /// Change the selected index when button is tapped.
  void _onNavButtonTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
