import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:live_stream_player/widgets/video_player_controls.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class CustomVideoPlayer extends StatefulWidget {
  const CustomVideoPlayer({
    Key? key,
    required this.isPortrait,
    required VideoPlayerController controller,
  })   : _controller = controller,
        super(key: key);

  final bool isPortrait;
  final VideoPlayerController _controller;

  @override
  _CustomVideoPlayerState createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  Orientation? target;
  bool isPortraitMode = true;
  EdgeInsets? safePadding;
  StreamSubscription<NativeDeviceOrientation>? orientationStream;
  @override
  void initState() {
    setOrientation();
    isPortraitMode = widget.isPortrait;
    super.initState();
  }

  setOrientation() {
    Wakelock.enable();
    orientationStream = NativeDeviceOrientationCommunicator()
        .onOrientationChanged(useSensor: true)
        .listen(setNewOrientation);
  }

  void setNewOrientation(event) {
    isPortraitMode = event == NativeDeviceOrientation.portraitUp;
    final isLandscapeMode = event == NativeDeviceOrientation.landscapeRight ||
        event == NativeDeviceOrientation.landscapeLeft;
    final isTargetPortrait = target == Orientation.portrait;
    final isTargetLandscape = target == Orientation.landscape;
    if (isPortraitMode != isTargetPortrait ||
        isLandscapeMode != isTargetLandscape) {
      isLandscapeMode
          ? SystemChrome.setEnabledSystemUIOverlays([])
          : SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      target = null;

      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
  }

  @override
  void dispose() {
    Wakelock.disable();
    orientationStream?.cancel();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    safePadding = MediaQuery.of(context).padding;
    return Padding(
      padding: widget.isPortrait
          ? safePadding ?? EdgeInsets.all(0)
          : EdgeInsets.all(0),
      child: Stack(
          fit: widget.isPortrait ? StackFit.loose : StackFit.expand,
          children: [
            widget._controller.value.isInitialized
                ? FittedBox(
                    fit: !widget.isPortrait ? BoxFit.fill : BoxFit.contain,
                    child: SizedBox(
                      height: widget._controller.value.size.height,
                      width: widget._controller.value.size.width,
                      child: Stack(children: [
                        AspectRatio(
                          aspectRatio: widget._controller.value.aspectRatio,
                          child: VideoPlayer(widget._controller),
                        ),
                        VideoPlayerControls(
                            isPlaying: ValueNotifier<bool>(
                                widget._controller.value.isPlaying),
                            volume: ValueNotifier<double>(
                                widget._controller.value.volume),
                            controller: widget._controller,
                            onClickedFullScreen: () {
                              // setOrientation();
                              target = isPortraitMode
                                  ? Orientation.landscape
                                  : Orientation.portrait;
                              !isPortraitMode
                                  ? SystemChrome.setEnabledSystemUIOverlays([])
                                  : SystemChrome.setEnabledSystemUIOverlays(
                                      SystemUiOverlay.values);
                              isPortraitMode
                                  ? SystemChrome.setPreferredOrientations(
                                      [DeviceOrientation.landscapeLeft])
                                  : SystemChrome.setPreferredOrientations(
                                      [DeviceOrientation.portraitUp]);
                              isPortraitMode = !isPortraitMode;
                              // ? AutoOrientation.landscapeAutoMode()
                              // : AutoOrientation.portraitUpMode();
                              // isPortraitMode = target == Orientation.portrait;
                            })
                      ]),
                    ),
                  )
                : Container(),
          ]),
    );
  }
}
