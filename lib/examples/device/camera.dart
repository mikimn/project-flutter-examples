import 'dart:io';

import 'package:android_course/examples/device/camera_repository.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as paths;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class CameraExamplesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Camera Example'),
        ),
        body: Container(
          child: Consumer<CameraRepository>(
              builder: (context, cameraRepository, _) =>
                  CameraDisplay(cameraRepository.cameras)),
        ));
  }
}

class CameraDisplay extends StatefulWidget {
  final List<CameraDescription> cameraDescriptions;

  CameraDisplay(this.cameraDescriptions);

  @override
  _CameraDisplayState createState() => _CameraDisplayState();
}

class _CameraDisplayState extends State<CameraDisplay> {
  CameraController? controller;
  int currentCamera = 0;

  @override
  void initState() {
    super.initState();
    controller = CameraController(
        widget.cameraDescriptions[currentCamera], ResolutionPreset.medium);
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller!.value.isInitialized) {
      return Container();
    }
    return Stack(
      children: [
        Container(
          color: Colors.black,
          child: Center(
            child: AspectRatio(
                aspectRatio: controller!.value.aspectRatio,
                child: CameraPreview(controller!)),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            color: Colors.black54,
            height: 130.0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      color: Colors.white,
                      icon: Icon(Icons.flip_camera_android_outlined),
                      onPressed: () {
                        currentCamera = (currentCamera + 1) %
                            (widget.cameraDescriptions.length);
                        selectNewCamera(
                            widget.cameraDescriptions[currentCamera]);
                      }),
                  IconButton(
                      color: Colors.white,
                      icon: Icon(Icons.camera),
                      onPressed: () async {
                        final String imageName = '${DateTime.now()}.png';
                        final String path = paths.join(
                          (await getTemporaryDirectory()).path,
                          imageName,
                        );

                        controller!.takePicture().then((XFile file) async {
                          final File imageFile = File(file.path);
                          _showImageDialog(context, imageFile);
                          return imageFile;
                        }).catchError((error) => print('Error: $error'));
                      })
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  void selectNewCamera(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.medium);

    // If the controller is updated then update the UI.
    controller!.addListener(() {
      if (mounted) setState(() {});
      if (controller!.value.hasError) {
        // TODO Handle error
        // showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller!.initialize();
    } on CameraException catch (e) {
      // TODO Handle error
      // _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _showImageDialog(BuildContext context, File imageFile) {
    showDialog(
        context: context,
        builder: (context) => Container(
            margin: EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: Text('Captured Image'),
                ),
                Image.file(imageFile),
              ],
            )));
  }
}
