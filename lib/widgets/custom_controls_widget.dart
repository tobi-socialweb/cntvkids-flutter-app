import 'dart:async';

import 'package:better_player/better_player.dart' hide VideoPlayerValue;

import 'package:flutter/material.dart';

import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/widgets/video_display_widget.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/r.g.dart';

/// The controls for managing the videos state.
class CustomPlayerControls extends StatefulWidget {
  final BetterPlayerController controller;
  final Video video;

  const CustomPlayerControls({Key key, this.controller, this.video})
      : super(key: key);

  @override
  _CustomPlayerControlsState createState() => _CustomPlayerControlsState();
}

class _CustomPlayerControlsState extends State<CustomPlayerControls> {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
        child: WillPopScope(
            child: GestureDetector(
              child: InheritedVideoDisplay.of(context) == null ||
                      !InheritedVideoDisplay.of(context).isMinimized

                  /// If video display is full screen.
                  ? Container(color: Colors.transparent)

                  /// If video display is minimized.
                  : VideoControlsBar(
                      video: widget.video,
                      controller: widget.controller,
                    ),
              onTap: () {
                InheritedVideoDisplay.of(context).toggleDisplay();
              },
            ),
            onWillPop: () {
              if (InheritedVideoDisplay.of(context).isMinimized) {
                Navigator.of(context).pop();
              } else {
                InheritedVideoDisplay.of(context).toggleDisplay();
              }
              return Future<bool>.value(false);
            }));
  }
}

/// The bottom controls bar.
class VideoControlsBar extends StatefulWidget {
  final BetterPlayerController controller;
  final Video video;

  const VideoControlsBar({Key key, this.controller, this.video})
      : super(key: key);

  @override
  _VideoControlsBarState createState() => _VideoControlsBarState();
}

class _VideoControlsBarState extends State<VideoControlsBar> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(bottom: 0.005 * size.height),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              /// Play/pause button.
              InkWell(
                overlayColor: MaterialStateColor.resolveWith(
                    (states) => Colors.transparent),
                child: SvgIcon(
                  asset: widget.controller.isPlaying()
                      ? R.svg.back_icon
                      : R.svg.videos_icon,
                  size: 0.25 * size.height,
                  padding: EdgeInsets.only(left: 0.005 * size.height),
                ),
                onTap: () {
                  setState(() {
                    if (widget.controller.isPlaying())
                      widget.controller.pause();
                    else
                      widget.controller.play();
                  });
                },
              ),

              /// Left timer.
              Container(
                  width: 0.30 * size.height,
                  height: 0.30 * size.height,
                  child: Center(
                      child: _DisplayTime(
                    controller: widget.controller,

                    /// TODO: fix how to get a reliable textScaleFactor using proportions.
                    textScaleFactor: 0.005 * size.height,
                  ))),

              /// Progress bar.
              Expanded(
                child: _CustomProgressBar(
                  widget.controller,
                  height: 0.025 * size.height,
                  colors: BetterPlayerProgressColors(),
                ),
              ),

              /// Video duration.
              Container(
                  width: 0.30 * size.height,
                  height: 0.30 * size.height,
                  child: Center(
                      child: _DisplayTime.format(widget.controller,
                          textScaleFactor: 0.005 * size.height))),
            ],
          ),
        ],
      ),
    );
  }
}

/// Progress bar that detects interactions and updates accordingly.
class _CustomProgressBar extends StatefulWidget {
  final BetterPlayerController controller;
  final Function() onDragStart;
  final Function() onDragEnd;
  final Function() onDragUpdate;
  final double height;
  final double width;
  final BetterPlayerProgressColors colors;

  _CustomProgressBar(
    this.controller, {
    this.onDragEnd,
    this.onDragStart,
    this.onDragUpdate,
    this.height,
    this.width,
    Key key,
    this.colors,
  }) : super(key: key);

  @override
  _VideoProgressBarState createState() {
    return _VideoProgressBarState();
  }
}

class _VideoProgressBarState extends State<_CustomProgressBar> {
  VoidCallback listener;
  bool _controllerWasPlaying = false;

