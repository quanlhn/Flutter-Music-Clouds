import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_clouds/models/Const.dart';
import 'package:flutter_music_clouds/models/PlayingSong.dart';
import 'package:flutter_music_clouds/models/SongInfos.dart';
import 'package:flutter_music_clouds/screens/Songs.dart';
import 'package:flutter_music_clouds/widgets/inheritedWidget.dart';

class FavoriteSongs extends StatefulWidget {
  const FavoriteSongs({super.key});

  @override
  State<FavoriteSongs> createState() => _FavoriteSongsState();
}

class _FavoriteSongsState extends State<FavoriteSongs> {
  @override
  void initState() {
    super.initState();
    // addToFavorite();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<String>> getFavoriteIds() async {
    try {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref().child('app/users');
      final snapshot =
          await ref.orderByChild('id').equalTo(currentUser!.uid).once();
      // print(snapshot.snapshot.children.first.child('playlist/favorite').value);
      // String songId = await getSongId();
      if (snapshot.snapshot.exists) {
        Map<dynamic, dynamic> userMap =
            snapshot.snapshot.value as Map<dynamic, dynamic>;
        // await ref.update({
        //   "${userMap.keys.first}/playlist/favorite":
        //       "$songId,${snapshot.snapshot.children.first.child('playlist/favorite').value}"
        // });
        print(
            snapshot.snapshot.children.first.child('playlist/favorite').value);
        List<String> favoriteSongs = snapshot.snapshot.children.first
            .child('playlist/favorite')
            .value
            .toString()
            .split(',');
        return favoriteSongs.where((element) => element != '' && element != 'null').toList();
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
          title: Text('Đã thích'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: FutureBuilder(
            future: getFavoriteIds(),
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

class SongCard extends StatelessWidget {
  final SongInfo songInfo;

  SongCard({required this.songInfo});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 90.0,
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Image.network(
              songInfo.imageUrl,
              height: 64.0,
              width: 64.0,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    songInfo.artistName,
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                  Text(
                    songInfo.songName,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    'Listened: ${songInfo.listened}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
