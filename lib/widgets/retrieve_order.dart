import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purdue_dash_courier_app/orders.dart';

List<Orders> orderList = [];

Future<List<Orders>> getDeliveringStatusOrderList() async {
  orderList.clear();
  await retrieveDeliveringOrders();
  return orderList;
}

Future<List<Orders>> getNormalStatusOrderList() async {
  orderList.clear();
  await retrieveNormalStatusOrders();
  //print("Retrieve Check: ${orderList.length}");
  return orderList;
}

Future<List<Orders>> getCourierHistoryOrders() async {
  orderList.clear();
  await retrieveCourierOrderHistory();
  return orderList;
}

Future<void> retrieveCourierOrderHistory() async {
  final user = FirebaseAuth.instance.currentUser;
  String courierUID = user!.uid;

  final courierCollection = FirebaseFirestore.instance.collection("couriers");
  final ordersCollection =
      courierCollection.doc(courierUID).collection("orders");

  final ordersSnapshot = await ordersCollection.get();
  int orderCount = ordersSnapshot.docs.length;
  for (int i = 0; i < orderCount; i++) {
    //retrieve customer details name + address
    late String ordererName;
    late String ordererAddress;
    late String merchantName;
    final element = ordersSnapshot.docs.elementAt(i);
    await FirebaseFirestore.instance
        .collection('customers')
        .doc(element.get('orderedBy'))
        .get()
        .then((name) {
      // print("2nd test: ${name.exists}");
      ordererName = name.get('name');
    });

    await FirebaseFirestore.instance
        .collection('customers')
        .doc(element.get('orderedBy'))
        .collection('userAddress')
        .doc(element.get('addressID'))
        .get()
        .then((getAddress) {
      // print("A ${thing.get('address')}");
      ordererAddress = getAddress.get('address');
    });
    //retrieve customer details

    //retrieve proper merchant name
    await FirebaseFirestore.instance
        .collection('merchants')
        .doc(element.get('merchantUID'))
        .get()
        .then((merchant) {
      merchantName = merchant.get('merchantName');
    });

    //create order object to pass to pages for displaying
    Orders order = Orders(
      ordererAddress,
      element.get('courierUID'),
      element.get('isSuccess'),
      merchantName,
      element.get('orderId'),
      element.get('orderTime'),
      ordererName,
      element.get('paymentDetails'),
      element.get('productIDs'),
      element.get('status'),
      element.get('totalPrice'),
    );

    orderList.add(order);
  }
}

/*
 * Go to 'orders' collection -> find status labeled "normal" and add
 * those to the list.
 * TO DO: make separate functions for getting information
 */

Future<void> retrieveNormalStatusOrders() async {
  await FirebaseFirestore.instance
      .collection('orders')
      .where('status', isEqualTo: "normal")
      .get()
      .then((snapShot) async {
    int orderCount = snapShot.docs.length;
    for (int i = 0; i < orderCount; i++) {
      //retrieve customer details name + address
      late String ordererName;
      late String ordererAddress;
      late String merchantName;
      final element = snapShot.docs.elementAt(i);
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(element.get('orderedBy'))
          .get()
          .then((name) {
        // print("2nd test: ${name.exists}");
        ordererName = name.get('name');
      });

      await FirebaseFirestore.instance
          .collection('customers')
          .doc(element.get('orderedBy'))
          .collection('userAddress')
          .doc(element.get('addressID'))
          .get()
          .then((getAddress) {
        // print("A ${thing.get('address')}");
        ordererAddress = getAddress.get('address');
      });
      //retrieve customer details

      //retrieve proper merchant name
      await FirebaseFirestore.instance
          .collection('merchants')
          .doc(element.get('merchantUID'))
          .get()
          .then((merchant) {
        merchantName = merchant.get('merchantName');
      });

      //create order object to pass to pages for displaying
      Orders order = Orders(
        ordererAddress,
        element.get('courierUID'),
        element.get('isSuccess'),
        merchantName,
        element.get('orderId'),
        element.get('orderTime'),
        ordererName,
        element.get('paymentDetails'),
        element.get('productIDs'),
        element.get('status'),
        element.get('totalPrice'),
      );

      orderList.add(order);
    }
  });
} /* retrieveNormalStatusOrders() */

/*
 * Go to 'orders' collection -> find all status not normal/delivered
 * and add those to the list. ONLY retrieve those of under courier ID
 */

Future<void> retrieveDeliveringOrders() async {
  List<String> validStatuses = ['picking', 'delivering'];
  await FirebaseFirestore.instance
      .collection('orders')
      .where('status', whereIn: validStatuses)
      .where('courierUID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .get()
      .then((snapShot) async {
    int orderCount = snapShot.docs.length;

    for (int i = 0; i < orderCount; i++) {
      //retrieve customer details name + address
      late String ordererName;
      late String ordererAddress;
      late String merchantName;
      final element = snapShot.docs.elementAt(i);
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(element.get('orderedBy'))
          .get()
          .then((name) {
        // print("2nd test: ${name.exists}");
        ordererName = name.get('name');
      });

      await FirebaseFirestore.instance
          .collection('customers')
          .doc(element.get('orderedBy'))
          .collection('userAddress')
          .doc(element.get('addressID'))
          .get()
          .then((getAddress) {
        // print("A ${thing.get('address')}");
        ordererAddress = getAddress.get('address');
      });
      //retrieve customer details

      //retrieve proper merchant name
      await FirebaseFirestore.instance
          .collection('merchants')
          .doc(element.get('merchantUID'))
          .get()
          .then((merchant) {
        merchantName = merchant.get('merchantName');
      });

      //create order object to pass to pages for displaying
      Orders order = Orders(
        ordererAddress,
        element.get('courierUID'),
        element.get('isSuccess'),
        merchantName,
        element.get('orderId'),
        element.get('orderTime'),
        ordererName,
        element.get('paymentDetails'),
        element.get('productIDs'),
        element.get('status'),
        element.get('totalPrice'),
      );

      orderList.add(order);
    }
  });
}
