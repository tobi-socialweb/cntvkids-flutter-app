import 'dart:async';

import 'package:flutter/material.dart';

import 'package:better_player/better_player.dart' hide VideoPlayerValue;

import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/pages/video_display_page.dart';
import 'package:cntvkids_app/common/helpers.dart';

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
  /// TODO: add listener to controller, to check if video is finished and restart
  /// video on

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
              SvgButton(
                asset: widget.controller.isPlaying()
                    ? SvgAsset.player_pause_icon
                    : SvgAsset.player_play_icon,
                size: 0.25 * size.height,
                padding: EdgeInsets.only(left: 0.005 * size.height),
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
    void seekToRelativePosition(Offset globalPosition) {
      final box = context.findRenderObject() as RenderBox;
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      if (relative > 0) {
        final Duration position =
            widget.controller.videoPlayerController.value.duration * relative;

        /// If position is greater than video duration, then move to max.
        if (position >
            betterPlayerController.videoPlayerController.value.duration) {
          betterPlayerController.seekTo(
              betterPlayerController.videoPlayerController.value.duration);

          /// If position is less than 0, move to 0.
        } else if (position < Duration.zero) {
          betterPlayerController.seekTo(Duration.zero);

          /// Otherwise, move to position.
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
    return _DisplayTime.formatTime(value.duration.inMilliseconds,
        textScaleFactor: textScaleFactor,
        color: color,
        diagonalOffset: diagonalOffset);
  }

  /// Expects minutes and seconds to be the total of each respective one separately.
  static Text formatTime(int milliseconds,
      {double textScaleFactor = 2.5,
      Color color = Colors.white,
      double diagonalOffset = 2.5}) {
    /// Get the ammount of seconds and minutes.
    int numSeconds = (milliseconds / 1000).floor();
    int numMinutes = (numSeconds / 60).floor();
    numSeconds = numSeconds % 60;

    /// Format correctly as strings.
    String strSeconds =
        (numSeconds < 10) ? "0$numSeconds" : numSeconds.toString();
    String strMinutes =
        (numMinutes < 10) ? "0$numMinutes" : numMinutes.toString();

    return Text(
      "$strMinutes:$strSeconds",
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
  /// Text component that displays the time.
  Text text;

  /// Timer that calls the _timerCallback function every second.
  Timer timer;

  /// The ammount of milliseconds to wait for the [timerPeriodicity].
  final int timeOffset = 100;

  /// The ammount of time to wait before trying to update the timer if there is
  /// a shift or delay. Used inside [startTimer()].
  ///
  /// Currently, the value is for 1/10 of a second.
  Duration timerPeriodicity;

  /// The currently passed time in the units used.
  int passedTime;

  /// The max time units according to the video duration.
  int maxTime;

  /// The ammount of possible error range (proportion of the [timeOffset])
  /// when checking for the current video position (must be a positive value).
  final double errorRange = 0.5;

  BetterPlayerController get controller => widget.controller;
  dynamic get value => widget.controller.videoPlayerController.value;

  void startTimer() {
    timer = Timer.periodic(timerPeriodicity, _timerCallback);
  }

  void cancelTimer() {
    if (timer != null) timer.cancel();
  }

  @override
  void initState() {
    timerPeriodicity = Duration(milliseconds: timeOffset);

    _updateTimePassed();

    if (controller.isPlaying()) startTimer();

    controller.addEventsListener((event) {
      if (!this.mounted) return;

      setState(() {
        /// seekTo event.
        if (event.betterPlayerEventType == BetterPlayerEventType.seekTo) {
          cancelTimer();
          _updateTimePassed();

          if (controller.isPlaying()) {
            startTimer();
          }

          /// play event.
        } else if (event.betterPlayerEventType == BetterPlayerEventType.play) {
          cancelTimer();
          _updateTimePassed();

          startTimer();

          /// pause event.
        } else if (event.betterPlayerEventType == BetterPlayerEventType.pause) {
          _updateTimePassed();

          cancelTimer();
        } else if (event.betterPlayerEventType ==
            BetterPlayerEventType.finished) {
          _updateTimePassed();

          if (timer != null) {
            /// Show the max minutes and seconds because the video finished.
            if (passedTime > maxTime) {
              text = _DisplayTime.formatTime(maxTime,
                  textScaleFactor: widget.textScaleFactor);
            }

            cancelTimer();
          }
        }
      });

      maxTime = value.duration.inMilliseconds;
    });

    controller.videoPlayerController.addListener(() {
      if (value.isBuffering && timer.isActive) {
        cancelTimer();
      } else if (!value.isBuffering && timer != null && !timer.isActive) {
        startTimer();
      }
    });

    super.initState();
  }

  void _timerCallback(Timer timer) {
    if (!this.mounted) return;

    setState(() {
      /// Add the time passed.
      passedTime += timeOffset;

      /// Get the error between the current position and the time has passed.
      int error = value.position.inMilliseconds - passedTime;

      /// If the error goes beyond the error range, then fix.
      if (error.abs() >= timeOffset * errorRange) {
        /*print(
            "DEBUG: fixing passedTime from ($passedTime)->(${error > 0 ? passedTime + timeOffset * errorRange : passedTime - timeOffset * errorRange}), because the error (abs(error) = abs($error) = ${error.abs()}) is greater or equal than\nDEBUG:\t-> timeOffset * errorRange = $timeOffset * $errorRange = ${timeOffset * errorRange}\nDEBUG:");*/

        passedTime +=
            (error > 0 ? timeOffset * errorRange : -timeOffset * errorRange)
                .floor();
      }

      /// Change the text widget to reflect new time.
      text = _DisplayTime.formatTime(passedTime,
          textScaleFactor: widget.textScaleFactor);
    });
  }

  /// Get the current position according to the video controller and update text.
  void _updateTimePassed() {
    if (!this.mounted) return;

    setState(() {
      passedTime = value.position.inMilliseconds;

      text = _DisplayTime.formatTime(passedTime,
          textScaleFactor: widget.textScaleFactor);
    });
  }

  @override
  Widget build(BuildContext context) {
    return text;
  }
}
