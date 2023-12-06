import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:purdue_dash_courier_app/authentication/auth_screen.dart';
import 'package:purdue_dash_courier_app/global/global.dart';
import 'package:purdue_dash_courier_app/home/home_screen.dart';
import 'package:purdue_dash_courier_app/widgets/error_box.dart';
import 'package:purdue_dash_courier_app/widgets/loading_box.dart';

import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  formValidation() {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      login();
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorBox(
              message: "Email or Password is empty",
            );
          });
    }
  }

  login() async {
    showDialog(
        context: context,
        builder: (c) {
          return LoadingBox(
            message: "Login",
          );
        });
    User? currentUser;
    await firebaseAuth
        .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim())
        .then((auth) {
      currentUser = auth.user!;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorBox(
              message: error.message.toString(),
            );
          });
    });
    if (currentUser != null) {
      authenticate(currentUser!);
    }
  }

  Future authenticate(User user) async {
    await FirebaseFirestore.instance
        .collection("couriers")
        .doc(user.uid)
        .get()
        .then((value) async {
      if (value.exists) {
        await sharedPreferences!.setString("uid", user.uid);
        await sharedPreferences!
            .setString("email", value.data()!["courierEmail"]);
        await sharedPreferences!
            .setString("name", value.data()!["courierName"]);
        await sharedPreferences!
            .setString("logoUrl", value.data()!["courierLogoURL"]);
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const HomeScreen()));
      } else {
        firebaseAuth.signOut();
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const AuthScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Image.asset(
                "images/splash.png",
                height: 270,
              ),
            ),
          ),
          Form(
            key: formKey,
            child: Column(
              children: [
                CustomTextField(
                  data: Icons.email,
                  controller: emailController,
                  hintText: "Email",
                  isObscure: false,
                ),
                CustomTextField(
                  data: Icons.lock,
                  controller: passwordController,
                  hintText: "Password",
                  isObscure: true,
                ),
              ],
            ),
          ),
          ElevatedButton(
            child: const Text(
              "Login",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Franklin Gothic'),
            ),
            style: ElevatedButton.styleFrom(
              primary: const Color(0xFFCFB991), // Boilermaker Gold
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            ),
            onPressed: () {
              formValidation();
            },
          ),
        ],
      ),
    );
  }
}
