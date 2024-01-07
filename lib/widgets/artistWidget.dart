import 'package:flutter/material.dart';
import 'package:flutter_music_clouds/models/Const.dart';
import 'package:flutter_music_clouds/models/SongInfos.dart';
import 'package:flutter_music_clouds/screens/PlaylistPlayer.dart';
import 'package:flutter_music_clouds/widgets/inheritedWidget.dart';
import 'package:firebase_database/firebase_database.dart';

class ArtistWidget extends StatefulWidget {
  final String artist;

  ArtistWidget({required this.artist});

  @override
  _ArtistWidgetState createState() => _ArtistWidgetState();
}

class _ArtistWidgetState extends State<ArtistWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDataFromFirebase();
  }

  String genreImageUrl =
      'https://firebasestorage.googleapis.com/v0/b/musiccloud-8eaa8.appspot.com/o/artist-images%2Fden-120521.jpg?alt=media&token=c8fc2527-3d6a-4dcd-bd3c-f2a443b37c88'; // Ảnh đại diện của bài hát đầu tiên
  String genreName = ''; // Tên của thể loại nhạc
  List<SongInfo> listSong = [];
  final databaseReference = FirebaseDatabase.instance.ref();

  Future<List<SongInfo>> fetchDataFromFirebase() async {
    // Thực hiện logic để lấy thông tin từ Firebase Realtime Database
    // Đặc biệt là ảnh đại diện của bài hát đầu tiên và tên thể loại
    // Cập nhật giá trị của genreImageUrl và genreName
    // print(widget.artist);
    final searchSnapshot = await databaseReference
        .child('app/songInfos')
        .orderByChild('lowerCaseArtistName')
        .startAt(widget.artist.toLowerCase())
        .endAt('${widget.artist.toLowerCase()}\uf8ff')
        .get();
    if (searchSnapshot.exists) {
      final List<SongInfo> tSongs = [];
      for (DataSnapshot dataSnapshot in searchSnapshot.children) {
        // print(dataSnapshot.child('songName').value.toString());
        // print(dataSnapshot.child('songName').value);
        String songName = dataSnapshot.child('songName').value.toString();
        String imageUrl = dataSnapshot.child('imageUrl').value.toString();
        String artistName = dataSnapshot.child('artistName').value.toString();
        String songUrl = dataSnapshot.child('songUrl').value.toString();
        int like = dataSnapshot.child('like').value as int;
        int listened = dataSnapshot.child('listened').value as int;
        String type = dataSnapshot.child('type').value.toString();
        final newSong = SongInfo(
            songName, imageUrl, songUrl, artistName, like, listened, type);

        tSongs.add(newSong);
      }
      if (mounted) {
        setState(() {
          listSong = tSongs;
          genreImageUrl = tSongs[0].imageUrl;
          genreName = tSongs[0].type;
        });
      }
      return tSongs;
    } else {
      print('No favorite data available.');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final myInheritedWidget = MyInheritedWidget.of(context);
    if (myInheritedWidget == null) {
      return const Text('no inheritedwidget');
    }
    return Padding(
      padding: EdgeInsets.all(14),
      child: GestureDetector(
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (context) {
          return MyInheritedWidget(
            isAppPlaying: myInheritedWidget.isAppPlaying,
            player: myInheritedWidget.player,
            child: PlaylistPlayer(myInheritedWidget.player, true, listSong),
          );
        })).then((value) {
          if (mounted) {
            setState(() {
              playingSong.isAppPlaying = true;
              playingSong.songInfo = listSong[0];
              playingSong.listSong = listSong;
            });
          }
        }),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              listSong.isNotEmpty ? listSong[0].imageUrl : genreImageUrl, // Đường dẫn URL của ảnh
              width: 125, // Độ rộng của ảnh
              height: 125, // Độ cao của ảnh
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
            Text(
              widget.artist.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
  
    );
  }
}
