import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purdue_dash_courier_app/orders.dart';
import 'package:purdue_dash_courier_app/widgets/add_to_history.dart';
import 'package:purdue_dash_courier_app/widgets/courier_stat_modify.dart';

//retrieves order status and its associated integer value

Future<int> retrieveOrderStatus(String orderID) async {
  final collection = FirebaseFirestore.instance.collection("orders");
  final querySnapshot =
      await collection.where('orderId', isEqualTo: orderID).get();
  String status = querySnapshot.docs.first.get('status');
  int statusInt = 0;
  switch (status) {
    case 'picking':
      statusInt = 1;
    case 'delivering':
      statusInt = 2;
    case 'delivered':
      statusInt = 3;
    default:
      statusInt = 0;
  }
  return statusInt;
}

//updates the order status generic
Future<void> updateOrderStatus(String newStatus, String orderID) async {
  final collection = FirebaseFirestore.instance.collection("orders");
  final querySnapshot =
      await collection.where('orderId', isEqualTo: orderID).get();

  if (querySnapshot.docs.isNotEmpty) {
    final docRef = collection.doc(querySnapshot.docs.first.id);
    docRef.update({'status': newStatus});
  }
}

//updates the order status by steps
Future<void> updateOrderStatusBySteps(Orders order) async {
  String orderID = order.orderID;
  final collection = FirebaseFirestore.instance.collection("orders");
  final querySnapshot =
      await collection.where('orderId', isEqualTo: orderID).get();

  if (querySnapshot.docs.isNotEmpty) {
    int statusNum = await retrieveOrderStatus(orderID);
    String newStatus = "";
    switch (statusNum) {
      case 1:
        newStatus = 'delivering';
      case 2:
        newStatus = "delivered";
      default:
        newStatus = 'ERROR';
    }
    final docRef = collection.doc(querySnapshot.docs.first.id);
    await docRef.update({'status': newStatus});

    //add order to order collection on courier if status is delivered + increase stat on delivered
    if (newStatus == "delivered") {
      await addToHistory(order);
      await incrementOrdersDelivered();
      //TODO: change this to courier SHARE!
      await incrementAmountEarned(order.totalPrice);
    }

    String customerUID = querySnapshot.docs.first.get('orderedBy');
    final customersCollection =
        FirebaseFirestore.instance.collection("customers");
    final customerOrderDocRef = customersCollection
        .doc(customerUID)
        .collection("orders")
        .doc(querySnapshot.docs.first.id);
    await customerOrderDocRef.update({'status': newStatus});
  }
}

//updates order changing courier ID as well
Future<void> getDelivery(String newStatus, String orderID) async {
  final collection = FirebaseFirestore.instance.collection("orders");
  final querySnapshot =
      await collection.where('orderId', isEqualTo: orderID).get();
  //retrieve Courier UID
  final user = FirebaseAuth.instance.currentUser;
  String courierUID = user!.uid;
  if (querySnapshot.docs.isNotEmpty) {
    final docRef = collection.doc(querySnapshot.docs.first.id);
    docRef.update({'status': newStatus});
    docRef.update({'courierUID': courierUID});
  }
}

//updates the courier ID to link the order to the courier