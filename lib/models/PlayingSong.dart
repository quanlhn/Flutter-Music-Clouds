import 'package:flutter_music_clouds/models/SongInfos.dart';

class PlayingSong {
  bool isAppPlaying = false;
  SongInfo? songInfo;
  List<SongInfo> listSong;

  PlayingSong(this.isAppPlaying, {SongInfo? songInfo, List<SongInfo>? listSong})
      : songInfo = songInfo ?? SongInfo('', '', '', '', -1, -1, ''), // Sử dụng null-aware operator
        listSong = listSong ?? [];
}
