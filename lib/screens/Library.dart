import "package:flutter/material.dart";
import "package:flutter_music_clouds/widgets/customAppBar.dart";

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
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(2, 10, 2, 10),
      child: Center()
    );
  }
}