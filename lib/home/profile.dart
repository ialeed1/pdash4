import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purdue_dash_courier_app/widgets/courier_drawer.dart';
import 'package:purdue_dash_courier_app/widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contactDetailsController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text("Edit Profile"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = true;
              });
            },
          ),
        ],
      ),
      drawer: courier_drawer(),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Name
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: CustomTextField(
                data: Icons.person,
                controller: nameController,
                hintText:
                    nameController.text.isEmpty ? "Name" : nameController.text,
                isObscure: false,
              ),
            ),
            // Email
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: CustomTextField(
                data: Icons.email,
                controller: emailController,
                hintText: emailController.text.isEmpty
                    ? "Email"
                    : emailController.text,
                isObscure: false,
              ),
            ),
            // Contact Details
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: CustomTextField(
                data: Icons.contact_page,
                controller: contactDetailsController,
                hintText: contactDetailsController.text.isEmpty
                    ? "Contact Details"
                    : contactDetailsController.text,
                isObscure: false,
              ),
            ),
            // Address
            const SizedBox(height: 6),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: CustomTextField(
                data: Icons.map,
                controller: addressController,
                hintText: addressController.text.isEmpty
                    ? "Address"
                    : addressController.text,
                isObscure: false,
              ),
            ),
/*
            if (isEditing) ...[
              ElevatedButton(
                onPressed: () {
                },
                child: Text('Upload Image'),
              ),
            ],
            */

            SizedBox(height: 20),

            // Save button

            ElevatedButton(
              onPressed: () {
                String name = nameController.text;
                String email = emailController.text;
                String contactDetails = contactDetailsController.text;
                String address = addressController.text;

                updateUserProfile(name, email, contactDetails, address);

                setState(() {
                  isEditing = false;
                });
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateUserProfile(
    String name,
    String email,
    String contactDetails,
    String address,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final profileCollection =
          FirebaseFirestore.instance.collection('couriers');

      final dataToUpdate = <String, dynamic>{};

      if (name.isNotEmpty) {
        dataToUpdate['courierName'] = name;
      }

      if (email.isNotEmpty) {
        dataToUpdate['courierEmail'] = email;
      }

      if (contactDetails.isNotEmpty) {
        dataToUpdate['couriertContact'] = contactDetails;
      }

      if (address.isNotEmpty) {
        dataToUpdate['courierAddress'] = address;
      }

      try {
        await profileCollection.doc(user.uid).update(dataToUpdate);

        if (name.isNotEmpty) {
          await user.updateDisplayName(name);
        }
      } catch (error) {
        print("Error updating user profile: $error");
      }
    }
  }
}
