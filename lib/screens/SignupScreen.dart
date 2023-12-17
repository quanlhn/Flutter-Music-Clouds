import 'package:flutter/material.dart';
import 'package:flutter_music_clouds/models/AuthController.dart';
import 'package:flutter_music_clouds/models/Const.dart';
import 'package:flutter_music_clouds/models/strings.dart';
import 'package:flutter_music_clouds/models/styles.dart';
import 'package:flutter_music_clouds/screens/MainScreen.dart';
import 'package:flutter_music_clouds/widgets/colorScheme.dart';
import 'package:flutter_music_clouds/widgets/custom_textfield.dart';
import 'package:flutter_music_clouds/widgets/our_button.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool? isCheck = false;
  // auth controller
  var controller = Get.put(AuthController());

  //text controllers
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var passwordRetypeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              (context.screenHeight * 0.1).heightBox,
              10.heightBox,
              "Đăng ký tài khoản"
                  .text
                  .fontFamily(bold)
                  .white
                  .size(18)
                  .make(),
              15.heightBox,

              Obx(
                () => SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Tạo trường nhập cho Họ tên
                      customTextField(
                          hint: nameHint,
                          title: name,
                          controller: nameController,
                          isPass: false),
                      // Tạo trường nhập cho Email và Mật khẩu
                      customTextField(
                          hint: emailHint,
                          title: email,
                          controller: emailController,
                          isPass: false),
                      customTextField(
                          hint: passwordHint,
                          title: password,
                          controller: passwordController,
                          isPass: true),
                      // Tạo trường nhập cho "Nhập lại mật khẩu"
                      customTextField(
                          hint: passwordHint,
                          title: retypePassword,
                          controller: passwordRetypeController,
                          isPass: true),
                      // Align(
                      //   alignment: Alignment.centerRight,
                      //   // Tạo chữ "Quên mật khẩu"
                      //   child: TextButton(
                      //     onPressed: () {},
                      //     child: forgetPass.text.make(),
                      //   ),
                      // ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.lock),
                              SizedBox(
                                width: 5,
                              ), // Khoảng cách giữa icon và văn bản
                              Text(forgetPass),
                            ],
                          ),
                        ),
                      ),
                      5.heightBox,
                      // Tạo check box "đồng ý với điều khoản dịch vụ...""
                      Row(
                        children: [
                          Checkbox(
                            activeColor: redColor,
                            checkColor: whiteColor,
                            value: isCheck,
                            onChanged: (newValue) {
                              setState(() {
                                isCheck = newValue;
                              });
                            },
                          ),
                          10.widthBox,
                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Tôi đồng ý với ",
                                    style: TextStyle(
                                      fontFamily: regular,
                                      color: fontGrey,
                                    ),
                                  ),
                                  TextSpan(
                                    text: termAndCondi,
                                    style: TextStyle(
                                      fontFamily: regular,
                                      color: redColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: " & ",
                                    style: TextStyle(
                                      fontFamily: regular,
                                      color: fontGrey,
                                    ),
                                  ),
                                  TextSpan(
                                    text: privacyPolicy,
                                    style: TextStyle(
                                      fontFamily: regular,
                                      color: redColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      5.heightBox,

                      /// Tạo nút "Đăng ký"
                      controller.isLoading.value
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(redColor),
                            )
                          : ourButton(

                              /// Điều kiện: đã check check box "Điều khoản dịch vụ"
                              color: isCheck == true ? redColor : lightGrey,
                              title: signup,
                              textColor: whiteColor,

                              /// xử lý sự kiện on press
                              onPress: () async {
                                if (isCheck != false) {
                                  /// set flag = true => hiệu ứng loading
                                  controller.isLoading(true);
                                  try {
                                    /// truyền dữ liệu từ controller vào sign up method
                                    await controller
                                        .signupMethod(
                                            context: context,
                                            email: emailController.text,
                                            password: passwordController.text)
                                        .then(
                                      (value) {
                                        /// then store data lại
                                        return controller.storeUserData(
                                          email: emailController.text,
                                          password: passwordController.text,
                                          name: nameController.text,
                                        );
                                      },
                                    ).then(
                                      (value) {
                                        /// then Thông báo ra màn hình Đăng nhập thành công
                                        VxToast.show(context, msg: loginSuccess);

                                        /// chuyển sang màn Home (không quay lại được màn sign up)
                                        Get.offAll(() => const MainApp());
                                      },
                                    );
                                  } catch (e) {
                                    /// Nếu error Đăng xuất authentication instance
                                    auth.signOut();
                                    VxToast.show(context, msg: e.toString());

                                    /// set lại flag hiệu ứng loading
                                    controller.isLoading(false);
                                  }
                                }
                              }).box.width(context.screenWidth - 50).make(),
                    ],
                  )
                      .box
                      .white
                      .rounded
                      .padding(const EdgeInsets.all(16))
                      .width(context.screenWidth - 70)
                      .shadowSm
                      .make(),
                ),
              ),
              10.heightBox,
              // Tạo chữ "Đã có tài khoản? Đăng nhập"
              // đóng gói lại để xử lý sự kiện
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  alreadyHaveAccount.text.color(fontGrey).make(),
                  login.text.color(redColor).make().onTap(() {
                    // Quay lại màn đăng nhập
                    Get.back();
                  })
                ],
              ),
            ],
          ),
     
        ),
      ),
    );
  }
}
