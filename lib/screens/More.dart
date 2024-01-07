import 'package:flutter/material.dart';
import 'package:flutter_music_clouds/models/AuthController.dart';
import 'package:flutter_music_clouds/screens/LoginScreen.dart';
import 'package:get/get.dart';



class More extends StatelessWidget {
  const More({super.key});

  @override
  Widget build(BuildContext context) {
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

              },
              child: Container(
                width: MediaQuery.of(context).size.width - 25.0,
                height: 50.0,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 31, 29, 29)
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Các bài đã thích'),
                    Icon(Icons.arrow_forward_ios)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8.0,),
            
            // playlist
            GestureDetector(
              onTap: () {

              },
              child: Container(
                width: MediaQuery.of(context).size.width - 25.0,
                height: 50.0,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 31, 29, 29)
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Playlist & Albums'),
                    Icon(Icons.arrow_forward_ios)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8.0,),
            
            // following
            GestureDetector(
              onTap: () {

              },
              child: Container(
                width: MediaQuery.of(context).size.width - 25.0,
                height: 50.0,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 31, 29, 29)
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Following'),
                    Icon(Icons.arrow_forward_ios)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8.0,),
            
            // stations
            GestureDetector(
              onTap: () async {
                await Get.put(
                    AuthController().signoutMethod(context));
                // chuyển màn Login (không quay lại được)
                Get.offAll(() => const LoginScreen());
              },
              child: Container(
                width: MediaQuery.of(context).size.width - 25.0,
                height: 50.0,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 31, 29, 29)
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Đăng xuất'),
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