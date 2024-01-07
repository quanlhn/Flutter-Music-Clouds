import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_clouds/models/Const.dart';
import 'package:flutter_music_clouds/models/PlayingSong.dart';
import 'package:flutter_music_clouds/models/SongInfos.dart';
import 'package:flutter_music_clouds/screens/Songs.dart';
import 'package:flutter_music_clouds/screens/library/favorite.dart';
import 'package:flutter_music_clouds/widgets/inheritedWidget.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  String selectedButton = 'Tên';
  final databaseReference = FirebaseDatabase.instance.ref();

  List<SongInfo> searchResults = [];

  void searchInDatabase(String query) async {
    final searchStatus = {
      "Tên": "lowerCaseSongName",
      "Ca sĩ": "lowerCaseArtistName",
      "Thể loại": "lowerCaseType"
    };

    final searchSnapshot = await databaseReference
        .child('app/songInfos')
        .orderByChild(searchStatus[selectedButton]!)
        .startAt(query.toLowerCase())
        .endAt('${query.toLowerCase()}\uf8ff')
        .get();
    if (searchSnapshot.exists) {
      final List<SongInfo> tSongs = [];
      for (DataSnapshot dataSnapshot in searchSnapshot.children) {
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
          searchResults = tSongs;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          searchResults = [];
        });
      }
      print('No data available.');
    }
  }

  void searchAsName(String query) async {}

  @override
  Widget build(BuildContext context) {
    final myInheritedWidget = MyInheritedWidget.of(context);
    if (myInheritedWidget == null) {
      return const Text('no inheritedwidget');
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 10, 2, 10),
      child: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Nhập từ khóa',
                  filled: true,
                  contentPadding: EdgeInsets.fromLTRB(2, 5, 2, 5),
                  fillColor: Theme.of(context).colorScheme.surface,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      searchInDatabase(searchController.text);
                    },
                  ),
                ),
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ToggleButton(
                  text: 'Tên',
                  isSelected: selectedButton == 'Tên',
                  onSelect: () {
                    setState(() {
                      selectedButton = 'Tên';
                    });
                    searchInDatabase(searchController.text);
                  },
                ),
                ToggleButton(
                  text: 'Ca sĩ',
                  isSelected: selectedButton == 'Ca sĩ',
                  onSelect: () {
                    setState(() {
                      selectedButton = 'Ca sĩ';
                    });
                    searchInDatabase(searchController.text);
                  },
                ),
                ToggleButton(
                  text: 'Thể loại',
                  isSelected: selectedButton == 'Thể loại',
                  onSelect: () {
                    setState(() {
                      selectedButton = 'Thể loại';
                    });
                    searchInDatabase(searchController.text);
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        myInheritedWidget.updateIsAppPlaying(true);
                        return MyInheritedWidget(
                          isAppPlaying: myInheritedWidget.isAppPlaying,
                          player: myInheritedWidget.player,
                          child: Songspage(searchResults[index], true,
                              myInheritedWidget.player),
                        );
                      })).then((value) => setState(() {
                            playingSong = PlayingSong(true,
                                songInfo: searchResults[index]);
                          }));
                    },
                    child: SongCard(songInfo: searchResults[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ToggleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onSelect;

  ToggleButton(
      {required this.text, required this.isSelected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onSelect,
      style: ElevatedButton.styleFrom(
          primary: isSelected ? Colors.blue : Colors.grey,
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0))),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 16.0),
      ),
    );
  }
}
