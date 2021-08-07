import 'package:flutter/material.dart';
import 'package:live_stream_player/widgets/camera_preview.dart';
import 'package:live_stream_player/widgets/custom_video_player.dart';
import 'package:video_player/video_player.dart';

class VideoPlayScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayScreen({Key? key, required this.videoUrl}) : super(key: key);
  @override
  _VideoPlayScreenState createState() => _VideoPlayScreenState();
}

class _VideoPlayScreenState extends State<VideoPlayScreen> {
  late VideoPlayerController _controller;
  double cameraViewHeight = 120;
  double cameraViewwidth = 120;
  Size? screenSize;

  @override
  void initState() {
    super.initState();
    // _controller = VideoPlayerController.network(
    //     'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4')
    // _controller = VideoPlayerController.asset('assets/video_2.mp4')
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..setLooping(true)
      ..initialize().then((_) {
        _controller.play();
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation) {
        final bool isPortrait = orientation == Orientation.portrait;
        screenSize = MediaQuery.of(context).size;
        return Stack(fit: StackFit.expand, children: [
          CustomVideoPlayer(isPortrait: isPortrait, controller: _controller),
          CameraPreviewWindow(screenSize: screenSize!)
        ]);
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
