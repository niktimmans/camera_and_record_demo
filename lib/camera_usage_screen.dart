import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CameraScreen extends StatefulWidget {
  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  List<CameraDescription>? _cameras;
  bool isRecording = false;
  bool isRecorded = false;
  late XFile file;
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose(){
    super.dispose();
    _controller.dispose();
    controller!.dispose();
  }

  Future<void> initCamera() async {
    _cameras = await availableCameras();
    controller = CameraController(_cameras![0], ResolutionPreset.max);
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('User denied camera access.');
            break;
          default:
            print('Handle other errors.');
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isRecorded
          ? VideoPlayer(_controller)
          : controller != null
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    CameraPreview(controller!),
                    Positioned(
                      bottom: 40,
                      child: GestureDetector(
                        onTap: () async {
                          if (!isRecording) {
                            await controller!.startVideoRecording();
                            setState(() {
                              isRecording = true;
                            });
                          } else {
                            file = await controller!.stopVideoRecording();
                            _controller =
                               VideoPlayerController.file(File(file.path))
                                  ..initialize().then((_) {
                                    // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                                    setState(() {
                                      isRecording = false;
                                      isRecorded = true;
                                    });
                                    _controller.setLooping(true);
                                    _controller.play();
                                  });
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: isRecording
                                ? BoxShape.rectangle
                                : BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
    );
  }
}
