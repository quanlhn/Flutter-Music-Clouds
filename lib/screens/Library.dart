import "package:flutter/material.dart";

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
      child: Center(
        child: Column(
          children: [
            Container(
              height: 50.0,
            ),

            // favourites
            GestureDetector(
              onTap: () {

              },
              child: Container(
                width: MediaQuery.of(context).size.width - 25.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 31, 29, 29)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Các bài đã thích'),
                    Icon(Icons.arrow_forward_ios)
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.0,),
            
            // playlist
            GestureDetector(
              onTap: () {

              },
              child: Container(
                width: MediaQuery.of(context).size.width - 25.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 31, 29, 29)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Playlist & Albums'),
                    Icon(Icons.arrow_forward_ios)
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.0,),
            
            // following
            GestureDetector(
              onTap: () {

              },
              child: Container(
                width: MediaQuery.of(context).size.width - 25.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 31, 29, 29)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Following'),
                    Icon(Icons.arrow_forward_ios)
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.0,),
            
            // stations
            GestureDetector(
              onTap: () {

              },
              child: Container(
                width: MediaQuery.of(context).size.width - 25.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 31, 29, 29)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Stations'),
                    Icon(Icons.arrow_forward_ios)
                  ],
                ),
              ),
            ),

          ],
        ),
      )
    );
  }

}