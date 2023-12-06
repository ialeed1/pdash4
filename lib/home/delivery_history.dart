import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:purdue_dash_courier_app/widgets/courier_drawer.dart';
import 'package:purdue_dash_courier_app/orders.dart';
import 'package:purdue_dash_courier_app/widgets/find_product_name_by_id.dart';

class DeliveryHistoryScreen extends StatefulWidget {
  const DeliveryHistoryScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryHistoryScreen> createState() => _DeliveryHistoryScreenState();
}

List<Orders> orderHistory = []; // List to store fetched orders
bool refreshEnabled = true;

enum OrderSortBy {
  oldestToNewest,
  newestToOldest,
  leastToGreatest,
  greatestToLeast
}

OrderSortBy currentSortBy = OrderSortBy.newestToOldest;

class _DeliveryHistoryScreenState extends State<DeliveryHistoryScreen> {
  Future<void> fetchOrderHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    String courierUID = user!.uid;
    final courierCollection = FirebaseFirestore.instance.collection("couriers");
    final ordersCollection =
        courierCollection.doc(courierUID).collection("orders");
    final ordersSnapshot = await ordersCollection.get();
    setState(() {
      orderHistory = ordersSnapshot.docs.map((doc) {
        return Orders(
          doc['address'],
          doc['courierID'],
          doc['isSuccess'],
          doc['merchant'],
          doc['orderID'],
          doc['orderTime'],
          doc['orderedBy'],
          doc['paymentDetails'],
          List.from(doc['productIDs']),
          doc['status'],
          doc['totalPrice'],
        );
      }).toList();
    });
  }

  void sortBy(OrderSortBy sortBy) {
    setState(() {
      currentSortBy = sortBy;

      switch (sortBy) {
        case OrderSortBy.oldestToNewest:
          orderHistory.sort((a, b) => a.orderTime.compareTo(b.orderTime));
          break;
        case OrderSortBy.newestToOldest:
          orderHistory.sort((a, b) => b.orderTime.compareTo(a.orderTime));
          break;
        case OrderSortBy.leastToGreatest:
          orderHistory.sort((a, b) => a.totalPrice.compareTo(b.totalPrice));
          break;
        case OrderSortBy.greatestToLeast:
          orderHistory.sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchOrderHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text("Delivery History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: !refreshEnabled
                ? null
                : () async {
                    setState(() {
                      refreshEnabled = false;
                    });
                    await fetchOrderHistory();
                    Timer(const Duration(seconds: 1),
                        () => setState(() => refreshEnabled = true));
                  },
          ),
          PopupMenuButton<OrderSortBy>(
            onSelected: sortBy,
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<OrderSortBy>>[
              const PopupMenuItem<OrderSortBy>(
                value: OrderSortBy.oldestToNewest,
                child: Text('Oldest to Newest'),
              ),
              const PopupMenuItem<OrderSortBy>(
                value: OrderSortBy.newestToOldest,
                child: Text('Newest to Oldest'),
              ),
              const PopupMenuItem<OrderSortBy>(
                value: OrderSortBy.leastToGreatest,
                child: Text('Least to Greatest Amount'),
              ),
              const PopupMenuItem<OrderSortBy>(
                value: OrderSortBy.greatestToLeast,
                child: Text('Greatest to Least Amount'),
              ),
            ],
          ),
        ],
      ),
      drawer: const courier_drawer(),
      body: Column(
        children: [
          if (orderHistory.isEmpty)
            const Text("History is empty")
          else
            Expanded(
              child: ListView.builder(
                itemCount: orderHistory.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: GestureDetector(
                      onTap: () {
                        _showOrderDetails(context, orderHistory[index]);
                      },
                      child: ListTile(
                        title: Text('Order ${orderHistory[index].orderID}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text("Status: ${orderHistory[index].status}"),
                              ],
                            ),
                            Text(
                              'Total Price: \$${orderHistory[index].totalPrice.toStringAsFixed(2)}',
                            ),
                            Text(
                                "Number of Items: ${orderHistory[index].productIDs.length - 1}"),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

//show order details when clicked on
void _showOrderDetails(BuildContext context, Orders order) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(8),
          title: const Text('Order Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Address: ${order.addressID}'),
                //replace: merchant with restaurant
                Text('Merchant: ${order.merchantUID}'),
                Text('Order Id: ${order.orderID}'),
                Text('Order Time: ${order.orderTime}'),
                //replace ordered by with actual username
                Text('Ordered By: ${order.orderedBy}'),
                Text('Number of Items: ${order.productIDs.length - 1}'),
                Text('Status: ${order.status}'),
                Text('Total Price: \$${order.totalPrice.toStringAsFixed(2)}')
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _showItemsScreen(context, order);
              },
              child: const Text('Items'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      });
    },
  );
}

void _showItemsScreen(BuildContext context, Orders order) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: ((context, setState) {
        return AlertDialog(
            insetPadding: const EdgeInsets.all(8),
            title: const Text("Item Details"),
            content: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i < order.productIDs.length; i++)
                  FutureBuilder(
                      future: getProductString(order.productIDs.elementAt(i)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            return Text("${snapshot.data}");
                          } else if (snapshot.hasData) {
                            return const Text("Could not be loaded");
                          }
                        }
                        return const Text("Loading...");
                      }),
                //process the productID into product name, and display the correct amount
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Close"))
              ],
            )));
      }));
    },
  );
}
