import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:live_stream_player/models/video_model.dart';
import 'package:live_stream_player/screens/video_play_screen.dart';
import 'package:live_stream_player/services/actionHandeler.dart';

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
