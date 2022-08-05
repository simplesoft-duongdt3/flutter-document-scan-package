import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewWidget extends StatefulWidget {
  final Color? topSpaceColor;
  final Color? bottomSpaceColor;
  final VoidCallback onInitPreviewDone;

  const CameraPreviewWidget({
    Key? key,
    required this.onInitPreviewDone,
    this.topSpaceColor,
    this.bottomSpaceColor,
  }) : super(key: key);

  @override
  State<CameraPreviewWidget> createState() => CameraPreviewWidgetState();
}

class CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  final GlobalKey _topWidgetKey = GlobalKey();
  CameraController? _cameraController;

  final List<CameraDescription> _listCamera = [];

  @override
  void initState() {
    super.initState();
    availableCameras().then((List<CameraDescription> listCamera) {
      _listCamera.clear();
      _listCamera.addAll(listCamera);

      print('CameraPreviewWidgetState listCamera $_listCamera');

      if (listCamera.isNotEmpty) {
        _selectCamera(listCamera.first);
      } else {
        setState(() {});
      }
    });
  }

  void _selectCamera(CameraDescription camera) {
    CameraController cameraController =
    CameraController(camera, ResolutionPreset.max);
    cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        print('CameraPreviewWidgetState select cameraId ${cameraController.cameraId}');
        _cameraController = cameraController;
        widget.onInitPreviewDone();
      });
    });
  }

  @override
  void didUpdateWidget(covariant CameraPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.topSpaceColor != widget.topSpaceColor ||
        oldWidget.bottomSpaceColor != widget.bottomSpaceColor) {
      setState((){

      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _cameraController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var cameraController = _cameraController;
    if (cameraController != null) {
      return Column(
        children: [
          Expanded(
            child: Container(
              key: _topWidgetKey,
              color: widget.topSpaceColor,
            ),
          ),
          CameraPreview(cameraController),
          Expanded(
            child: Container(
              color: widget.bottomSpaceColor,
            ),
          ),
        ],
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Future<XFile?> takePicture() async {
    var cameraController = _cameraController;
    if (cameraController != null) {
      try {
        XFile xFile = await cameraController.takePicture();
        return xFile;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> setFlashMode(FlashMode flashMode) async {
    var cameraController = _cameraController;
    if (cameraController != null) {
      try {
        await cameraController.setFlashMode(flashMode);
      } catch (e) {
        //ignore exception here
      }
    }
  }

  FlashMode? getFlashMode() {
    return _cameraController?.value.flashMode;
  }


  Size? getPreviewWidgetSize() {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    RenderBox box = _topWidgetKey.currentContext!.findRenderObject() as RenderBox;
    double spaceHeight = box.size.height * 2;

    return Size(screenWidth, screenHeight - spaceHeight);
  }
}
