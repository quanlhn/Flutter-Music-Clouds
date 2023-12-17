import 'package:flutter/material.dart';
import 'package:flutter_music_clouds/models/AuthController.dart';
import 'package:flutter_music_clouds/models/strings.dart';
import 'package:flutter_music_clouds/screens/MainScreen.dart';
import 'package:flutter_music_clouds/screens/SignupScreen.dart';
import 'package:flutter_music_clouds/widgets/colorScheme.dart';
import 'package:flutter_music_clouds/widgets/custom_textfield.dart';
import 'package:flutter_music_clouds/widgets/our_button.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // lấy controller authentication
    var controller = Get.put(AuthController());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              (context.screenHeight * 0.1).heightBox,
              10.heightBox,
              "Đăng nhập".text.fontFamily("sans_bold").white.size(18).make(),
              15.heightBox,
              Obx(
                () => SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Tạo trường nhập text cho Email và Mật khẩu
                      customTextField(
                        hint: emailHint,
                        title: email,
                        isPass: false,
                        controller: controller.emailController,
                      ),
                      5.heightBox,
                      customTextField(
                        hint: passwordHint,
                        title: password,
                        isPass: true,
                        controller: controller.passwordController,
                      ),

                      /// Button quên mật khẩu
                      Align(
                        alignment: Alignment.centerRight,
                        // Tạo chữ "Quên mật khẩu"
                        child: TextButton(
                          onPressed: () {},
                          child: forgetPass.text.make(),
                        ),
                      ),
                      5.heightBox,

                      /// Tạo button "Đăng nhập"
                      /// Tạo hiệu ứng loading
                      controller.isLoading.value
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(redColor),
                            )
                          : ourButton(
                              color: redColor,
                              title: login,
                              textColor: whiteColor,

                              /// Xử lý sự kiện "Đăng nhập"
                              onPress: () async {
                                /// set Loading = true để hiển thị hiệu ứng
                                controller.isLoading(true);

                                await controller
                                    .loginMethod(context: context)
                                    .then((value) {
                                  if (value != null) {
                                    /// Thông báo đăng nhập thành công
                                    VxToast.show(context, msg: loginSuccess);

                                    /// chuyển màn Home (block turn back)
                                    Get.offAll(() => const MainApp());
                                  } else {
                                    /// Đăng nhập thất bại:
                                    /// Set thành false để await onPress
                                    controller.isLoading(false);
                                    VxToast.show(context,
                                        msg: "Sai tài khoản hoặc mật khẩu");
                                  }
                                });
                              },
                            ).box.width(context.screenWidth - 50).make(),
                      5.heightBox,
                      // Tạo chữ "Hoặc đăng ký tài khoản mới"
                      createNewAccount.text.color(fontGrey).make(),
                      5.heightBox,
                      // Tạo nút bấm "Đăng ký"
                      ourButton(
                          color: golden,
                          title: signup,
                          textColor: redColor,
                          // Tạo chuyển hướng màn
                          onPress: () {
                            Get.to(() => const SignupScreen());
                          }).box.width(context.screenWidth - 50).make(),
                      // Tạo chữ "Đăng nhập với"
                      10.heightBox,
                      loginWith.text.color(fontGrey).make(),
                      5.heightBox,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          2,
                          (index) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: lightGrey,
                              radius: 25,
                              child: Image.asset(
                                socialIconList[index],
                                width: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
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
            ],
          ),
        ),
      ),
    );
  }
}
