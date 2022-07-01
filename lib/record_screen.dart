import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';


class RecordScreen extends StatefulWidget {
  @override
  RecordScreenState createState() => RecordScreenState();
}

class RecordScreenState extends State<RecordScreen> {

  final record = Record();
  final player = AudioPlayer();
  String path = '';

  bool isRecording = false;

  @override
  void dispose(){
    super.dispose();
    player.dispose();
  }

  Future<void> startStopRecording() async{
    if (await record.hasPermission()) {
      if(isRecording){
        await record.stop();
        await player.setFilePath(path);
        await player.play();
        setState((){
          isRecording = false;
        });
      }else {
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;
        path = appDocPath + '/' + DateTime.now().microsecondsSinceEpoch.toString() + '.m4a';
        await record.start(
          path: path,
        );
        setState((){
          isRecording = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () => startStopRecording(),
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: Center(
              child: Icon(isRecording ? Icons.pause : Icons.play_arrow),
            ),
          ),
        ),
      ),
    );
  }
}
