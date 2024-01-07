import "package:firebase_database/firebase_database.dart";
import "package:flutter/material.dart";
import "package:flutter_music_clouds/models/Const.dart";
import "package:flutter_music_clouds/models/PlayingSong.dart";
import "package:flutter_music_clouds/models/SongInfos.dart";
import "package:flutter_music_clouds/screens/Songs.dart";
import "package:flutter_music_clouds/screens/library/favorite.dart";
import "package:flutter_music_clouds/widgets/inheritedWidget.dart";

class Uploaded extends StatefulWidget {
  const Uploaded({super.key});

  @override
  State<Uploaded> createState() => _UploadedState();
}

class _UploadedState extends State<Uploaded> {
  @override
  void initState() {
    super.initState();
    // addToFavorite();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<String>> getUploadedIds() async {
    try {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref().child('app/songInfos');
      final snapshot =
          await ref.orderByChild('userId').equalTo(currentUser!.uid).once();
      // print(snapshot.snapshot.children.first.child('playlist/favorite').value);
      // String songId = await getSongId();
      if (snapshot.snapshot.exists) {
        Map<dynamic, dynamic> songsMap =
            snapshot.snapshot.value as Map<dynamic, dynamic>;
        // await ref.update({
        //   "${userMap.keys.first}/playlist/favorite":
        //       "$songId,${snapshot.snapshot.children.first.child('playlist/favorite').value}"
        // });
        print(
            songsMap.keys.toList());
        List<String> favoriteSongs = snapshot.snapshot.children.first
            .child('playlist/favorite')
            .value
            .toString()
            .split(',');
        return songsMap.keys.map((e) => e.toString()).toList();
      } else {
        print('Không tìm thấy user với id ${currentUser!.uid}');
      }
    } catch (error) {
      print('Lỗi: $error');
    }
    return [];
  }

  Future<SongInfo> getSongInfo(String id) async {
    SongInfo songInfo = SongInfo('', '', '', '', -1, -1, '');

    final songRef = FirebaseDatabase.instance.ref();
    final songSnapshot = await songRef.child('app/songInfos/$id').get();
    if (songSnapshot.exists) {
      return SongInfo(
          songSnapshot.child('songName').value.toString(),
          songSnapshot.child('imageUrl').value.toString(),
          songSnapshot.child('songUrl').value.toString(),
          songSnapshot.child('artistName').value.toString(),
          songSnapshot.child('like').value as int,
          songSnapshot.child('listened').value as int,
          songSnapshot.child('type').value.toString());
    } else {
      print('No snapshot');
    }

    return songInfo;
  }

  @override
  Widget build(BuildContext context) {
    final myInheritedWidget = MyInheritedWidget.of(context);
    if (myInheritedWidget == null) {
      return const Text('no inheritedwidget');
    }
    return Scaffold(
        appBar: AppBar(
          title: Text('Đã tải lên'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: FutureBuilder(
            future: getUploadedIds(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                List<String> data = snapshot.data!;
                return Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 16.0, 10.0, 16.0),
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder(
                        future: getSongInfo(data[index]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else {
                            var song =
                                snapshot.data ?? SongInfo('', '', '', '', -1, -1, '');
                            return Container(
                              height: 90.0,
                              margin: EdgeInsets.all(8.0),
                              color: Theme.of(context).colorScheme.surface,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    myInheritedWidget.updateIsAppPlaying(true);
                                    return MyInheritedWidget(
                                      isAppPlaying:
                                          myInheritedWidget.isAppPlaying,
                                      player: myInheritedWidget.player,
                                      child: Songspage(
                                          song, true, myInheritedWidget.player),
                                    );
                                  }))
                                  .then((value) => setState(() {
                                    playingSong = PlayingSong(true,
                                    songInfo: song);
                                  }));
                                },
                                child: SongCard(songInfo: song),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                );
              }
            }));
  }
}