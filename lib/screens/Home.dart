import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_clouds/models/Const.dart';
import 'package:flutter_music_clouds/models/PlayingSong.dart';
import 'package:flutter_music_clouds/models/SongInfos.dart';
import 'package:flutter_music_clouds/models/commonJustAudio.dart';
import 'package:flutter_music_clouds/screens/PlaylistPlayer.dart';
import 'package:flutter_music_clouds/screens/Songs.dart';
import 'package:flutter_music_clouds/widgets/inheritedWidget.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final alldata;
  late List<SongInfo> songs = [];
  late List<SongInfo> playList = [];
  late List<SongInfo> recentPlayed = [];
  late List<SongInfo> songAsType = [];
  // late SongInfo playingSong = {} as SongInfo;

  @override
  void initState() {
    super.initState();
    // print(currentUser);
    getRecentPlayedSongs();
    getPlaylist();
    getSongsAsType();
    // getData();

    DatabaseReference songInfosRef =
        FirebaseDatabase.instance.ref('app/songInfos');
    songInfosRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot;
      final List<SongInfo> tSongs = [];
      for (DataSnapshot dataSnapshot in data.children) {
        // print(dataSnapshot.child('songName').value);
        String songName = dataSnapshot.child('songName').value.toString();
        String imageUrl = dataSnapshot.child('imageUrl').value.toString();
        String artistName = dataSnapshot.child('artistName').value.toString();
        String songUrl = dataSnapshot.child('songUrl').value.toString();
        final newSong = SongInfo(songName, imageUrl, songUrl, artistName);

        tSongs.add(newSong);
      }
      if (mounted) {
        setState(() {
          songs = tSongs;
        });
      }
    });
    listenDatabase();
  }

  Future listenDatabase() async {
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child('app/users');
    final snapshot =
        await userRef.orderByChild('id').equalTo('${currentUser!.uid}').once();
    Map<dynamic, dynamic> userMap =
        snapshot.snapshot.value as Map<dynamic, dynamic>;
    DatabaseReference userListened = FirebaseDatabase.instance
        .ref()
        .child('app/users/${userMap.keys.first}');
    userListened.onValue.listen((event) {
      getRecentPlayedSongs();
      print('user`s recent played changed');
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  Future getRecentPlayedSongs() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('app/users');
    final snapshot =
        await ref.orderByChild('id').equalTo('${currentUser!.uid}').once();
    // print(snapshot.snapshot.children.first
    //     .child('recentPlayed')
    //     .value
    //     .toString()
    //     .split(','));

    final recentSongIds = snapshot.snapshot.children.first
        .child('recentPlayed')
        .value
        .toString()
        .split(',')
        .toSet()
        .toList();
    final List<SongInfo> recentSongs = [];
    for (String id in recentSongIds) {
      final songRef = FirebaseDatabase.instance.ref();
      final songSnapshot = await songRef.child('app/songInfos/${id}').get();
      if (songSnapshot.exists) {
        String songName = songSnapshot.child('songName').value.toString();
        String imageUrl = songSnapshot.child('imageUrl').value.toString();
        String artistName = songSnapshot.child('artistName').value.toString();
        String songUrl = songSnapshot.child('songUrl').value.toString();
        final newSong = SongInfo(songName, imageUrl, songUrl, artistName);
        recentSongs.add(newSong);
      } else {
        print('no snapshot');
      }
    }
    setState(() {
      recentPlayed = recentSongs;
    });

    return recentSongs;
  }

  Future getSongs() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('app/songInfos').get();
    if (snapshot.exists) {
      final List<SongInfo> tSongs = [];
      for (DataSnapshot dataSnapshot in snapshot.children) {
        // print(dataSnapshot.child('songName').value);
        String songName = dataSnapshot.child('songName').value.toString();
        String imageUrl = dataSnapshot.child('imageUrl').value.toString();
        String artistName = dataSnapshot.child('artistName').value.toString();
        String songUrl = dataSnapshot.child('songUrl').value.toString();
        final newSong = SongInfo(songName, imageUrl, songUrl, artistName);

        tSongs.add(newSong);
      }
      setState(() {
        alldata = snapshot.value;
        songs = tSongs;
      });
    } else {
      print('No data available.');
    }
    return snapshot;
  }

  Future getSongsAsType() async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child('app/songInfos');
    final snapshot = await ref.orderByChild('type').equalTo('Kpop').once();
    if (snapshot.snapshot.exists) {
      final List<SongInfo> tSongs = [];
      for (DataSnapshot dataSnapshot in snapshot.snapshot.children) {
        // print(dataSnapshot.child('songName').value);
        String songName = dataSnapshot.child('songName').value.toString();
        String imageUrl = dataSnapshot.child('imageUrl').value.toString();
        String artistName = dataSnapshot.child('artistName').value.toString();
        String songUrl = dataSnapshot.child('songUrl').value.toString();
        final newSong = SongInfo(songName, imageUrl, songUrl, artistName);
        tSongs.add(newSong);
      }
      setState(() {
        print(tSongs[0].imageUrl);
        songAsType = tSongs;
      });
    } else {
      print('No data available.');
    }
    return snapshot.snapshot;
  }

  Future getPlaylist() async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child('app/songInfos');
    final snapshot =
        await ref.orderByChild('artistName').equalTo('Den vau').once();
    if (snapshot.snapshot.exists) {
      final List<SongInfo> tSongs = [];
      for (DataSnapshot dataSnapshot in snapshot.snapshot.children) {
        // print(dataSnapshot.child('songName').value);
        String songName = dataSnapshot.child('songName').value.toString();
        String imageUrl = dataSnapshot.child('imageUrl').value.toString();
        String artistName = dataSnapshot.child('artistName').value.toString();
        String songUrl = dataSnapshot.child('songUrl').value.toString();
        final newSong = SongInfo(songName, imageUrl, songUrl, artistName);
        tSongs.add(newSong);
      }
      setState(() {
        print(tSongs[0].imageUrl);
        playList = tSongs;
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

  Widget _buildPlaybackStatusWidget(fatherContext) {
    final myInheritedWidget = MyInheritedWidget.of(context);
    if (myInheritedWidget == null) {
      return Text('no inheritedwidget');
    }

    Stream<PositionData> _positionDataStream =
        Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
            myInheritedWidget.player.positionStream,
            myInheritedWidget.player.bufferedPositionStream,
            myInheritedWidget.player.durationStream,
            (position, bufferedPosition, duration) => PositionData(
                position, bufferedPosition, duration ?? Duration.zero));

    if (playingSong.isAppPlaying) {
      return Column(
        children: [
          Container(
            height: 40.0, // Điều chỉnh độ cao theo ý muốn
            color: Colors.black45,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Play/pause
                StreamBuilder<PlayerState>(
                  stream: myInheritedWidget.player.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final processingState = playerState?.processingState;
                    final playing = playerState?.playing;
                    if (processingState == ProcessingState.loading ||
                        processingState == ProcessingState.buffering) {
                      return Container(
                        margin: const EdgeInsets.all(8.0),
                        width: 40.0,
                        height: 40.0,
                        child: const CircularProgressIndicator(),
                      );
                    } else if (playing != true) {
                      return IconButton(
                        icon: const Icon(Icons.play_arrow),
                        iconSize: 30.0,
                        onPressed: myInheritedWidget.player.play,
                      );
                    } else if (processingState != ProcessingState.completed) {
                      return IconButton(
                        icon: const Icon(Icons.pause),
                        iconSize: 30.0,
                        onPressed: myInheritedWidget.player.pause,
                      );
                    } else {
                      return IconButton(
                        icon: const Icon(Icons.replay),
                        iconSize: 30.0,
                        onPressed: () =>
                            myInheritedWidget.player.seek(Duration.zero),
                      );
                    }
                  },
                ),
                // Name
                if (playingSong.songInfo != null &&
                    playingSong.listSong.length == 0)
                  InkWell(
                      onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            final myInheritedWidget =
                                MyInheritedWidget.of(fatherContext);

                            if (myInheritedWidget == null) {
                              return const Text(
                                  'MyInheritedWidget was not found');
                            }
                            myInheritedWidget.updateIsAppPlaying(true);
                            return MyInheritedWidget(
                              isAppPlaying: myInheritedWidget.isAppPlaying,
                              player: myInheritedWidget.player,
                              child: Songspage(playingSong.songInfo!, false,
                                  myInheritedWidget.player),
                            );
                          })),
                      child: Column(
                        children: [
                          Text(playingSong.songInfo!.songName),
                          Text(playingSong.songInfo!.artistName),
                        ],
                      )),

                if (playingSong.listSong.length > 0)
                  InkWell(
                      onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            final myInheritedWidget =
                                MyInheritedWidget.of(fatherContext);

                            if (myInheritedWidget == null) {
                              return const Text(
                                  'MyInheritedWidget was not found');
                            }
                            myInheritedWidget.updateIsAppPlaying(true);
                            return MyInheritedWidget(
                              isAppPlaying: myInheritedWidget.isAppPlaying,
                              player: myInheritedWidget.player,
                              child: PlaylistPlayer(myInheritedWidget.player, false, playingSong.listSong),
                            );
                          })),
                      child: Column(
                        children: [
                          Text(playingSong.songInfo!.songName),
                          Text(playingSong.songInfo!.artistName),
                        ],
                      )),

                IconButton(
                  icon: Icon(Icons.favorite_outline),
                  onPressed: () {
                    // Xử lý sự kiện nhấn nút pause
                    myInheritedWidget.player.pause();
                  },
                ),
                // Thêm các biểu tượng hoặc thông tin khác ở đây
              ],
            ),
          ),
          StreamBuilder<PositionData>(
            stream: _positionDataStream,
            builder: (context, snapshot) {
              final positionData = snapshot.data;
              return MiniSeekBar(
                duration: positionData?.duration ?? Duration.zero,
                position: positionData?.position ?? Duration.zero,
                bufferedPosition:
                    positionData?.bufferedPosition ?? Duration.zero,
                onChangeEnd: myInheritedWidget.player.seek,
              );
            },
          ),
        ],
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext fatherContext) {
    final myInheritedWidget = MyInheritedWidget.of(fatherContext);
    if (myInheritedWidget == null) {
      return Text('no inheritedwidget');
    }

    return MyInheritedWidget(
        isAppPlaying: myInheritedWidget.isAppPlaying,
        player: myInheritedWidget.player,
        child: Column(children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2, 10, 2, 10),
              child: Center(
                  child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    // recented play
                    Container(
                      height: 270,
                      decoration:
                          BoxDecoration(color: Color.fromARGB(255, 31, 29, 29)),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10.0),
                            child: const Text(
                              'Nghe gần đây',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: recentPlayed.length,
                              itemBuilder: (context, index) {
                                return SizedBox(
                                  width: 150,
                                  child: InkWell(
                                    onTap: () => Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      final myInheritedWidget =
                                          MyInheritedWidget.of(fatherContext);

                                      if (myInheritedWidget == null) {
                                        return const Text(
                                            'MyInheritedWidget was not found');
                                      }
                                      myInheritedWidget
                                          .updateIsAppPlaying(true);
                                      return MyInheritedWidget(
                                        isAppPlaying:
                                            myInheritedWidget.isAppPlaying,
                                        player: myInheritedWidget.player,
                                        child: Songspage(recentPlayed[index],
                                            true, myInheritedWidget.player),
                                      );
                                    })).then((value) => setState(() {
                                          playingSong = new PlayingSong(true,
                                              songInfo: recentPlayed[0]);
                                        })),
                                    child: Card(
                                        elevation: 10.0,
                                        // Padding áp dụng trực tiếp cho Card
                                        margin: const EdgeInsets.all(10),
                                        child: Column(
                                          children: [
                                            Image.network(
                                              recentPlayed[index].imageUrl,
                                              width: 140.0,
                                              height: 125.0,
                                              fit: BoxFit.cover,
                                            ),
                                            ListTile(
                                              title: Text(
                                                recentPlayed[index].songName,
                                                style: const TextStyle(
                                                    fontSize: 12.0),
                                              ),
                                              subtitle: Text(
                                                recentPlayed[index].artistName,
                                                style: const TextStyle(
                                                    fontSize: 8.0),
                                              ),
                                            )
                                          ],
                                        )),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      height: 30.0,
                    ),

                    //recomend category

                    //  Container(
                    //   height: 270,
                    //   decoration:
                    //       BoxDecoration(color: Color.fromARGB(255, 31, 29, 29)),
                    //   child: Column(
                    //     children: [
                    //       Container(
                    //         padding: const EdgeInsets.all(10.0),
                    //         child: const Text(
                    //           'Recommend Category',
                    //           style: TextStyle(
                    //             fontSize: 20,
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    //         ),
                    //       ),
                    //       Expanded(
                    //         child: ListView.builder(
                    //           scrollDirection: Axis.horizontal,
                    //           itemCount: 1,
                    //           itemBuilder: (context, index) {
                    //             return SizedBox(
                    //               width: 150,
                    //               child: InkWell(
                    //                 onTap: () => Navigator.push(context,
                    //                     MaterialPageRoute(
                    //                         builder: (context) {
                    //                   final myInheritedWidget =
                    //                       MyInheritedWidget.of(
                    //                           fatherContext);
                    //                   if (myInheritedWidget == null) {
                    //                     return const Text(
                    //                         'MyInheritedWidget was not found');
                    //                   }
                    //                   return MyInheritedWidget(
                    //                     isAppPlaying: myInheritedWidget
                    //                         .isAppPlaying,
                    //                     player:
                    //                         myInheritedWidget.player,
                    //                     // child: Songspage(
                    //                     //     songs[songs.length - 1 - index],
                    //                     //     myInheritedWidget.player),
                    //                     child: PlaylistPlayer(
                    //                         myInheritedWidget.player,
                    //                         songAsType),
                    //                   );
                    //                 })),
                    //                 child: Card(
                    //                     elevation: 10.0,
                    //                     // Padding áp dụng trực tiếp cho Card
                    //                     margin:
                    //                         const EdgeInsets.all(10),
                    //                     child: Column(
                    //                       children: [
                    //                         Image.network(
                    //                           songAsType[0].imageUrl,
                    //                           width: 140.0,
                    //                           height: 125.0,
                    //                           fit: BoxFit.cover,
                    //                         ),
                    //                         ListTile(
                    //                           title: Text(
                    //                             songAsType[0].songName,
                    //                             style: const TextStyle(
                    //                                 fontSize: 12.0),
                    //                           ),
                    //                           subtitle: Text(
                    //                             songAsType[0].artistName,
                    //                             style: const TextStyle(
                    //                                 fontSize: 8.0),
                    //                           ),
                    //                         )
                    //                         // Text(
                    //                         //   songs[songs.length - 1 - index].songName,
                    //                         //   style: const TextStyle(fontSize: 20.0),
                    //                         // ),
                    //                       ],
                    //                     )),
                    //               ),
                    //             );
                    //           },
                    //         ),
                    //       ),
                    //     ],
                    //   ),

                    // ),

                    // FutureBuilder(
                    //     future: getRecentPlayedSongs(),
                    //     builder: (context, snapshot) {
                    //       if (snapshot.connectionState ==
                    //           ConnectionState.waiting) {
                    //         return const Center(
                    //           child: CircularProgressIndicator(),
                    //         );
                    //       } else {
                    //         return SizedBox(
                    //           height: 270,
                    //           child: Column(
                    //     children: [
                    //       Container(
                    //         padding: const EdgeInsets.all(10.0),
                    //         child: const Text(
                    //           'Recommend Category',
                    //           style: TextStyle(
                    //             fontSize: 20,
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    //         ),
                    //       ),
                    //       Expanded(
                    //         child: ListView.builder(
                    //           scrollDirection: Axis.horizontal,
                    //           itemCount: 1,
                    //           itemBuilder: (context, index) {
                    //             return SizedBox(
                    //               width: 150,
                    //               child: InkWell(
                    //                 onTap: () => Navigator.push(context,
                    //                     MaterialPageRoute(
                    //                         builder: (context) {
                    //                   final myInheritedWidget =
                    //                       MyInheritedWidget.of(
                    //                           fatherContext);
                    //                   if (myInheritedWidget == null) {
                    //                     return const Text(
                    //                         'MyInheritedWidget was not found');
                    //                   }
                    //                   return MyInheritedWidget(
                    //                     isAppPlaying: myInheritedWidget
                    //                         .isAppPlaying,
                    //                     player:
                    //                         myInheritedWidget.player,
                    //                     // child: Songspage(
                    //                     //     songs[songs.length - 1 - index],
                    //                     //     myInheritedWidget.player),
                    //                     child: PlaylistPlayer(
                    //                         myInheritedWidget.player,
                    //                         songAsType),
                    //                   );
                    //                 })),
                    //                 child: Card(
                    //                     elevation: 10.0,
                    //                     // Padding áp dụng trực tiếp cho Card
                    //                     margin:
                    //                         const EdgeInsets.all(10),
                    //                     child: Column(
                    //                       children: [
                    //                         Image.network(
                    //                           songAsType[0].imageUrl,
                    //                           width: 140.0,
                    //                           height: 125.0,
                    //                           fit: BoxFit.cover,
                    //                         ),
                    //                         ListTile(
                    //                           title: Text(
                    //                             songAsType[0].songName,
                    //                             style: const TextStyle(
                    //                                 fontSize: 12.0),
                    //                           ),
                    //                           subtitle: Text(
                    //                             songAsType[0].artistName,
                    //                             style: const TextStyle(
                    //                                 fontSize: 8.0),
                    //                           ),
                    //                         )
                    //                         // Text(
                    //                         //   songs[songs.length - 1 - index].songName,
                    //                         //   style: const TextStyle(fontSize: 20.0),
                    //                         // ),
                    //                       ],
                    //                     )),
                    //               ),
                    //             );
                    //           },
                    //         ),
                    //       ),
                    //     ],
                    //   ),

                    //         );
                    //       }
                    //     }),

                    Container(
                      height: 30.0,
                    ),

                    //Bài mới
                    FutureBuilder(
                        future: getSongs(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            return Container(
                              height: 270,
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 31, 29, 29)),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10.0),
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
                                        return SizedBox(
                                          width: 150,
                                          child: InkWell(
                                            onTap: () => Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              final myInheritedWidget =
                                                  MyInheritedWidget.of(
                                                      fatherContext);

                                              if (myInheritedWidget == null) {
                                                return const Text(
                                                    'MyInheritedWidget was not found');
                                              }
                                              myInheritedWidget
                                                  .updateIsAppPlaying(true);
                                              return MyInheritedWidget(
                                                isAppPlaying: myInheritedWidget
                                                    .isAppPlaying,
                                                player:
                                                    myInheritedWidget.player,
                                                child: Songspage(
                                                    songs[songs.length -
                                                        1 -
                                                        index],
                                                    true,
                                                    myInheritedWidget.player),
                                              );
                                            })).then((value) => setState(() {
                                                  playingSong = new PlayingSong(
                                                      true,
                                                      songInfo: songs[
                                                          songs.length -
                                                              1 -
                                                              index]);
                                                })),
                                            child: Card(
                                                elevation: 10.0,
                                                // Padding áp dụng trực tiếp cho Card
                                                margin:
                                                    const EdgeInsets.all(10),
                                                child: Column(
                                                  children: [
                                                    Image.network(
                                                      songs[songs.length -
                                                              1 -
                                                              index]
                                                          .imageUrl,
                                                      width: 140.0,
                                                      height: 125.0,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    ListTile(
                                                      title: Text(
                                                        songs[songs.length -
                                                                1 -
                                                                index]
                                                            .songName,
                                                        style: const TextStyle(
                                                            fontSize: 12.0),
                                                      ),
                                                      subtitle: Text(
                                                        songs[songs.length -
                                                                1 -
                                                                index]
                                                            .artistName,
                                                        style: const TextStyle(
                                                            fontSize: 8.0),
                                                      ),
                                                    )
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
                    //Danh sách mới
                    FutureBuilder(
                        future: getSongs(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            return SizedBox(
                              height: 270,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10.0),
                                    child: const Text(
                                      'Nghệ sĩ mới nổi',
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
                                        return SizedBox(
                                          width: 150,
                                          child: InkWell(
                                            onTap: () => Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              final myInheritedWidget =
                                                  MyInheritedWidget.of(
                                                      fatherContext);
                                              if (myInheritedWidget == null) {
                                                return const Text(
                                                    'MyInheritedWidget was not found');
                                              }
                                              return MyInheritedWidget(
                                                isAppPlaying: myInheritedWidget
                                                    .isAppPlaying,
                                                player:
                                                    myInheritedWidget.player,
                                                // child: Songspage(
                                                //     songs[songs.length - 1 - index],
                                                //     myInheritedWidget.player),
                                                child: PlaylistPlayer(
                                                    myInheritedWidget.player, true,
                                                    playList),
                                              );
                                            })).then((value) => setState(() {
                                                  playingSong.isAppPlaying =
                                                      true;
                                                  playingSong.songInfo =
                                                      playList[0];
                                                  playingSong.listSong =
                                                      playList;
                                                })),
                                            child: Card(
                                                elevation: 10.0,
                                                // Padding áp dụng trực tiếp cho Card
                                                margin:
                                                    const EdgeInsets.all(10),
                                                child: Column(
                                                  children: [
                                                    Image.network(
                                                      playList[0].imageUrl,
                                                      width: 140.0,
                                                      height: 125.0,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    ListTile(
                                                      title: Text(
                                                        playList[0].songName,
                                                        style: const TextStyle(
                                                            fontSize: 12.0),
                                                      ),
                                                      subtitle: Text(
                                                        playList[0].artistName,
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

                    Container(
                      height: 150,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                          color: Colors.deepOrange[200],
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20.0))),
                    ),
                  ],
                ),
              )),
            ),
          ),
          Container(child: _buildPlaybackStatusWidget(fatherContext)),
        ]));
  }
}
