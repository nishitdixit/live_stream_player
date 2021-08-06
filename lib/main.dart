import 'dart:async';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:live_stream_player/models/video_model.dart';
import 'package:live_stream_player/services/actionHandeler.dart';
import 'package:live_stream_player/widgets/camera_preview.dart';
import 'package:live_stream_player/widgets/video_player_controls.dart';
import 'package:video_player/video_player.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
      },
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(
              sliderTheme: SliderTheme.of(context).copyWith(
                //slider modifications
                thumbColor: Color(0xFFEB1555),
                inactiveTrackColor: Color(0xFF8D8E98),
                activeTrackColor: Colors.white,
                overlayColor: Color(0x99EB1555),
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15.0),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 30.0),
              ),
              primaryColor: Color(0xFF0A0E21), // theme color
              scaffoldBackgroundColor: Color(0xFF0A0E21)),
          title: 'Video Demo',
          home: VideoListPage()),
    );
  }
}

class VideoListPage extends StatefulWidget {
  const VideoListPage({Key? key}) : super(key: key);

  @override
  _VideoListPageState createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  List<Video> videos = [];
  int focusIndex = 0;
  CarouselController buttonCarouselController = CarouselController();
  @override
  void initState() {
    loadVideoList();

    super.initState();
  }

  loadVideoList() async {
    String data =
        await DefaultAssetBundle.of(context).loadString("assets/media.json");
    videos = videoFromMap(data);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video test'),
      ),
      body: ActionHandler().handleArrowAndEnterActions(
        child: Actions(
          actions: {
            LeftButtonIntent:
                CallbackAction<LeftButtonIntent>(onInvoke: (intent) {
              return buttonCarouselController.previousPage(
                  duration: Duration(microseconds: 300),
                  curve: Curves.easeInOutCubic);
            }),
            RightButtonIntent:
                CallbackAction<RightButtonIntent>(onInvoke: (intent) {
              return buttonCarouselController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic);
            }),
            EnterButtonIntent: CallbackAction<EnterButtonIntent>(
                onInvoke: (intent) =>
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => VideoPlayScreen(
                              videoUrl: videos[focusIndex].sources![0],
                            )))),
          },
          child: Focus(
            autofocus: true,
            child: CarouselSlider.builder(
                options: CarouselOptions(
                  aspectRatio: 2,
                  viewportFraction: 0.6,
                  initialPage: 0,
                  enableInfiniteScroll: false,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 15),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  onPageChanged: (int pageIndex, carouselPageChangedReason) {
                    focusIndex = pageIndex;
                  },
                  scrollDirection: Axis.horizontal,
                ),
                carouselController: buttonCarouselController,
                // itemScrollController: _scrollController,
                itemCount: videos.length,
                itemBuilder: (context, itemIndex, pageIndex) => GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => VideoPlayScreen(
                                  videoUrl: videos[pageIndex].sources![0],
                                )));
                      },
                      child: Card(
                        child: Image.network(
                          '${videos[itemIndex].thumb}',
                          fit: BoxFit.fill,
                        ),
                      ),
                    )),
          ),
        ),
      ),
    );
  }
}

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
