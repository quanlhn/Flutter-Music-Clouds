import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(2, 10, 2, 10),
      child: Center(
        child: Column(
          children: <Widget>[
            AppBar(
              title: const Text('Tìm kiếm'),
              toolbarHeight: 35.0,
            )
          ],
        ),
      ),
    );
  }
}
