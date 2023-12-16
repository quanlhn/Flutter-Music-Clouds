import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_clouds/models/SongInfos.dart';
import 'package:flutter_music_clouds/screens/PlaylistPlayer.dart';
import 'package:flutter_music_clouds/screens/Songs.dart';
import 'package:flutter_music_clouds/screens/Upload.dart';
import 'package:flutter_music_clouds/widgets/inheritedWidget.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final alldata;
  late List<SongInfo> songs = [];
  late List<SongInfo> playList = [];

  @override
  void initState() {
    super.initState();

    getSongs();
    getPlaylist();
    // getData();

    DatabaseReference songInfosRef =
        FirebaseDatabase.instance.ref('app/songInfos');
    songInfosRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot;
      print('data changed');
      final List<SongInfo> t_songs = [];
      for (DataSnapshot dataSnapshot in data.children) {
        // print(dataSnapshot.child('songName').value);
        String songName = dataSnapshot.child('songName').value.toString();
        String imageUrl = dataSnapshot.child('imageUrl').value.toString();
        String artistName = dataSnapshot.child('artistName').value.toString();
        String songUrl = dataSnapshot.child('songUrl').value.toString();
        final newSong = SongInfo(songName, imageUrl, songUrl, artistName);

        t_songs.add(newSong);
      }
      setState(() {
        songs = t_songs;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    
    super.dispose();
  }

  Future getSongs() async {
    // if (alldata == null) {
    //   setState(() {
    //     alldata = {};
    //   });
    // }
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('app/songInfos').get();
    if (snapshot.exists) {
      final List<SongInfo> t_songs = [];
      for (DataSnapshot dataSnapshot in snapshot.children) {
        // print(dataSnapshot.child('songName').value);
        String songName = dataSnapshot.child('songName').value.toString();
        String imageUrl = dataSnapshot.child('imageUrl').value.toString();
        String artistName = dataSnapshot.child('artistName').value.toString();
        String songUrl = dataSnapshot.child('songUrl').value.toString();
        final newSong = SongInfo(songName, imageUrl, songUrl, artistName);

        t_songs.add(newSong);
      }
      setState(() {
        alldata = snapshot.value;
        songs = t_songs;
      });
    } else {
      print('No data available.');
    }
    return snapshot;
  }

  Future getPlaylist() async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child('app/songInfos');
    final snapshot =
        await ref.orderByChild('artistName').equalTo('Den vau').once();
    if (snapshot.snapshot.exists) {
      final List<SongInfo> t_songs = [];
      for (DataSnapshot dataSnapshot in snapshot.snapshot.children) {
        // print(dataSnapshot.child('songName').value);
        String songName = dataSnapshot.child('songName').value.toString();
        String imageUrl = dataSnapshot.child('imageUrl').value.toString();
        String artistName = dataSnapshot.child('artistName').value.toString();
        String songUrl = dataSnapshot.child('songUrl').value.toString();
        final newSong = SongInfo(songName, imageUrl, songUrl, artistName);
        t_songs.add(newSong);
      }
      setState(() {
        // alldata = snapshot.snapshot.value;
        print(t_songs[0].imageUrl);
        playList = t_songs;
      });
    } else {
      print('No data available.');
    }
    return snapshot.snapshot;
  }

  String replaceCharAt(String oldString, int index, String newChar) {
    return oldString.substring(0, index) +
        newChar +
        oldString.substring(index + 1);
  }

  @override
  Widget build(BuildContext fatherContext) {
    return Padding(
      padding: EdgeInsets.fromLTRB(2, 10, 2, 10),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              FutureBuilder(
                  future: getSongs(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return SizedBox(
                        height: 270,
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.0),
                              child: const Text(
                                'Bài mới',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: songs.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 150,
                                    child: InkWell(
                                      onTap: () => Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        final myInheritedWidget =
                                            MyInheritedWidget.of(fatherContext);
                                        if (myInheritedWidget == null) {
                                          return Text(
                                              'MyInheritedWidget was not found');
                                        }
                                        return MyInheritedWidget(
                                          count: myInheritedWidget.count,
                                          player: myInheritedWidget.player,
                                          child: Songspage(
                                              songs[songs.length - 1 - index],
                                              myInheritedWidget.player),
                                        );
                                      })),
                                      child: Card(
                                          elevation: 10.0,
                                          // Padding áp dụng trực tiếp cho Card
                                          margin: EdgeInsets.all(10),
                                          child: Column(
                                            children: [
                                              Image.network(
                                                songs[songs.length - 1 - index]
                                                    .imageUrl,
                                                width: 140.0,
                                                height: 125.0,
                                                fit: BoxFit.cover,
                                              ),
                                              ListTile(
                                                title: Text(
                                                  songs[songs.length - 1 - index]
                                                      .songName,
                                                  style: const TextStyle(
                                                      fontSize: 12.0),
                                                ),
                                                subtitle: Text(
                                                  songs[songs.length - 1 - index]
                                                      .artistName,
                                                  style: const TextStyle(
                                                      fontSize: 8.0),
                                                ),
                                              )
                                              // Text(
                                              //   songs[songs.length - 1 - index].songName,
                                              //   style: const TextStyle(fontSize: 20.0),
                                              // ),
                                            ],
                                          )),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }),
              
              FutureBuilder(
                  future: getSongs(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return SizedBox(
                        height: 270,
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.0),
                              child: const Text(
                                'Bài mới',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 1,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 150,
                                    child: InkWell(
                                      onTap: () => Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        final myInheritedWidget =
                                            MyInheritedWidget.of(fatherContext);
                                        if (myInheritedWidget == null) {
                                          return Text(
                                              'MyInheritedWidget was not found');
                                        }
                                        return MyInheritedWidget(
                                          count: myInheritedWidget.count,
                                          player: myInheritedWidget.player,
                                          // child: Songspage(
                                          //     songs[songs.length - 1 - index],
                                          //     myInheritedWidget.player),
                                          child: PlaylistPlayer(myInheritedWidget.player, playList),
                                        );
                                      })),
                                      child: Card(
                                          elevation: 10.0,
                                          // Padding áp dụng trực tiếp cho Card
                                          margin: EdgeInsets.all(10),
                                          child: Column(
                                            children: [
                                              Image.network(
                                                songs[songs.length - 1 - index]
                                                    .imageUrl,
                                                width: 140.0,
                                                height: 125.0,
                                                fit: BoxFit.cover,
                                              ),
                                              ListTile(
                                                title: Text(
                                                  songs[songs.length - 1 - index]
                                                      .songName,
                                                  style: const TextStyle(
                                                      fontSize: 12.0),
                                                ),
                                                subtitle: Text(
                                                  songs[songs.length - 1 - index]
                                                      .artistName,
                                                  style: const TextStyle(
                                                      fontSize: 8.0),
                                                ),
                                              )
                                              // Text(
                                              //   songs[songs.length - 1 - index].songName,
                                              //   style: const TextStyle(fontSize: 20.0),
                                              // ),
                                            ],
                                          )),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }),

              // FutureBuilder(
              //     future: getPlaylist(),
              //     builder: (context, snapshot) {
              //       if (snapshot.connectionState == ConnectionState.waiting) {
              //         return Center(
              //           child: CircularProgressIndicator(),
              //         );
              //       } else {
              //         return SizedBox(
              //           height: 270,
              //           child: Column(
              //             children: [
              //               Container(
              //                 padding: EdgeInsets.all(10.0),
              //                 child: const Text(
              //                   'List nổi bật',
              //                   style: TextStyle(
              //                     fontSize: 20,
              //                     fontWeight: FontWeight.bold,
              //                   ),
              //                 ),
              //               ),
              //               Expanded(
              //                 child: ListView.builder(
              //                   scrollDirection: Axis.horizontal,
              //                   itemCount: 1,
              //                   itemBuilder: (context, index) {
              //                     return Container(
              //                       width: 150,
              //                       child: InkWell(
              //                         onTap: () => Navigator.push(context,
              //                             MaterialPageRoute(builder: (context) {
              //                           final myInheritedWidget =
              //                               MyInheritedWidget.of(fatherContext);
              //                           if (myInheritedWidget == null) {
              //                             return Text(
              //                                 'MyInheritedWidget was not found');
              //                           }
              //                           return MyInheritedWidget(
              //                             count: myInheritedWidget.count,
              //                             player: myInheritedWidget.player,
              //                             // child: Songspage(songs[songs.length - 1 - index], myInheritedWidget.player),
              //                             child: PlaylistPlayer(
              //                                 myInheritedWidget.player, playList),
              //                           );
              //                         })),
              //                         child: Card(
              //                             elevation: 10.0,
              //                             // Padding áp dụng trực tiếp cho Card
              //                             margin: EdgeInsets.all(10),
              //                             child: Column(
              //                               children: [
              //                                 Image.network(
              //                                   playList[0].imageUrl,
              //                                   width: 140.0,
              //                                   height: 125.0,
              //                                   fit: BoxFit.cover,
              //                                 ),
              //                                 ListTile(
              //                                   title: Text(
              //                                     '${playList[0].artistName} play list',
              //                                     style: const TextStyle(
              //                                         fontSize: 12.0),
              //                                   ),
              //                                   subtitle: Text(playList[0].artistName, style: const TextStyle(fontSize: 8.0),),
              //                                 )
              //                                 // Text(
              //                                 //   songs[songs.length - 1 - index].songName,
              //                                 //   style: const TextStyle(fontSize: 20.0),
              //                                 // ),
              //                               ],
              //                             )),
              //                       ),
              //                     );
              //                   },
              //                 ),
              //               ),
              //             ],
              //           ),
              //         );
              //       }
              //     }),
            
            ],
          ),
        )
      ),
    );
  }
}
