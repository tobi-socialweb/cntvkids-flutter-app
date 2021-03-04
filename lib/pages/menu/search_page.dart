import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cntvkids_app/pages/menu/search_detail_page.dart';

/// General plugins
import 'package:flutter/material.dart';
import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:flutter/services.dart';

/// Signals
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

///
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// The first page to be shown when starting the app.
class SearchPage extends StatefulWidget {
  final stt.SpeechToText speech;

  const SearchPage({Key key, this.speech}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  /// Currently selected index for navigation bar.
  bool hide;
  SearchCardList lista;

  TextEditingController controller;
  String _textToSpeech = 'Buscar aquí';

  bool hasSpeech;

  @override
  void initState() {
    super.initState();
    _startOneSignal();

    lista = SearchCardList();
    controller = TextEditingController();
    hide = true;

    hasSpeech = widget.speech.isAvailable;
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
  }

  void submit(String string) {
    if (!this.mounted) return;

    setState(() {
      hide = false;
      lista = SearchCardList(search: string);
    });
  }

  void startListening() {
    widget.speech.listen(
      onResult: resultListener,
      cancelOnError: true,
      listenMode: stt.ListenMode.dictation,

      ///TODO: fix listen time duration
      listenFor: Duration(seconds: 5),
      pauseFor: Duration(seconds: 5),
    );

    if (!this.mounted) return;

    setState(() {
      hide = true;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      print("DEBUG: calling resultListener");
      _textToSpeech = result.recognizedWords;
      controller.text = _textToSpeech;

      if (widget.speech.isNotListening) submit(_textToSpeech);
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Get size of the current context widget.
    final Size size = MediaQuery.of(context).size;
    final double navHeight = NAVBAR_HEIGHT_PROP * size.height;
    final double iconSize = 0.5 * navHeight;
    final EdgeInsets padding = EdgeInsets.fromLTRB(
        0.00625 * navHeight, 0.0, 0.00625 * navHeight, 0.25 * navHeight);

    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).primaryColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// The colored curved blob in the background (white, yellow, etc.).
            CustomPaint(
              painter: BottomColoredBlobPainter(
                size: size,
                color: Colors.white,
              ),
            ),

            /// Top Bar.
            Stack(
              children: [
                Container(
                    constraints: BoxConstraints(
                        maxHeight: navHeight,
                        maxWidth: size.width,
                        minWidth: size.width,
                        minHeight: navHeight),
                    height: navHeight,
                    width: size.width,
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Back button.
                        SvgButton(
                          asset: SvgAsset.back_icon,
                          size: iconSize,
                          padding: padding,
                          onPressed: () => Navigator.of(context).pop(),
                        ),

                        /// search container
                        Expanded(
                          child: Container(
                              height: 0.35 * navHeight,
                              margin: EdgeInsets.only(bottom: 0.25 * navHeight),
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius:
                                      BorderRadius.circular(navHeight * 0.1)),
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.025),
                                child: TextField(
                                    controller: controller,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: TextStyle(
                                        fontSize: 12 * 0.003 * size.height,
                                        height: 1.5,
                                        color: Colors.white,
                                        fontFamily: "FredokaOne"),
                                    onTap: () {
                                      setState(() {
                                        hide = true;
                                      });
                                    },
                                    onChanged: (string) {
                                      setState(() {
                                        _textToSpeech = string;
                                      });
                                    },
                                    onSubmitted: (string) => submit(string),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: _textToSpeech,
                                      hintStyle: TextStyle(
                                          fontSize: 12 * 0.003 * size.height,
                                          height: 1.5,
                                          color: Colors.white,
                                          fontFamily: "FredokaOne"),
                                    )),
                              )),
                        ),

                        /// Search button
                        SvgButton(
                          asset: SvgAsset.search_icon,
                          size: iconSize,
                          padding: padding,
                          onPressed: () {
                            SystemChannels.textInput
                                .invokeMethod('TextInput.hide');
                            submit(_textToSpeech);
                          },
                        ),

                        /// TODO: Fix button not glowing when used
                        SvgButton(
                          asset: SvgAsset.record_icon,
                          size: iconSize,
                          onPressed: startListening,
                          padding: padding,
                        ),
                      ],
                    )),
                if (!hide)
                  Container(
                    height: size.height - navHeight,
                    width: size.width,
                    margin: EdgeInsets.only(top: navHeight),
                    child: lista,
                  ),
              ],
            )
          ],
        ));
  }

  /// Play sounds efects
  Future<AudioPlayer> playSound(String soundName) async {
    AudioCache cache = new AudioCache();
    var bytes = await (await cache.load(soundName)).readAsBytes();
    return cache.playBytes(bytes);
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
