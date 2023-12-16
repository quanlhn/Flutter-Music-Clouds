import 'dart:io';
import 'dart:ui';

// import 'package:audio_waveforms/audio_waveforms.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_clouds/models/SongInfos.dart';
import 'package:flutter_music_clouds/models/commonJustAudio.dart';
import 'package:flutter_music_clouds/widgets/colorScheme.dart';
import 'package:flutter_music_clouds/widgets/inheritedWidget.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class Songspage extends StatefulWidget {
  SongInfo songInfo;
  AudioPlayer _player;

  Songspage(this.songInfo, this._player);
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

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initPlatformState() async {
    // print(MyInheritedWidget.of(context)!.count);
    widget._player.stop();
    final duration = await widget._player.setUrl(widget.songInfo.songUrl);
    await widget._player.setLoopMode(LoopMode.one);
    widget._player.play();
    setState(() {
      isPlaying = true;
    });
    // widget._player.positionStream.listen((position) {
    //   setState(() {
    //     _currentPosition = position;
    //   });
    // });
    // directory = await getDownloadsDirectory();
    // path = widget.songInfo.songUrl;
    // print('SONG URL: ${path}');

    // await controller.preparePlayer(
    //     path: path, shouldExtractWaveform: true, noOfSamples: 100, volume: 1.0);
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
                  print(volumn);
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
            SizedBox(
              height: 10.0,
            ),
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     // Hiển thị thanh tiến trình
            //     Slider(
            //       value: widget._player.position.inMilliseconds.toDouble(),
            //       min: 0.0,
            //       max: widget._player.duration?.inMilliseconds?.toDouble() ??
            //           0.0,
            //       onChanged: (value) {
            //         // Điều khiển tiến trình khi người dùng vuốt thanh trượt
            //         widget._player.seek(Duration(milliseconds: value.toInt()));
            //       },
            //       activeColor: Theme.of(context).colorScheme.onSecondary,
            //     ),

            //     // Hiển thị thời gian hiện tại / tổng thời gian
            //     Text(
            //       '${widget._player.position} / ${widget._player.duration}',
            //     ),
            //   ],
            // ),
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
            ControlButtons(widget._player)
          ],
        ),
      )),
    );
  }
}

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
              value: player.volume,
              stream: player.volumeStream,
              onChanged: player.setVolume,
            );
          },
        ),

        /// This StreamBuilder rebuilds whenever the player state changes, which
        /// includes the playing/paused state and also the
        /// loading/buffering/ready state. Depending on the state we show the
        /// appropriate button or loading indicator.
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
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
                onPressed: player.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.pause),
                iconSize: 64.0,
                onPressed: player.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 64.0,
                onPressed: () => player.seek(Duration.zero),
              );
            }
          },
        ),
        // Opens speed slider dialog
        StreamBuilder<double>(
          stream: player.speedStream,
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
                value: player.speed,
                stream: player.speedStream,
                onChanged: player.setSpeed,
              );
            },
          ),
        ),
      ],
    );
  }
}
