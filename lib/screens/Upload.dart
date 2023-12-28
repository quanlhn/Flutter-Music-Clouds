// ignore: file_names
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_music_clouds/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_music_clouds/models/Const.dart';

class Upload extends StatefulWidget {
  const Upload({super.key});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController songName = TextEditingController();
  TextEditingController artistName = TextEditingController();
  TextEditingController songType = TextEditingController();

  DatabaseReference dbRef = FirebaseDatabase.instance.ref("app/songInfos");

  PlatformFile? pickedImage;
  PlatformFile? pickedSong;
  UploadTask? uploadTask;

    @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future upload() async {
    final imagePath = 'artist-images/${pickedImage!.name}';
    final imageFile = File(pickedImage!.path!);

    final imageRef = FirebaseStorage.instance.ref().child(imagePath);
    setState(() {
      uploadTask = imageRef.putFile(imageFile);
    });

    // if (uploadTask != null) {
    final snapshot = await uploadTask!.whenComplete(() {});
    final imageUrlDownload = await snapshot.ref.getDownloadURL();
    // var imageUrl = await (await uploadTask)?.ref.getDownloadURL();

    print('Image download Link:  $imageUrlDownload');

    setState(() {
      uploadTask = null;
    });

    final songPath = 'songs/${pickedSong!.name}';
    final songFile = File(pickedSong!.path!);
    final songRef = FirebaseStorage.instance.ref().child(songPath);

    setState(() {
      uploadTask = songRef.putFile(songFile);
    });

    final songSnapshot = await uploadTask!.whenComplete(() {});
    final songUrlDownload = await songSnapshot.ref.getDownloadURL();

    print('Song download Link:  $songUrlDownload');
    setState(() {
      uploadTask = null;
    });

    DatabaseReference newSongRef = dbRef.push();
    await newSongRef.set({
      "imageUrl": imageUrlDownload,
      "songUrl": songUrlDownload,
      "artistName": artistName.text,
      "songName": songName.text,
      "type": songType.text,
      'userId': currentUser!.uid,
      "like": 0,
      "listened": 0
    });
  }

  // Future uploadSong() async {
  //   final path =
  // }

  Future selectImage() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedImage = result.files.first;
    });
  }

  void selectSong() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedSong = result.files.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tải âm thanh lên'),
        actions: [
            IconButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => 
              const MyApp() 
              ));
            }, 
            icon: const Icon(Icons.cloud_upload_rounded)),
          ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              ElevatedButton(
                onPressed: () => selectImage(),
                child: const Text("Select Image", style: TextStyle(color: Colors.white)),
              ),
              if (pickedImage != null)
                Expanded(
                    child: Container(
                        color: Colors.blue[200],
                        height: 10,
                        child: Center(
                          child: Text(pickedImage!.name),
                        ))),
              ElevatedButton(
                onPressed: () => selectSong(),
                child: const Text("Select Songs", style: TextStyle(color: Colors.white)),
              ),
              if (pickedSong != null)
                Expanded(
                    child: Container(
                        color: Colors.blue[200],
                        height: 10,
                        child: Center(
                          child: Text(pickedSong!.name),
                        ))),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                child: TextField(
                  controller: songName,
                  decoration: const InputDecoration(hintText: "Tên bài nhạc"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                child: TextField(
                  controller: artistName,
                  decoration: const InputDecoration(hintText: "Tên ca sĩ"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                child: TextField(
                  controller: songType,
                  decoration: const InputDecoration(hintText: "Thể loại"),
                ),
              ),
              ElevatedButton(onPressed: upload, child: const Text("Upload", style: TextStyle(color: Colors.white))),
              buildProgress(),
            ],
          ),
        ),
      
      )
    );
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;
          return SizedBox(
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey,
                  color: Colors.green,
                ),
                Center(
                  child: Text(
                    '${(100 * progress).roundToDouble()}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          );
        } else {
          return const SizedBox(height: 50);
        }
      });
}
