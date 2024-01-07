import "package:flutter/material.dart";
import "package:flutter_music_clouds/screens/library/favorite.dart";
import "package:flutter_music_clouds/screens/library/uploaded.dart";
import "package:flutter_music_clouds/widgets/inheritedWidget.dart";

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext fatherContext) {
    final myInheritedWidget = MyInheritedWidget.of(fatherContext);
    if (myInheritedWidget == null) {
      return const Text('no inheritedwidget');
    }
    return Padding(
        padding: const EdgeInsets.fromLTRB(2, 10, 2, 10),
        child: Center(
          child: Column(
            children: [
              Container(
                height: 50.0,
              ),

              // favourites
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return MyInheritedWidget(
                        isAppPlaying: myInheritedWidget.isAppPlaying,
                        player: myInheritedWidget.player,
                        child: FavoriteSongs());
                    // return MyIn
                  }));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width - 25.0,
                  height: 50.0,
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 31, 29, 29)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Các bài đã thích'),
                      Icon(Icons.arrow_forward_ios)
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),

              // playlist
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: MediaQuery.of(context).size.width - 25.0,
                  height: 50.0,
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 31, 29, 29)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Playlist & Albums'),
                      Icon(Icons.arrow_forward_ios)
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),

              // following
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: MediaQuery.of(context).size.width - 25.0,
                  height: 50.0,
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 31, 29, 29)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Following'),
                      Icon(Icons.arrow_forward_ios)
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),

              // stations
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return MyInheritedWidget(
                        isAppPlaying: myInheritedWidget.isAppPlaying,
                        player: myInheritedWidget.player,
                        child: Uploaded());
                    // return MyIn
                  }));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width - 25.0,
                  height: 50.0,
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 31, 29, 29)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('Đã tải lên'), Icon(Icons.arrow_forward_ios)],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
