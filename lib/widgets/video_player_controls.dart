import 'package:flutter/material.dart';
import 'package:live_stream_player/services/actionHandeler.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerControls extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback onClickedFullScreen;
  final ValueNotifier<double> volume;
  final ValueNotifier<bool> isPlaying;

  static const allSpeeds = <double>[0.25, 0.5, 1, 1.5, 2, 3, 5, 10];

  const VideoPlayerControls({
    Key? key,
    required this.controller,
    required this.onClickedFullScreen,
    required this.volume,
    required this.isPlaying,
  }) : super(key: key);

  @override
  _VideoPlayerControlsState createState() => _VideoPlayerControlsState();
}

class _VideoPlayerControlsState extends State<VideoPlayerControls> {
  FocusNode _playPauseButtonFocusNode = FocusNode();
  FocusNode _timelineFocusNode = FocusNode();
  FocusNode _fullscreenButtonFocusNode = FocusNode();
  FocusNode _volumeBarFocusNode = FocusNode();
  @override
  void initState() {
    _fullscreenButtonFocusNode.addListener(() {
      setState(() {});
    });
    _volumeBarFocusNode.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _playPauseButtonFocusNode.dispose();
    _timelineFocusNode.dispose();
    _fullscreenButtonFocusNode.dispose();
    _volumeBarFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ActionHandler().handleArrowAndEnterActions(
        child: Stack(
          children: <Widget>[
            buildSpeed(),
            Positioned(
                right: 0,
                bottom: 100,
                top: 100,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: ValueListenableBuilder<double>(
                    valueListenable: widget.volume,
                    builder: (context, currentVolume, child) => Actions(
                      actions: {
                        DownButtonIntent: CallbackAction<DownButtonIntent>(
                            onInvoke: (intent) =>
                                _fullscreenButtonFocusNode.requestFocus()),
                        RightButtonIntent: CallbackAction<RightButtonIntent>(
                            onInvoke: (intent) => changeVideoVolume(
                                widget.controller.value.volume + 0.1)),
                        LeftButtonIntent: CallbackAction<LeftButtonIntent>(
                            onInvoke: (intent) => changeVideoVolume(
                                widget.controller.value.volume - 0.1)),
                      },
                      child: Focus(
                        focusNode: _volumeBarFocusNode,
                        child: Container(
                          decoration: BoxDecoration(
                              border: _volumeBarFocusNode.hasFocus
                                  ? Border.all(width: 5)
                                  : null),
                          child: Slider(
                              value: currentVolume,
                              onChanged: changeVideoVolume),
                        ),
                      ),
                    ),
                  ),
                )),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    SizedBox(
                        child: Actions(
                      actions: {
                        EnterButtonIntent: CallbackAction<EnterButtonIntent>(
                            onInvoke: (intent) => toggleVideoPlayState()),
                        // UpButtonIntent: CallbackAction<UpButtonIntent>(
                        //     onInvoke: (intent) => FocusScope.of(context)
                        //         .requestFocus(_speedButtonFocusNode)),
                        RightButtonIntent: CallbackAction<RightButtonIntent>(
                            onInvoke: (intent) => FocusScope.of(context)
                                .requestFocus(_fullscreenButtonFocusNode)),
                      },
                      child: Focus(
                        focusNode: _playPauseButtonFocusNode,
                        autofocus: true,
                        child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: toggleVideoPlayState,
                            child: Container(
                                decoration: BoxDecoration(
                                    border: _playPauseButtonFocusNode.hasFocus
                                        ? Border.all(width: 5)
                                        : null),
                                child: buildPlay())),
                      ),
                    )),
                    Expanded(child: buildIndicator()),
                    const SizedBox(width: 12),
                    Actions(
                      actions: {
                        EnterButtonIntent: CallbackAction<EnterButtonIntent>(
                            onInvoke: (intent) => widget.onClickedFullScreen()),
                        UpButtonIntent: CallbackAction<UpButtonIntent>(
                            onInvoke: (intent) => FocusScope.of(context)
                                .requestFocus(_volumeBarFocusNode)),
                        LeftButtonIntent: CallbackAction<LeftButtonIntent>(
                            onInvoke: (intent) => FocusScope.of(context)
                                .requestFocus(_playPauseButtonFocusNode)),
                      },
                      child: Focus(
                        // autofocus: true,
                        focusNode: _fullscreenButtonFocusNode,
                        child: GestureDetector(
                          child: Container(
                            decoration: BoxDecoration(
                                border: _fullscreenButtonFocusNode.hasFocus
                                    ? Border.all(width: 5)
                                    : null),
                            child: Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                              size: 70,
                            ),
                          ),
                          onTap: widget.onClickedFullScreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                )),
          ],
        ),
      );

  void changeVideoVolume(newValue) {
    if (newValue < 0) newValue = 0.0;
    if (newValue > 1) newValue = 1.0;
    widget.controller.setVolume(newValue);
    widget.volume.value = newValue;
  }

  void toggleVideoPlayState() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
      widget.isPlaying.value = false;
    } else {
      widget.controller.play();
      widget.isPlaying.value = true;
    }
  }

  Widget buildIndicator() => Container(
        margin: EdgeInsets.all(8).copyWith(right: 0),
        height: 16,
        child: VideoProgressIndicator(
          widget.controller,
          allowScrubbing: true,
        ),
      );

  Widget buildSpeed() => Align(
        alignment: Alignment.topRight,
        child: PopupMenuButton<double>(
          initialValue: widget.controller.value.playbackSpeed,
          tooltip: 'Playback speed',
          onSelected: (value) {
            widget.controller.setPlaybackSpeed(value);
            setState(() {});
          },
          itemBuilder: (context) => VideoPlayerControls.allSpeeds
              .map<PopupMenuEntry<double>>((speed) => PopupMenuItem(
                    value: speed,
                    child: Text(
                      '${speed}x',
                    ),
                  ))
              .toList(),
          child: Container(
            color: Colors.white38,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              '${widget.controller.value.playbackSpeed}x',
              style: TextStyle(fontSize: 30),
            ),
          ),
        ),
      );

  Widget buildPlay() => ValueListenableBuilder<bool>(
        valueListenable: widget.isPlaying,
        builder: (context, isCurrentlyPlaying, child) => AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: isCurrentlyPlaying
              ? Container(
                  // color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.pause_outlined,
                      color: Colors.white,
                      size: 70,
                    ),
                  ),
                )
              : Container(
                  // color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 70,
                    ),
                  ),
                ),
        ),
      );
}
