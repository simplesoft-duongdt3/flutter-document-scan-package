import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera_preview_package/camera_preview_lib/camera_preview_widget.dart';
import 'package:flutter_camera_preview_package/camera_preview_lib/overlay_shape.dart';

import 'crop_image_util.dart';

class FlutterCameraPreview extends StatefulWidget {
  final Color headerColor;
  final Color footerColor;

  const FlutterCameraPreview({
    Key? key,
    this.headerColor = Colors.white,
    this.footerColor = Colors.white,
  }) : super(key: key);

  @override
  State<FlutterCameraPreview> createState() => _FlutterCameraPreviewState();
}

class _FlutterCameraPreviewState extends State<FlutterCameraPreview> {
  final GlobalKey<CameraPreviewWidgetState> cameraPreviewKey = GlobalKey();
  final ImageCropper cropImageUtil = ImageCropper();
  final double cropWidth = 240;
  final double cropHeight = 360;
  FlashMode _flashMode = FlashMode.auto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CameraPreviewWidget(
            key: cameraPreviewKey,
            onInitPreviewDone: _handlePreviewCameraDone,
            topSpaceColor: widget.headerColor,
            bottomSpaceColor: widget.footerColor,
          ),
          OverlayShape(
            width: cropWidth,
            height: cropHeight,
            borderRadius: BorderRadius.circular(8),
          ),
          _buildCaptureButton(),
          _buildHeader(context),
        ],
      ),
    );
  }

  void _handlePreviewCameraDone() {
    //TODO _handlePreviewCameraDone
    print('_handlePreviewCameraDone');
    FlashMode? flashMode = cameraPreviewKey.currentState?.getFlashMode();
    if (flashMode != null) {
      print('FlashMode $flashMode');
    }
  }

  Widget _buildCaptureButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
          color: Colors.transparent,
          child: Container(
              decoration: const BoxDecoration(
                color: Colors.black12,
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.all(25),
              child: IconButton(
                enableFeedback: true,
                color: Colors.white,
                onPressed: () {
                  _handleCaptureButton();
                },
                icon: const Icon(
                  Icons.camera,
                ),
                iconSize: 72,
              ))),
    );
  }

  Future<void> _handleCaptureButton() async {
    Size? previewSize = cameraPreviewKey.currentState?.getPreviewWidgetSize();
    XFile? file = await cameraPreviewKey.currentState?.takePicture();
    if (previewSize != null && file != null) {
      CropImageResult? cropImageResult = await cropImageUtil.crop(
        imagePath: file.path,
        cropWidth: cropWidth,
        cropHeight: cropHeight,
        parentHeight: previewSize.height,
        parentWidth: previewSize.width,
        quality: 80,
      );

      if (cropImageResult != null) {
        String bs4str = base64.encode(cropImageResult.cropImageBytes);
        print('Base64 Image ${file.path}');
      }
    }
  }

  Positioned _buildHeader(BuildContext context) {
    return Positioned(
      top: 0.0,
      left: 0.0,
      right: 0.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        decoration: BoxDecoration(
          color: widget.headerColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16.0),
            bottomRight: Radius.circular(16.0),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 54.0,
            child: Row(
              children: [
                IconButtonWidget(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.black87,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 4.0),
                const Expanded(
                  child: Text(
                    'Take a picture',
                  ),
                ),
                IconButtonWidget(
                  _flashMode == FlashMode.auto
                      ? Icons.flash_auto_outlined
                      : _flashMode == FlashMode.always
                      ? Icons.flash_on_outlined
                      : Icons.flash_off_outlined,
                  color: Colors.black87,
                  onTap: () {
                    FlashMode newFlashMode = _flashMode;
                    if (_flashMode == FlashMode.auto) {
                      newFlashMode = FlashMode.always;
                    } else if (_flashMode == FlashMode.always) {
                      newFlashMode = FlashMode.off;
                    } else {
                      newFlashMode = FlashMode.auto;
                    }

                    cameraPreviewKey.currentState?.setFlashMode(FlashMode.always).then((value)  {
                      setState(() {
                        _flashMode = newFlashMode;
                      });
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IconButtonWidget extends StatelessWidget {
  const IconButtonWidget(this.icon,
      {Key? key, required this.color, required this.onTap})
      : super(key: key);
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22.0),
      onTap: () => onTap(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          color: color,
        ),
      ),
    );
  }
}