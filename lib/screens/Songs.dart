// import 'package:audio_waveforms/audio_waveforms.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_clouds/models/Const.dart';
import 'package:flutter_music_clouds/models/SongInfos.dart';
import 'package:flutter_music_clouds/models/commonJustAudio.dart';
import 'package:flutter_music_clouds/widgets/inheritedWidget.dart';
// import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:velocity_x/velocity_x.dart';

enum SampleItem { itemOne, itemTwo, itemThree }

class Songspage extends StatefulWidget {
  SongInfo songInfo;
  bool changeSong;
  final AudioPlayer _player;

  Songspage(this.songInfo, this.changeSong, this._player, {super.key});
  @override
  _SongspageState createState() => _SongspageState();
}

class _SongspageState extends State<Songspage> {
  // final _player = AudioPlayer();

  // PlayerController controller = PlayerController();
  late String path;
  // late Directory? directory;

  var isPlaying = false;
  // Duration _currentPosition = Duration.zero;
  double volumn = 0.5;

  void updateIsAppPlaying(BuildContext context) {
    final myInheritedWidget = MyInheritedWidget.of(context);
    if (myInheritedWidget != null) {
      myInheritedWidget.updateIsAppPlaying(true);
    }
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getSongId() async {
    try {
      DatabaseReference songRef =
          FirebaseDatabase.instance.ref().child('app/songInfos');
      final songSnapshot = await songRef
          .orderByChild('songUrl')
          .equalTo(widget.songInfo.songUrl)
          .once();

      Map<dynamic, dynamic> songMap =
          songSnapshot.snapshot.value as Map<dynamic, dynamic>;
      // print(songMap.keys.first);
      return songMap.keys.first;
    } catch (error) {
      return ('Lỗi: $error');
    }
  }

  void addToFavorite() async {
    try {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref().child('app/users');
      final snapshot =
          await ref.orderByChild('id').equalTo(currentUser!.uid).once();

      if (snapshot.snapshot.exists) {
        Map<dynamic, dynamic> userMap =
            snapshot.snapshot.value as Map<dynamic, dynamic>;
        await ref.update({
          "${userMap.keys.first}/playlist/favorite":
              "${getSongId()},${snapshot.snapshot.children.first.child('playlist/favorite').value}"
        });
        print('Đã cập nhật favourite cho user ${currentUser!.uid}');
      } else {
        print('Không tìm thấy user với id ${currentUser!.uid}');
      }
    } catch (error) {
      print('Lỗi: $error');
    }
  }

  Future<int> getCountListened() async {
    var id = await getSongId();

    final songRef = FirebaseDatabase.instance.ref();
    final songSnapshot = await songRef.child('app/songInfos/$id').get();
    if (songSnapshot.exists) {
      return songSnapshot.child('listened').value as int;
    } else {
      print('No snapshot');
    }

    return -1;
  }

  void updateListened() async {
    try {
      // ----------- Lấy id của song --------------------//
      DatabaseReference songRef =
          FirebaseDatabase.instance.ref().child('app/songInfos');
      final songSnapshot = await songRef
          .orderByChild('songUrl')
          .equalTo(widget.songInfo.songUrl)
          .once();

      Map<dynamic, dynamic> songMap =
          songSnapshot.snapshot.value as Map<dynamic, dynamic>;

      int currentListened = await getCountListened();
      print('count listened: ${currentListened}');

      if (currentListened != -1) {
        await songRef.update({
          "${songMap.keys.first.toString()}/listened": currentListened + 1,
        });
      }

      // DatabaseReference countListenedRef = FirebaseDatabase.instance.ref();
      // print('songMap.keys.firs: ${songMap.keys.first}');
      // final listenedSnapshot = await countListenedRef
      //     .child('app/songinfos/${songMap.keys.first}')
      //     .get();

      // if (listenedSnapshot.exists) {
      //   int currentListened = listenedSnapshot.child('listened') as int;
      //   print('count listened: ${currentListened}');
      //   await songRef.update({
      //     "listened": 2,
      //   });
      // } else {
      //   print('no snapshot for listened');
      // }
    } catch (error) {
      print('Lỗi: $error');
    }
  }

  void updateUser() async {
    try {
      // ----------- Lấy id của song --------------------//
      DatabaseReference songRef =
          FirebaseDatabase.instance.ref().child('app/songInfos');
      final songSnapshot = await songRef
          .orderByChild('songUrl')
          .equalTo(widget.songInfo.songUrl)
          .once();

      Map<dynamic, dynamic> songMap =
          songSnapshot.snapshot.value as Map<dynamic, dynamic>;
      // print(songMap.keys.first);

      // ----------- Update trường recentPlayed --------------------//
      DatabaseReference ref =
          FirebaseDatabase.instance.ref().child('app/users');
      final snapshot =
          await ref.orderByChild('id').equalTo(currentUser!.uid).once();

      if (snapshot.snapshot.exists) {
        Map<dynamic, dynamic> userMap =
            snapshot.snapshot.value as Map<dynamic, dynamic>;
        // print(snapshot.snapshot.children.first.child('recentPlayed').value);
        userMap['recentPlay'] = 'hihi';
        await ref.update({
          "${userMap.keys.first}/recentPlayed":
              "${songMap.keys.first},${snapshot.snapshot.children.first.child('recentPlayed').value}"
        });
        print('Đã cập nhật recentPlayed cho user ${currentUser!.uid}');
      } else {
        print('Không tìm thấy user với id ${currentUser!.uid}');
      }
    } catch (error) {
      print('Lỗi: $error');
    }
  }

  Future<void> initPlatformState() async {
    if (widget.changeSong) {
      updateListened();
      updateUser();
      // print(MyInheritedWidget.of(context)!.count);
      // print(widget._player.audioSource);
      widget._player.stop();
      // final duration = await widget._player.setUrl(widget.songInfo.songUrl);
      await widget._player.setLoopMode(LoopMode.one);
      // widget._player.play();
      final myInheritedWidget = MyInheritedWidget.of(context);
      if (myInheritedWidget == null) {
        print('no myinheritedwidget');
      } else {
        print('player is ${myInheritedWidget.player.playing}');
        // setState(() {
        //   myInheritedWidget.player = true;
        // });
      }
      setState(() {
        isPlaying = true;
        widget._player.setUrl(widget.songInfo.songUrl);
        widget._player.play();
      });
    } else {}
  }

  void showVolumeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        // double volumeValue = 0.5;
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: volumn,
                onChanged: (value) {
                  // Xử lý khi giá trị Slider thay đổi
                  // print(value);
                  setState(() {
                    volumn = value;
                  });
                  // print(volumn);
                },
                activeColor: Theme.of(context).colorScheme.onSecondary,
              ),
            ],
          ),
        );
      },
    );
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          widget._player.positionStream,
          widget._player.bufferedPositionStream,
          widget._player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MusicPlayer App"),
      ),
      resizeToAvoidBottomInset: true,
      body: Center(
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: <Widget>[
            // Image.network(widget.songInfo.imageUrl),
            // const SizedBox(
            //   height: 10.0,
            // ),
            Card(
              elevation: 10.0,
              child: Image.network(
                widget.songInfo.imageUrl,
                height: 250.0,
              ),
            ),
            Text(
              widget.songInfo.songName,
              style: const TextStyle(fontSize: 25.0),
            ),
            Text(
              widget.songInfo.artistName,
              style: const TextStyle(fontSize: 15.0),
            ),
            const SizedBox(
              height: 10.0,
            ),
            StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return SeekBar(
                  duration: positionData?.duration ?? Duration.zero,
                  position: positionData?.position ?? Duration.zero,
                  bufferedPosition:
                      positionData?.bufferedPosition ?? Duration.zero,
                  onChangeEnd: widget._player.seek,
                );
              },
            ),
            ControlButtons(widget._player, widget.songInfo),
          ],
        ),
      )),
    );
  }
}