  _VideoProgressBarState() {
    listener = () {
      setState(() {});
    };
  }

  BetterPlayerController get betterPlayerController => widget.controller;

  @override
  void initState() {
    super.initState();
    widget.controller.videoPlayerController.addListener(listener);
  }

  @override
  void deactivate() {
    widget.controller.videoPlayerController.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    /// TODO: Show current time when seeking to new position.
    void seekToRelativePosition(Offset globalPosition) {
      final box = context.findRenderObject() as RenderBox;
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      if (relative > 0) {
        final Duration position =
            widget.controller.videoPlayerController.value.duration * relative;

        if (position >
            betterPlayerController.videoPlayerController.value.duration) {
          betterPlayerController.seekTo(
              betterPlayerController.videoPlayerController.value.duration);
        } else {
          betterPlayerController.seekTo(position);
        }
      }
    }

    return GestureDetector(
      onHorizontalDragStart: (DragStartDetails details) {
        if (!widget.controller.videoPlayerController.value.initialized) {
          return;
        }

        _controllerWasPlaying =
            widget.controller.videoPlayerController.value.isPlaying;
        if (_controllerWasPlaying) {
          widget.controller.pause();
        }

        if (widget.onDragStart != null) {
          widget.onDragStart();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!widget.controller.videoPlayerController.value.initialized) {
          return;
        }

        seekToRelativePosition(details.globalPosition);

        if (widget.onDragUpdate != null) {
          widget.onDragUpdate();
        }
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (_controllerWasPlaying) {
          widget.controller.play();
        }

        if (widget.onDragEnd != null) {
          widget.onDragEnd();
        }
      },
      onTapDown: (TapDownDetails details) {
        if (!widget.controller.videoPlayerController.value.initialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
      child: Center(
        child: Container(
          height: widget.height * 5,
          width: double.infinity,
          child: CustomPaint(
            painter: _ProgressBarPainter(
              value: widget.controller.videoPlayerController.value,
              colors: widget.colors,
              height: widget.height,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  dynamic value;
  BetterPlayerProgressColors colors;
  double height;

  _ProgressBarPainter({this.value, this.colors, this.height});

  @override
  bool shouldRepaint(CustomPainter painter) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    /// Background bar.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, (size.height - height) / 2),
          Offset(size.width, (size.height + height) / 2),
        ),
        const Radius.circular(100.0),
      ),
      colors.backgroundPaint,
    );

    if (!value.initialized) {
      return;
    }

    final double playedPartPercent =
        value.position.inMilliseconds / value.duration.inMilliseconds;
    final double playedPart =
        playedPartPercent > 1 ? size.width : playedPartPercent * size.width;

    final double start =
        value.buffered[0].startFraction(value.duration) * size.width;
    final double end =
        value.buffered[0].endFraction(value.duration) * size.width;

    /// Buffered bar.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(start, (size.height - height) / 2),
          Offset(end, (size.height + height) / 2),
        ),
        const Radius.circular(100.0),
      ),
      colors.bufferedPaint,
    );

    /// Played bar.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, (size.height - height) / 2),
          Offset(playedPart, (size.height + height) / 2),
        ),
        const Radius.circular(100.0),
      ),
      colors.playedPaint,
    );

    /// Handle circle.
    canvas.drawCircle(
      Offset(playedPart, size.height / 2),
      height * 1.5,
      colors.handlePaint,
    );
  }
}

/// Shows the duration or time in MM:SS format as a text widget.
class _DisplayTime extends StatefulWidget {
  final BetterPlayerController controller;
  final double textScaleFactor;
  final double diagonalOffset;

  _DisplayTime(
      {this.controller, this.textScaleFactor = 2.5, this.diagonalOffset = 2.5});

  _DisplayTimeState createState() => _DisplayTimeState();

  /// Format current time using the controller.
  static Text format(BetterPlayerController controller,
      {double textScaleFactor = 2.5,
      Color color = Colors.white,
      double diagonalOffset = 2.5}) {
    dynamic value = controller.videoPlayerController.value;
    return _DisplayTime.formatTime(
        value.duration.inMinutes, value.duration.inSeconds,
        textScaleFactor: textScaleFactor,
        color: color,
        diagonalOffset: diagonalOffset);
  }

