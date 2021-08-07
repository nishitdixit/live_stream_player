import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPreviewWindow extends StatefulWidget {
  final Size screenSize;

  const CameraPreviewWindow({Key? key, required this.screenSize})
      : super(key: key);
  @override
  _CameraPreviewWindowState createState() => _CameraPreviewWindowState();
}

class _CameraPreviewWindowState extends State<CameraPreviewWindow>
    with WidgetsBindingObserver {
  double cameraViewHeight = 120;
  double cameraViewwidth = 150;
  ValueNotifier<Offset>? position;
  CameraController? _cameraController;
  Size? screenSize;
  @override
  void initState() {
    initializeCamera();
    // setPosition();
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.addObserver(this);
    _cameraController?.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (_cameraController == null) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initializeCamera();
    }
  }

  setPosition() {
    position = ValueNotifier<Offset>(Offset(
        widget.screenSize.width - cameraViewwidth - 50,
        widget.screenSize.height - cameraViewHeight - 50));
  }

  initializeCamera() async {
    try {
      setPosition();
// Obtain a list of the available cameras on the device.

      // if (permission) {
      final camera = await availableCameras().then((value) => value.length == 0
          ? null
          : value.firstWhere(
              (element) => element.lensDirection == CameraLensDirection.front,
              orElse: null));
      bool permission = false;
      if (camera != null) {
        permission = await Permission.camera.isGranted;
        if (!permission && !await Permission.camera.isRestricted)
          await Permission.camera.request();
        permission = await Permission.camera.isGranted;
      }
      if (camera != null && permission) {
        _cameraController = CameraController(camera, ResolutionPreset.medium);
        _cameraController?.initialize().then((value) {
          if (!mounted) {
            return;
          }
          setState(() {});
        });
        // }
      }
    } catch (e) {
      // print(e);
      initializeCamera();
    }
  }

  @override
  void didUpdateWidget(covariant CameraPreviewWindow oldWidget) {
    super.didUpdateWidget(oldWidget);
    initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return _cameraController == null
        ? Align(
            alignment: Alignment.bottomRight,
            child: Text('no camera available'),
          )
        : ValueListenableBuilder<Offset>(
            valueListenable: position ?? ValueNotifier<Offset>(Offset(50, 50)),
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
  }
}