class ControlButtons extends StatefulWidget {
  final AudioPlayer player;
  final SongInfo songInfo;

  const ControlButtons(this.player, this.songInfo, {Key? key})
      : super(key: key);

  @override
  _ControlButtonsState createState() => _ControlButtonsState();
}

class _ControlButtonsState extends State<ControlButtons> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkSongFavorite().then((value) => {
          setState(() {
            isFavorite = value;
          })
        });
  }

  Future<String> getSongId() async {
    try {
      DatabaseReference songRef =
          FirebaseDatabase.instance.ref().child('app/songInfos');
      final songSnapshot = await songRef
          .orderByChild('songUrl')
          .equalTo(widget.songInfo.songUrl)
          .once();

      Map<dynamic, dynamic> songMap =
          songSnapshot.snapshot.value as Map<dynamic, dynamic>;
      // print(songMap.keys.first);
      return songMap.keys.first;
    } catch (error) {
      return ('Lỗi: $error');
    }
  }

  Future<bool> checkSongFavorite() async {
    try {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref().child('app/users');
      final snapshot =
          await ref.orderByChild('id').equalTo(currentUser!.uid).once();
      String favoriteSongs = (snapshot.snapshot.children.first
          .child('playlist/favorite')
          .value) as String;
      String songId = await getSongId();
      if (favoriteSongs.contains(songId)) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print('Lỗi: $error');
      return false;
    }
  }

  void addToFavorite() async {
    try {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref().child('app/users');
      final snapshot =
          await ref.orderByChild('id').equalTo(currentUser!.uid).once();
      // print(snapshot.snapshot.children.first.child('playlist/favorite').value);
      String songId = await getSongId();
      if (snapshot.snapshot.exists) {
        Map<dynamic, dynamic> userMap =
            snapshot.snapshot.value as Map<dynamic, dynamic>;
        await ref.update({
          "${userMap.keys.first}/playlist/favorite":
              "$songId,${snapshot.snapshot.children.first.child('playlist/favorite').value}"
        });
        print('Đã cập nhật favourite cho user ${currentUser!.uid}');
      } else {
        print('Không tìm thấy user với id ${currentUser!.uid}');
      }
    } catch (error) {
      print('Lỗi: $error');
    }
  }

  void removeFromFavorite() async {
    try {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref().child('app/users');
      final snapshot =
          await ref.orderByChild('id').equalTo(currentUser!.uid).once();
      // print(snapshot.snapshot.children.first.child('playlist/favorite').value);
      if (snapshot.snapshot.exists) {
        String songId = await getSongId();
        String originFavorite = snapshot.snapshot.children.first
            .child('playlist/favorite')
            .value as String;
        String newFavorite =
            originFavorite.replaceAll(originFavorite, '$songId,');
        Map<dynamic, dynamic> userMap =
            snapshot.snapshot.value as Map<dynamic, dynamic>;
        await ref
            .update({"${userMap.keys.first}/playlist/favorite": newFavorite});
        print('Đã cập nhật favourite cho user ${currentUser!.uid}');
      } else {
        print('Không tìm thấy user với id ${currentUser!.uid}');
      }
    } catch (error) {
      print('Lỗi: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            if (isFavorite) {
              // remove favorite
              removeFromFavorite();
            } else {
              // add favorite
              addToFavorite();
            }
            setState(() {
              isFavorite = !isFavorite;
            });
          },
          icon: isFavorite
              ? const Icon(Icons.favorite)
              : const Icon(Icons.favorite_border),
        ),

        const SizedBox(
          width: 20.0,
        ),

        // Opens volume slider dialog
        IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () {
            showSliderDialog(
              context: context,
              title: "Adjust volume",
              divisions: 10,
              min: 0.0,
              max: 1.0,
              value: widget.player.volume,
              stream: widget.player.volumeStream,
              onChanged: widget.player.setVolume,
            );
          },
        ),

        /// This StreamBuilder rebuilds whenever the player state changes, which
        /// includes the playing/paused state and also the
        /// loading/buffering/ready state. Depending on the state we show the
        /// appropriate button or loading indicator.
        StreamBuilder<PlayerState>(
          stream: widget.player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 64.0,
                onPressed: widget.player.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.pause),
                iconSize: 64.0,
                onPressed: widget.player.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 64.0,
                onPressed: () => widget.player.seek(Duration.zero),
              );
            }
          },
        ),
        // Opens speed slider dialog
        StreamBuilder<double>(
          stream: widget.player.speedStream,
          builder: (context, snapshot) => IconButton(
            icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              showSliderDialog(
                context: context,
                title: "Adjust speed",
                divisions: 10,
                min: 0.5,
                max: 1.5,
                value: widget.player.speed,
                stream: widget.player.speedStream,
                onChanged: widget.player.setSpeed,
              );
            },
          ),
        ),

        const SizedBox(
          width: 20.0,
        ),

        // IconButton(
        //   icon: const Icon(Icons.more_horiz),
        //   onPressed: () {},
        // )

        PopupMenuButton<String>(
          onSelected: (String result) {
            if (result == 'showBottomSheet') {
              // Khi chọn mục trong PopupMenu, hiển thị bottom sheet
              _showBottomSheet(context, widget.songInfo);
            }
          },
          tooltip: 'Thêm',
          icon: const Icon(Icons.more_horiz),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'showBottomSheet',
              child: Text('Show Bottom Sheet'),
            ),
          ],
        ),
      ],
    );
  }
}

