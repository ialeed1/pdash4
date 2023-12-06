import 'package:firebase_auth/firebase_auth.dart';

String getName() {
  String name = FirebaseAuth.instance.currentUser!.displayName.toString();
  return name;
}

String getEmail() {
  String email = FirebaseAuth.instance.currentUser!.email.toString();
  return email;
}
