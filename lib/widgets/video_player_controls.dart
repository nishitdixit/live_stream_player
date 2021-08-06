import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerControls extends StatelessWidget {
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
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          buildSpeed(),
          Positioned(
              right: 0,
              bottom: 100,
              top: 100,
              child: RotatedBox(
                quarterTurns: 3,
                child: ValueListenableBuilder<double>(
                  valueListenable: volume,
                  builder: (context, currentVolume, child) => Slider(
                      value: currentVolume,
                      onChanged: (newValue) {
                        controller.setVolume(newValue);
                        volume.value = newValue;
                      }),
                ),
              )),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                children: [
                  SizedBox(
                      child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (controller.value.isPlaying) {
                              controller.pause();
                              isPlaying.value = false;
                            } else {
                              controller.play();
                              isPlaying.value = true;
                            }
                          },
                          child: buildPlay())),
                  Expanded(child: buildIndicator()),
                  const SizedBox(width: 12),
                  GestureDetector(
                    child: Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: 70,
                    ),
                    onTap: onClickedFullScreen,
                  ),
                  const SizedBox(width: 8),
                ],
              )),
        ],
      );

  Widget buildIndicator() => Container(
        margin: EdgeInsets.all(8).copyWith(right: 0),
        height: 16,
        child: VideoProgressIndicator(
          controller,
          allowScrubbing: true,
        ),
      );

  Widget buildSpeed() => Align(
        alignment: Alignment.topRight,
        child: PopupMenuButton<double>(
          initialValue: controller.value.playbackSpeed,
          tooltip: 'Playback speed',
          onSelected: controller.setPlaybackSpeed,
          itemBuilder: (context) => allSpeeds
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
              '${controller.value.playbackSpeed}x',
              style: TextStyle(fontSize: 30),
            ),
          ),
        ),
      );

  Widget buildPlay() => ValueListenableBuilder<bool>(
        valueListenable: isPlaying,
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
                      size: 100,
                    ),
                  ),
                )
              : Container(
                  // color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100,
                    ),
                  ),
                ),
        ),
      );
}