void _showBottomSheet(BuildContext context, SongInfo songInfo) {
  Future<List<MapEntry>> getAllPlayList() async {
    try {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref().child('app/users');
      final snapshot =
          await ref.orderByChild('id').equalTo(currentUser!.uid).once();
      if (snapshot.snapshot.exists) {
        Map<dynamic, dynamic> userMap =
            snapshot.snapshot.value as Map<dynamic, dynamic>;
        // for (var item in userMap.values) {
        //   print(item.toString());
        //   print(item.runtimeType);
        // }
        Map<dynamic, dynamic> valueMap =
            userMap.values.firstOrNull as Map<dynamic, dynamic>;
        for (var item in valueMap.entries) {
          if (item.key == 'playlist') {
            // print(item.value.toString());
            var playlists = item.value as Map<dynamic, dynamic>;
            List<MapEntry<dynamic, dynamic>> returnResult =
                playlists.entries.toList();
            // for (var list in playlists.entries) {
            //   print(list.key);
            //   print(list.value);
            // }
            return returnResult;
          }
        }
      } else {
        print('Không tìm thấy user với id ${currentUser!.uid}');
      }
    } catch (error) {}
    print('playlist');
    return [];
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SizedBox(
        height: 450.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey[300], fontSize: 14.0),
                    ),
                  ),
                  Text(
                    'Add to playlist',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20.0),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showNestedModal(context, songInfo);
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    iconSize: 24.0,
                  )
                ],
              ),
              Expanded(
                  child: FutureBuilder<List<MapEntry>>(
                future: getAllPlayList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // hoặc widget loading khác
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No data available');
                  } else {
                    // Nếu dữ liệu có sẵn, hiển thị GridView
                    List<MapEntry> playlists = snapshot.data!;
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: playlists.length,
                      itemBuilder: (context, index) {
                        MapEntry<dynamic, dynamic> playlist = playlists[index];
                        return PlayListCard(playlist, songInfo);
                      },
                    );
                  }
                },
              ))
            ],
          ),
        ),
      );
    },
  );
}



