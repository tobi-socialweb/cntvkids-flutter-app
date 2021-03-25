import 'package:cntvkids_app/pages/menu/search_detail_page.dart';
import 'package:cntvkids_app/widgets/background_music.dart';
import 'package:cntvkids_app/widgets/sound_effects.dart';

/// General plugins
import 'package:flutter/material.dart';
import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:flutter/services.dart';
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

  SoundEffect _soundEffect;

  @override
  void initState() {
    lista = SearchCardList();
    controller = TextEditingController();
    hide = true;
    _soundEffect = SoundEffect();
    hasSpeech = widget.speech.isAvailable;
    super.initState();
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
      listenMode: stt.ListenMode.dictation,
      cancelOnError: true,

      ///TODO: fix listen time duration
      listenFor: Duration(seconds: 5),
    );

    if (!this.mounted) return;
    setState(() {
      BackgroundMusicManager.instance.music.pauseMusic();
      hide = true;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      print("DEBUG: calling resultListener");
      _textToSpeech = result.recognizedWords;
      controller.text = _textToSpeech;

      if (widget.speech.isNotListening) {
        _soundEffect.play(MediaAsset.mp3.resultados);
        BackgroundMusicManager.instance.music.resumeMusic();
        submit(_textToSpeech);
      }
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

    return BackgroundMusic(
        volume: BackgroundMusicManager.getVolume(),
        child: Scaffold(
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
                                onPressed: () {
                                  _soundEffect.play(MediaAsset.mp3.click);
                                  Navigator.of(context).pop();
                                }),

                            /// search container
                            Expanded(
                              child: Container(
                                  height: 0.35 * navHeight,
                                  margin:
                                      EdgeInsets.only(bottom: 0.25 * navHeight),
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(
                                          navHeight * 0.1)),
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.025),
                                    child: TextField(
                                        controller: controller,
                                        textAlignVertical:
                                            TextAlignVertical.center,
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
                                              fontSize:
                                                  12 * 0.003 * size.height,
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
                                _soundEffect.play(MediaAsset.mp3.click);
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
            )));
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
