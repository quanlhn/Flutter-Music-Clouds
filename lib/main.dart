import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_music_clouds/screens/Home.dart';
import 'package:flutter_music_clouds/screens/Library.dart';
import 'package:flutter_music_clouds/screens/Search.dart';
import 'package:flutter_music_clouds/screens/Upload.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_music_clouds/widgets/colorScheme.dart';
import 'package:flutter_music_clouds/widgets/customAppBar.dart';
import 'package:flutter_music_clouds/widgets/inheritedWidget.dart';
import 'package:just_audio/just_audio.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final player = AudioPlayer();
  int currentIndex = 0;
  List tabs = [Home(), Search(), Library()];
  List titleTabs = ['Trang chủ', "Tìm kiếm", "Thư viện"];

  void initState() {
    super.initState();
    print("Player is playing: ${player.playing}");
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: MyColorScheme.darkColorScheme,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(titleTabs[currentIndex]),
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Upload()));
                    },
                    icon: const Icon(Icons.cloud_upload_rounded)),
              ],
            ),
            body: MyInheritedWidget(
                count: 12, player: player, child: tabs[currentIndex]),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Color(0xFF1F1D1D),
              selectedFontSize: 0,
              currentIndex: currentIndex,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.library_music),
                  label: "",
                )
              ],
              onTap: (index) {
                print("Player is playing: ${player.playing}");
                setState(() {
                  currentIndex = index;
                });
              },
            ),
          ),
        ));
  }
}