class PlayListCard extends StatelessWidget {
  final MapEntry<dynamic, dynamic> list;
  final SongInfo songInfo;

  const PlayListCard(this.list, this.songInfo, {super.key});

  Future<String> getImageUrl() async {
    var id = list.value.toString().split(',')[0];

    final songRef = FirebaseDatabase.instance.ref();
    final songSnapshot = await songRef.child('app/songInfos/$id').get();
    if (songSnapshot.exists) {
      return songSnapshot.child('imageUrl').value.toString();
    } else {
      print('No snapshot');
    }

    return '';
  }

  Future<String> getSongId() async {
    try {
      DatabaseReference songRef =
          FirebaseDatabase.instance.ref().child('app/songInfos');
      final songSnapshot = await songRef
          .orderByChild('songUrl')
          .equalTo(songInfo.songUrl)
          .once();

      Map<dynamic, dynamic> songMap =
          songSnapshot.snapshot.value as Map<dynamic, dynamic>;
      // print(songMap.keys.first);
      return songMap.keys.first;
    } catch (error) {
      return ('Lỗi: $error');
    }
  }

  void addToAlbum() async {
    try {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref().child('app/users');
      final snapshot =
          await ref.orderByChild('id').equalTo(currentUser!.uid).once();
      // print(
      //     snapshot.snapshot.children.first.child('playlist/${list.key}').value);
      String songId = await getSongId();
      if (snapshot.snapshot.exists) {
        Map<dynamic, dynamic> userMap =
            snapshot.snapshot.value as Map<dynamic, dynamic>;
        await ref.update({
          "${userMap.keys.first}/playlist/${list.key}":
              "$songId,${snapshot.snapshot.children.first.child('playlist/${list.key}').value}"
        });
        print('Đã cập nhật favourite cho user ${currentUser!.uid}');
      } else {
        print('Không tìm thấy user với id ${currentUser!.uid}');
      }
    } catch (error) {
      print('Lỗi: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getImageUrl(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          String imageUrl =
              snapshot.data ?? ''; // Lấy giá trị hoặc giá trị mặc định

          return GestureDetector(
            onTap: () {
              addToAlbum();
              VxToast.show(context,
                msg: "Đã thêm vào album");
              Navigator.of(context).pop();
            },
            child: Container(
              child: Card(
                color: Colors.white30,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.network(
                        imageUrl,
                        height: 120.0,
                        width: 120.0,
                      ),
                      Text('${list.key}'),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          // Trạng thái đang đợi
          return const CircularProgressIndicator();
        } else {
          // Trạng thái khác (lỗi hoặc null)
          return Container(); // hoặc có thể thay thế bằng một Widget thông báo lỗi
        }
      },
    );
  }
}

void showNestedModal(BuildContext context, SongInfo songInfo) {
  TextEditingController playlistName = TextEditingController();

  Future<String> getSongId() async {
    try {
      DatabaseReference songRef =
          FirebaseDatabase.instance.ref().child('app/songInfos');
      final songSnapshot = await songRef
          .orderByChild('songUrl')
          .equalTo(songInfo.songUrl)
          .once();

      Map<dynamic, dynamic> songMap =
          songSnapshot.snapshot.value as Map<dynamic, dynamic>;
      // print(songMap.keys.first);
      return songMap.keys.first;
    } catch (error) {
      return ('Lỗi: $error');
    }
  }

  void createPlaylist() async {
    try {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref().child('app/users');
      final snapshot =
          await ref.orderByChild('id').equalTo(currentUser!.uid).once();
      String songId = await getSongId();
      if (snapshot.snapshot.exists) {
        Map<dynamic, dynamic> userMap =
            snapshot.snapshot.value as Map<dynamic, dynamic>;
        await ref.update(
            {"${userMap.keys.first}/playlist/${playlistName.text}": songId});
        print('Đã cập nhật favourite cho user ${currentUser!.uid}');
      } else {
        print('Không tìm thấy user với id ${currentUser!.uid}');
      }
    } catch (error) {
      print('Lỗi: $error');
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SingleChildScrollView(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20.0,
              right: 20.0,
              top: 10.0),
          child: SizedBox(
            height: 300.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Cancel',
                        style:
                            TextStyle(color: Colors.grey[300], fontSize: 14.0),
                      ),
                    ),
                    Text(
                      'Add to playlist',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 20.0),
                    ),
                    IconButton(
                      onPressed: () {
                        createPlaylist();
                        VxToast.show(context,
                          msg: "Tạo album mới thành công");
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.add_circle),
                      iconSize: 24.0,
                    )
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      songInfo.imageUrl,
                      height: 150,
                    ),
                    SizedBox(
                      width: 200.0,
                      child: TextField(
                        controller: playlistName,
                      ),
                    )
                  ],
                )
              ],
            ),
          ));
    },
  );
}
