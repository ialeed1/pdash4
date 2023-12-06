import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:purdue_dash_courier_app/global/global.dart';
import 'package:purdue_dash_courier_app/home/home_screen.dart';
import 'package:purdue_dash_courier_app/widgets/custom_text_field.dart';
import 'package:purdue_dash_courier_app/widgets/error_box.dart';
import 'package:purdue_dash_courier_app/widgets/loading_box.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  XFile? imageXfile;
  final ImagePicker picker = ImagePicker();
  String merchantLogoUrl = "";
  Future<void> getImage() async {
    imageXfile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXfile;
    });
  }

  Future<void> validateForm() async {
    if (imageXfile == null) {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorBox(
              message: "Select an image",
            );
          });
    } else {
      if (passwordController.text == confirmPasswordController.text) {
        if (confirmPasswordController.text.isNotEmpty &&
            emailController.text.isNotEmpty &&
            nameController.text.isNotEmpty &&
            contactController.text.isNotEmpty &&
            locationController.text.isNotEmpty) {
          showDialog(
              context: context,
              builder: (c) {
                return LoadingBox(
                  message: "Registration",
                );
              });
          String fileName = DateTime.now().millisecond.toString();
          storage.Reference reference = storage.FirebaseStorage.instance
              .ref()
              .child("Couriers")
              .child(fileName);
          storage.UploadTask uploadTask =
              reference.putFile(File(imageXfile!.path));
          storage.TaskSnapshot taskSnapshot =
              await uploadTask.whenComplete(() {});
          await taskSnapshot.ref.getDownloadURL().then((url) {
            merchantLogoUrl = url;
            registerMerchant();
          });
        } else {
          showDialog(
              context: context,
              builder: (c) {
                return ErrorBox(
                  message: "One of the fields is empty",
                );
              });
        }
      } else {
        showDialog(
            context: context,
            builder: (c) {
              return ErrorBox(
                message: "Passwords don't match",
              );
            });
      }
    }
  }

  Future save(User user) async {
    FirebaseFirestore.instance.collection("couriers").doc(user.uid).set({
      "courierUID": user.uid,
      "courierEmail": user.email,
      "courierName": nameController.text.trim(),
      "courierLogoURL": merchantLogoUrl,
      "couriertContact": contactController.text.trim(),
      "courierAddress": locationController.text.trim(),
      "status": "approved",
      "earnings": 0.0,
      "availabilityStatus": false,
    });
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", user.uid);
    await sharedPreferences!.setString("email", user.email.toString());
    await sharedPreferences!.setString("name", nameController.text.trim());
    await sharedPreferences!.setString("logoUrl", merchantLogoUrl);
  }

  void registerMerchant() async {
    User? currentUser;

    await firebaseAuth
        .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim())
        .then((auth) {
      currentUser = auth.user;
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
      save(currentUser!).then((value) {
        Navigator.pop(context);
        //Navigation to homescreen
        Route newRoute = MaterialPageRoute(builder: (c) => const HomeScreen());
        Navigator.pushReplacement(context, newRoute);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              getImage();
            },
            child: CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.20,
              backgroundColor: Colors.black,
              backgroundImage:
                  imageXfile == null ? null : FileImage(File(imageXfile!.path)),
              child: imageXfile == null
                  ? Icon(Icons.add_photo_alternate,
                      size: MediaQuery.of(context).size.width * 0.20,
                      color: Color(0xFFCFB991))
                  : null,
            ),
          ),
          const SizedBox(
            height: 10,
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
                  data: Icons.person,
                  controller: nameController,
                  hintText: "Name",
                  isObscure: false,
                ),
                CustomTextField(
                  data: Icons.lock,
                  controller: passwordController,
                  hintText: "Password",
                  isObscure: true,
                ),
                CustomTextField(
                  data: Icons.lock,
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  isObscure: true,
                ),
                CustomTextField(
                  data: Icons.phone,
                  controller: contactController,
                  hintText: "Contact Details",
                  isObscure: false,
                ),
                CustomTextField(
                  data: Icons.my_location,
                  controller: locationController,
                  hintText: "Address",
                  isObscure: false,
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: const Color(0xFFCFB991), // Boilermaker Gold
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 20),
                  ),
                  onPressed: () {
                    validateForm();
                  },
                  child: const Text(
                    "Register",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Franklin Gothic'),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
