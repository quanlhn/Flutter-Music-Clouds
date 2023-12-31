import 'package:audio_session/audio_session.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_music_clouds/models/Const.dart';
import 'package:flutter_music_clouds/models/PlayingSong.dart';
import 'package:flutter_music_clouds/models/SongInfos.dart';
import 'package:flutter_music_clouds/screens/Songs.dart';
import 'package:flutter_music_clouds/widgets/colorScheme.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_music_clouds/models/commonJustAudio.dart';
import 'package:rxdart/rxdart.dart';

class PlaylistPlayer extends StatefulWidget {
  // SongInfo songInfo;
  final AudioPlayer _player;
  List<SongInfo> playlistInfo;
  bool changeList;

  PlaylistPlayer(this._player, this.changeList, this.playlistInfo, {super.key});

  @override
  State<PlaylistPlayer> createState() => _PlaylistPlayerState();
}

class _PlaylistPlayerState extends State<PlaylistPlayer>
    with WidgetsBindingObserver {
  bool isFavorite = false;
  @override
  void initState() {
    super.initState();
    ambiguate(WidgetsBinding.instance)!.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _init();
  }

  int _addedCount = 0;
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  late AudioPlayer _player;
  late final ConcatenatingAudioSource _playlist =
      ConcatenatingAudioSource(children: [
    for (var i = 0; i < widget.playlistInfo.length; i++)
      AudioSource.uri(
        Uri.parse(widget.playlistInfo[i].songUrl),
        tag: AudioMetadata(
          album: widget.playlistInfo[i].artistName,
          title: widget.playlistInfo[i].songName,
          artwork: widget.playlistInfo[i].imageUrl,
          like: widget.playlistInfo[i].like,
          listened: widget.playlistInfo[i].listened,
          type: widget.playlistInfo[i].type,
        ),
      ),
  ]);

  Future<void> _init() async {
    _player = widget._player;

    print(widget._player.currentIndex);
    if (widget.changeList) {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
      // Listen to errors during playback.
      widget._player.playbackEventStream.listen((event) {},
          onError: (Object e, StackTrace stackTrace) {
        print('A stream error occurred: $e');
      });
      try {
        // Preloading audio is not currently supported on Linux.
        await widget._player.setAudioSource(_playlist,
            preload: kIsWeb || defaultTargetPlatform != TargetPlatform.linux);
      } catch (e) {
        // Catch load errors: 404, invalid url...
        print("Error loading audio source: $e");
      }
      // Show a snackbar whenever reaching the end of an item in the playlist.
      widget._player.positionDiscontinuityStream.listen((discontinuity) {
        if (discontinuity.reason == PositionDiscontinuityReason.autoAdvance) {
          _showItemFinished(discontinuity.previousEvent.currentIndex);
        }
      });
      widget._player.processingStateStream.listen((state) {
        if (state == ProcessingState.completed) {
          _showItemFinished(widget._player.currentIndex);
        }
      });
      updateUser(0);
      print(widget._player.currentIndex);
      checkSongFavorite(widget._player.currentIndex).then((value) => {
            setState(() {
              isFavorite = value;
            })
          });
    }
  }

  Future<String> getSongId(index) async {
    try {
      DatabaseReference songRef =
          FirebaseDatabase.instance.ref().child('app/songInfos');
      final songSnapshot = await songRef
          .orderByChild('songUrl')
          .equalTo(widget.playlistInfo[index].songUrl)
          .once();

      Map<dynamic, dynamic> songMap =
          songSnapshot.snapshot.value as Map<dynamic, dynamic>;
      // print(songMap.keys.first);
      return songMap.keys.first;
    } catch (error) {
      return ('Lỗi: $error');
    }
  }

  Future<bool> checkSongFavorite(index) async {
    try {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref().child('app/users');
      final snapshot =
          await ref.orderByChild('id').equalTo(currentUser!.uid).once();
      String favoriteSongs = (snapshot.snapshot.children.first
          .child('playlist/favorite')
          .value) as String;
      String songId = await getSongId(index);
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

  void addToFavorite(index) async {
    try {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref().child('app/users');
      final snapshot =
          await ref.orderByChild('id').equalTo(currentUser!.uid).once();
      // print(snapshot.snapshot.children.first.child('playlist/favorite').value);
      String songId = await getSongId(index);
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

  void removeFromFavorite(index) async {
    try {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref().child('app/users');
      final snapshot =
          await ref.orderByChild('id').equalTo(currentUser!.uid).once();
      // print(snapshot.snapshot.children.first.child('playlist/favorite').value);
      if (snapshot.snapshot.exists) {
        String songId = await getSongId(index);
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

  void _showItemFinished(int? index) {
    if (index == null) return;
    final sequence = widget._player.sequence;
    if (sequence == null) return;
    final source = sequence[index];
    final metadata = source.tag as AudioMetadata;
    _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text('Finished playing ${metadata.title}'),
      duration: const Duration(seconds: 1),
    ));
  }

  void updateUser(index) async {
    try {
      // ----------- Lấy id của song --------------------//
      DatabaseReference songRef =
          FirebaseDatabase.instance.ref().child('app/songInfos');
      final songSnapshot = await songRef
          .orderByChild('songUrl')
          .equalTo(widget.playlistInfo[index].songUrl)
          .once();

      Map<dynamic, dynamic> songMap =
          songSnapshot.snapshot.value as Map<dynamic, dynamic>;
      print(songMap.keys.first);

      // ----------- Update trường recentPlayed --------------------//
      DatabaseReference ref =
          FirebaseDatabase.instance.ref().child('app/users');
      final snapshot =
          await ref.orderByChild('id').equalTo(currentUser!.uid).once();

      if (snapshot.snapshot.exists) {
        Map<dynamic, dynamic> userMap =
            snapshot.snapshot.value as Map<dynamic, dynamic>;
        print(snapshot.snapshot.children.first.child('recentPlayed').value);
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

  @override
  void dispose() {
    ambiguate(WidgetsBinding.instance)!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      widget._player.stop();
    }
  }

  void getTagForItem(int index) async {
    if (index >= 0 && index < widget.playlistInfo.length) {
      updateUser(index);

      print(widget._player.currentIndex);
      checkSongFavorite(widget._player.currentIndex).then((value) => {
            setState(() {
              isFavorite = value;
            })
          });

      final audioSource = _playlist.children[index];
      final metadata = (audioSource as UriAudioSource).tag as AudioMetadata;
      print('Artistname: ${metadata.album}'); //artistname
      print('SongName: ${metadata.title}'); //songName
      print('imageUrl: ${metadata.artwork}'); //imageUrl
      print(audioSource.uri.toString());
      setState(() {
        playingSong = PlayingSong(true);
        playingSong.songInfo = SongInfo(
            metadata.title,
            metadata.artwork,
            audioSource.uri.toString(),
            metadata.album,
            metadata.like,
            metadata.listened,
            metadata.type);
        playingSong.listSong = widget.playlistInfo;
      });
    } else {
      print('Index out of bounds.');
    }
  }

  SongInfo getCurrentSong() {
    int nonNullIndex = _player.currentIndex ?? 0;
    final audioSource = _playlist.children[nonNullIndex];
    final metadata = (audioSource as UriAudioSource).tag as AudioMetadata;
    return SongInfo(
      metadata.title,
      metadata.artwork,
      audioSource.uri.toString(),
      metadata.album,
      metadata.like,
      metadata.listened,
      metadata.type);
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      theme: ThemeData(
        colorScheme: MyColorScheme.darkColorScheme,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: StreamBuilder<SequenceState?>(
                  stream: _player.sequenceStateStream,
                  builder: (context, snapshot) {
                    final state = snapshot.data;
                    if (state?.sequence.isEmpty ?? true) {
                      return const SizedBox();
                    }
                    final metadata = state!.currentSource!.tag as AudioMetadata;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                                Center(child: Image.network(metadata.artwork)),
                          ),
                        ),
                        Text(metadata.album,
                            style: Theme.of(context).textTheme.titleLarge),
                        Text(metadata.title),
                      ],
                    );
                  },
                ),
              ),
              //Các nút điều hướng
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (isFavorite) {
                        // remove favorite
                        removeFromFavorite(widget._player.currentIndex);
                      } else {
                        // add favorite
                        addToFavorite(widget._player.currentIndex);
                      }
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                    },
                    icon: isFavorite
                        ? const Icon(Icons.favorite)
                        : const Icon(Icons.favorite_border),
                  ),
                  ControlButtons(_player),
                  PopupMenuButton<String>(
                    onSelected: (String result) {
                      if (result == 'showBottomSheet') {
                        // Khi chọn mục trong PopupMenu, hiển thị bottom sheet
                        _showBottomSheet(context, getCurrentSong());
                      }
                    },
                    tooltip: 'Thêm',
                    icon: const Icon(Icons.more_horiz),
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'showBottomSheet',
                        child: Text('Show Bottom Sheet'),
                      ),
                    ],
                  ),
                ],
              ),

              // Thanh progress bar
              StreamBuilder<PositionData>(
                stream: _positionDataStream,
                builder: (context, snapshot) {
                  final positionData = snapshot.data;
                  return SeekBar(
                    duration: positionData?.duration ?? Duration.zero,
                    position: positionData?.position ?? Duration.zero,
                    bufferedPosition:
                        positionData?.bufferedPosition ?? Duration.zero,
                    onChangeEnd: (newPosition) {
                      _player.seek(newPosition);
                    },
                  );
                },
              ),
              const SizedBox(height: 8.0),

              // Loop mode
              Row(
                children: [
                  StreamBuilder<LoopMode>(
                    stream: _player.loopModeStream,
                    builder: (context, snapshot) {
                      final loopMode = snapshot.data ?? LoopMode.off;
                      const icons = [
                        Icon(Icons.repeat, color: Colors.grey),
                        Icon(Icons.repeat, color: Colors.orange),
                        Icon(Icons.repeat_one, color: Colors.orange),
                      ];
                      const cycleModes = [
                        LoopMode.off,
                        LoopMode.all,
                        LoopMode.one,
                      ];
                      final index = cycleModes.indexOf(loopMode);
                      return IconButton(
                        icon: icons[index],
                        onPressed: () {
                          _player.setLoopMode(cycleModes[
                              (cycleModes.indexOf(loopMode) + 1) %
                                  cycleModes.length]);
                        },
                      );
                    },
                  ),
                  Expanded(
                    child: Text(
                      "Playlist",
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  //bài tiếp ngẫu nhiên hay lần lượt
                  StreamBuilder<bool>(
                    stream: _player.shuffleModeEnabledStream,
                    builder: (context, snapshot) {
                      final shuffleModeEnabled = snapshot.data ?? false;
                      return IconButton(
                        icon: shuffleModeEnabled
                            ? const Icon(Icons.shuffle, color: Colors.orange)
                            : const Icon(Icons.shuffle, color: Colors.grey),
                        onPressed: () async {
                          final enable = !shuffleModeEnabled;
                          if (enable) {
                            await _player.shuffle();
                          }
                          await _player.setShuffleModeEnabled(enable);
                        },
                      );
                    },
                  ),
                ],
              ),

              // danh sách các bài trong playlist
              SizedBox(
                height: 240.0,
                child: StreamBuilder<SequenceState?>(
                  stream: _player.sequenceStateStream,
                  builder: (context, snapshot) {
                    final state = snapshot.data;
                    final sequence = state?.sequence ?? [];
                    return ReorderableListView(
                      onReorder: (int oldIndex, int newIndex) {
                        if (oldIndex < newIndex) newIndex--;
                        _playlist.move(oldIndex, newIndex);
                      },
                      children: [
                        for (var i = 0; i < sequence.length; i++)
                          Dismissible(
                            key: ValueKey(sequence[i]),
                            background: Container(
                              color: Colors.redAccent,
                              alignment: Alignment.centerRight,
                              child: const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                            ),
                            onDismissed: (dismissDirection) {
                              _playlist.removeAt(i);
                            },
                            child: Material(
                              color: i == state!.currentIndex
                                  ? MyColorScheme.darkColorScheme.surface
                                  : Colors.black54,
                              child: Container(
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.white54)),
                                  child: ListTile(
                                    title:
                                        Text(sequence[i].tag.title as String),
                                    onTap: () {
                                      getTagForItem(i);
                                      _player.seek(Duration.zero, index: i);
                                    },
                                  )),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   child: const Icon(Icons.add),
        //   onPressed: () {
        //     _playlist.add(AudioSource.uri(
        //       Uri.parse("asset:///audio/nature.mp3"),
        //       tag: AudioMetadata(
        //         album: "Public Domain",
        //         title: "Nature Sounds ${++_addedCount}",
        //         artwork:
        //             "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
        //       ),
        //     ));
        //   },
        // ),
      ),
    );
  }
}

class ControlButtons extends StatefulWidget {
  final AudioPlayer player;
  const ControlButtons(this.player, {super.key});

  @override
  State<ControlButtons> createState() => _ControlButtonsState();
}

class _ControlButtonsState extends State<ControlButtons> {
  late bool _isFavorite;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        StreamBuilder<SequenceState?>(
          stream: widget.player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
            icon: const Icon(Icons.skip_previous),
            onPressed:
                widget.player.hasPrevious ? widget.player.seekToPrevious : null,
          ),
        ),
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
                onPressed: () => widget.player.seek(Duration.zero,
                    index: widget.player.effectiveIndices!.first),
              );
            }
          },
        ),
        StreamBuilder<SequenceState?>(
          stream: widget.player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: widget.player.hasNext ? widget.player.seekToNext : null,
          ),
        ),
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
      ],
    );
  }
}

class AudioMetadata {
  final String album;
  final String title;
  final String artwork;
  int like;
  int listened;
  String type;
  AudioMetadata(
      {required this.album,
      required this.title,
      required this.artwork,
      required this.like,
      required this.listened,
      required this.type});
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