  /// Expects minutes and seconds to be the total of each respective one separately.
  static Text formatTime(int minutes, int seconds,
      {double textScaleFactor = 2.5,
      Color color = Colors.white,
      double diagonalOffset = 2.5}) {
    seconds = seconds - 60 * minutes;

    String sMinutes = (minutes < 10) ? "0$minutes" : minutes.toString();
    String sSeconds = (seconds < 10) ? "0$seconds" : seconds.toString();

    return Text(
      "$sMinutes:$sSeconds",
      style: TextStyle(
        shadows: [
          Shadow(
              color: Color(0x8F000000),
              offset: Offset(diagonalOffset, diagonalOffset))
        ],
        color: color,
      ),
      textScaleFactor: textScaleFactor,
    );
  }
}

class _DisplayTimeState extends State<_DisplayTime> {
  Text text;
  Timer timer;

  int minuteCounter;
  int passedMinutes;
  int passedSeconds;

  int maxMinutes;
  int maxSeconds;

  dynamic get value => widget.controller.videoPlayerController.value;
  Timer getTimer() => Timer.periodic(Duration(seconds: 1), _timerCallback);

  @override
  void initState() {
    _updateTimePassed();

    if (widget.controller.isPlaying()) {
      timer = getTimer();
    }

    widget.controller.addEventsListener((event) {
      if (!this.mounted) return;

      setState(() {
        /// seekTo event.
        if (event.betterPlayerEventType == BetterPlayerEventType.seekTo) {
          if (timer != null) timer.cancel();

          _updateTimePassed();

          if (widget.controller.isPlaying()) {
            timer = getTimer();
          }

          /// play event.
        } else if (event.betterPlayerEventType == BetterPlayerEventType.play) {
          if (timer != null) timer.cancel();

          _updateTimePassed();

          timer = getTimer();

          /// pause event.
        } else if (event.betterPlayerEventType == BetterPlayerEventType.pause) {
          _updateTimePassed();

          if (timer != null) timer.cancel();
        } else if (event.betterPlayerEventType ==
            BetterPlayerEventType.finished) {
          _updateTimePassed();

          if (timer != null) {
            /// Show the max minutes and seconds because the video finished.
            if (passedSeconds >= maxSeconds) {
              text = _DisplayTime.formatTime(maxMinutes, maxSeconds,
                  textScaleFactor: widget.textScaleFactor);
            }

            timer.cancel();
          }
        }

        /// TODO: Cancel timer when video stops for buffering the rest (when there is lag).
      });

      maxMinutes = value.duration.inMinutes;
      maxSeconds = value.duration.inSeconds;
    });

    widget.controller.videoPlayerController.addListener(() {
      if (value.isBuffering && timer.isActive) {
        timer.cancel();
      } else if (!value.isBuffering && timer != null && !timer.isActive) {
        timer = getTimer();
      }
    });

    super.initState();
  }

  void _timerCallback(Timer timer) {
    if (!this.mounted) return;

    setState(() {
      passedSeconds += 1;
      minuteCounter += 1;

      if (minuteCounter > 59) {
        passedMinutes += 1;
        minuteCounter = 0;
      }

      /// Check if current values go 2 seconds beyond the real video position.
      if (passedSeconds + 1 > value.position.inSeconds) {
        passedSeconds -= 1;
        minuteCounter -= 1;
      }

      text = _DisplayTime.formatTime(passedMinutes, passedSeconds,
          textScaleFactor: widget.textScaleFactor);
    });
  }

  void _updateTimePassed() {
    if (!this.mounted) return;

    setState(() {
      passedMinutes = value.position.inMinutes;
      passedSeconds = value.position.inSeconds;
      minuteCounter = passedSeconds - 60 * passedMinutes;

      text = _DisplayTime.formatTime(passedMinutes, passedSeconds,
          textScaleFactor: widget.textScaleFactor);
    });
  }

  @override
  Widget build(BuildContext context) {
    return text;
  }
}
