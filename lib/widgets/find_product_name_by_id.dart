import 'package:cloud_firestore/cloud_firestore.dart';

String productFormat = "";

Future<String> getProductString(String productID) async {
  productFormat = "";

  String item = await retrieveProductName(productID);
  productFormat = "";
  return item;
}

Future<String> retrieveProductName(String productID) async {
  final product = await FirebaseFirestore.instance
      .collection('items')
      .doc(productID.split(':').first)
      .get();
  //maniuplate the productID trim to :
  String amount = productID.split(':').last;
  productFormat += "${amount}x ";
  productFormat += product.get('title');
  return productFormat;
}
