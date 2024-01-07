import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_tutorial/consts/consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_clouds/models/Const.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';



class AuthController extends GetxController {
  // Loading screen
  var isLoading = false.obs;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref("app/users");
  // khởi tạo text controller
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  // phương thức login
  Future<UserCredential?> loginMethod({context}) async {
    UserCredential? userCredential;

    try {
      userCredential = await auth.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
    } on FirebaseAuthException catch (e) {
      VxToast.show(context, msg: e.toString());
    }
    return userCredential;
  }

  // phương thức sign up
  Future<UserCredential?> signupMethod({email, password, context}) async {
    UserCredential? userCredential;

    try {
      userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      VxToast.show(context, msg: e.toString());
    }
    return userCredential;
  }

  // phương thức store data
  storeUserData({name, password, email}) async {
    print('storeUserData function');
    DatabaseReference newUserRef = FirebaseDatabase.instance.ref("app/users").push();
    await newUserRef.set({
      "name": name,
      "password": password,
      "email": email,
      "id": currentUser!.uid,
      "liked": 0
    });
  }

  //phương thức sign out
  signoutMethod(context) async {
    try {
      await auth.signOut();
    } catch (e) {
      VxToast.show(context, msg: e.toString());
    }
  }
}
