import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_clouds/screens/Home.dart';
import 'package:flutter_music_clouds/screens/Library.dart';
import 'package:flutter_music_clouds/screens/Search.dart';
import 'package:flutter_music_clouds/screens/Upload.dart';
import 'package:flutter_music_clouds/widgets/colorScheme.dart';
import 'package:flutter_music_clouds/widgets/inheritedWidget.dart';
import 'package:just_audio/just_audio.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final player = AudioPlayer();
  bool isPlaying = false;
  int currentIndex = 0;

  List tabs = [const Home(), const Search(), const Library()];
  List titleTabs = ['Trang chủ', "Tìm kiếm", "Thư viện"];

  @override
  void initState() {
    super.initState();
    print("Player is playing: ${player.playing}");
  }

  Widget _buildPlaybackStatusWidget(context) {
    final myInheritedWidget = MyInheritedWidget.of(context);
    if (myInheritedWidget == null) {
      return Text('no inheritedwidget');
    }
    return (CustomBottomAppBar());
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    MyInheritedWidget? inheritedWidget = MyInheritedWidget.of(context);

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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Upload()));
                      },
                      icon: const Icon(Icons.cloud_upload_rounded)),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: MyInheritedWidget(
                        isAppPlaying: false,
                        player: player,
                        child: tabs[currentIndex]),
                  ),
                ],
              ),
              bottomNavigationBar: SizedBox(
                height: 40.0,
                child: BottomNavigationBar(
                  backgroundColor: const Color(0xFF1F1D1D),
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
              )),
        ));
  }
}

class CustomBottomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.0, // Điều chỉnh độ cao theo ý muốn
      color: Colors.black45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thêm các biểu tượng hoặc thông tin khác ở đây (ví dụ: tên bài hát, nghệ sĩ)
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              // Xử lý sự kiện nhấn nút play
            },
          ),
          const Column(
            children: [
              Text('Cho toi lang thang'),
              Text('Den vau'),
            ],
          ),
          IconButton(
            icon: Icon(Icons.pause),
            onPressed: () {
              // Xử lý sự kiện nhấn nút pause
            },
          ),
          // Thêm các biểu tượng hoặc thông tin khác ở đây
        ],
      ),
    );
  }
}
