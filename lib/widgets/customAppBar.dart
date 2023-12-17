import "package:flutter/material.dart";
import "package:flutter_music_clouds/screens/Upload.dart";

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String actionText;
  // final Function onActionPressed;

  const CustomAppBar(
      {super.key, required this.title,
      required this.actionText,
      // required this.onActionPressed
      });

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  toUploadScreen() {
    // Navigator.push(context, MaterialPageRoute(builder: (context) {
    //   return Upload();
    // }));
    // setState(() {
    //   widget.count = widget.count + 1;
    // });
    // print(widget.count);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        widget.title,
        style: const TextStyle(color: Colors.white), // Màu tiêu đề
      ),
      centerTitle: true, // Đặt tiêu đề ở giữa
      actions: [
        IconButton(
          icon: const Icon(Icons.cloud_upload_outlined),
          onPressed: 
          // () {
          //   widget.onActionPressed();
          // },
          () =>
              Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const Upload();
          })),
        ),
      ],
    );
  }
}
