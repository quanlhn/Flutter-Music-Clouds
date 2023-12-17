import 'package:flutter/material.dart';
import 'package:flutter_music_clouds/widgets/colorScheme.dart';
import 'package:flutter_music_clouds/models/styles.dart';
import 'package:velocity_x/velocity_x.dart';

Widget customTextField({String? title, String? hint, controller, isPass}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      title!.text.color(redColor).fontFamily(semibold).size(16).make(),
      5.heightBox,
      TextFormField(
        // Che mật khẩu isPass
        obscureText: isPass,
        // tham số controller truyền vào
        controller: controller,
        decoration: InputDecoration(
          hintStyle: const TextStyle(
            fontFamily: semibold,
            color: textfieldGrey,
          ),
          hintText: hint,
          isDense: true,
          fillColor: lightGrey,
          filled: true,
          border: InputBorder.none,
          focusedBorder:
              const OutlineInputBorder(borderSide: BorderSide(color: redColor)),
        ),
      ),
      10.heightBox,
    ],
  );
}
