import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewWindow extends StatefulWidget {
  final Size screenSize;

  const CameraPreviewWindow({Key? key, required this.screenSize})
      : super(key: key);
  @override
  _CameraPreviewWindowState createState() => _CameraPreviewWindowState();
}

class _CameraPreviewWindowState extends State<CameraPreviewWindow> {
  double cameraViewHeight = 120;
  double cameraViewwidth = 150;
  ValueNotifier<Offset>? position;
  CameraController? _cameraController;
  Size? screenSize;
  @override
  void initState() {
    setPosition();
    super.initState();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  setPosition() {
    position = ValueNotifier<Offset>(Offset(
        widget.screenSize.width - cameraViewwidth - 50,
        widget.screenSize.height - cameraViewHeight - 50));
  }

  Future<void> initializeCamera() async {
    setPosition();
// Obtain a list of the available cameras on the device.
    final camera = await availableCameras().then((value) => value.length == 0
        ? null
        : value.singleWhere(
            (element) => element.lensDirection == CameraLensDirection.front));
    if (camera != null) {
      _cameraController = CameraController(camera, ResolutionPreset.medium);
      return _cameraController?.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: initializeCamera(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the Future is complete, display the preview.
          return _cameraController == null
              ? Align(
                  alignment: Alignment.bottomRight,
                  child: Text('no camera available'),
                )
              : ValueListenableBuilder<Offset>(
                  valueListenable:
                      position ?? ValueNotifier<Offset>(Offset(50, 50)),
                  builder: (context, currentPosition, child) {
                    return Positioned(
                      left: currentPosition.dx,
                      top: currentPosition.dy,
                      child: Draggable(
                        feedback: SizedBox(
                            height: cameraViewHeight,
                            width: cameraViewwidth,
                            child: CameraPreview(_cameraController!)),
                        childWhenDragging: Opacity(
                          opacity: .3,
                          child: Container(),
                        ),
                        onDragEnd: (details) {
                          position?.value = details.offset;
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.red[500]!,
                                ),
                                borderRadius: BorderRadius.circular(
                                    20) // use instead of BorderRadius.all(Radius.circular(20))
                                ),
                            height: cameraViewHeight,
                            width: cameraViewwidth,
                            child: CameraPreview(_cameraController!)),
                      ),
                    );
                  });
        } else {
          return Container();
          // Otherwise, display a loading indicator.
          // return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
