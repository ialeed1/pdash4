import 'package:flutter/material.dart';
import 'package:purdue_dash_courier_app/widgets/courier_drawer.dart';
import 'package:purdue_dash_courier_app/widgets/courier_stat_modify.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

double totalOrdersDelivered = 0;
double totalAmountEarned = 0.0;

class _StatisticsScreenState extends State<StatisticsScreen> {
  Future<void> retrieveStats() async {
    double newOrdersDelivered = await retrieveOrdersDelivered();
    double newTotalAmountEarned = await retrieveTotalAmountEarned();
    setState(() {
      totalOrdersDelivered = newOrdersDelivered;
      totalAmountEarned = newTotalAmountEarned;
    });
  }

  @override
  void initState() {
    super.initState();
    retrieveStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text('Statistics'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Total Orders Delivered: ${totalOrdersDelivered.toStringAsFixed(0)}'),
            Text(
                'Total Amount Earned: \$${totalAmountEarned.toStringAsFixed(2)}'),
            const SizedBox(height: 20.0),
            // Add a button to view detailed statistics
            ElevatedButton(
              onPressed: () {
                showDetails(context);
              },
              child: const Text('View Detailed Statistics'),
            ),
          ],
        ),
      ),
      drawer: const courier_drawer(),
    );
  }

  void showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detailed Statistics'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Orders Delivered: ${totalOrdersDelivered.toStringAsFixed(0)}'),
              Text('Amount Earned: \$${totalAmountEarned.toStringAsFixed(2)}'),
              SizedBox(
                height: 200,
                child: charts.BarChart(
                  createChart(),
                  animate: true,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  //create chart using stats
  List<charts.Series<StatData, String>> createChart() {
    final data = [
      StatData('Orders Delivered', totalOrdersDelivered),
      StatData('Amount Earned', totalAmountEarned),
    ];

    return [
      charts.Series<StatData, String>(
        id: 'Stats',
        domainFn: (StatData stat, _) => stat.statName,
        measureFn: (StatData stat, _) => stat.statValue,
        data: data,
        labelAccessorFn: (StatData stat, _) =>
            '${stat.statName}: ${stat.statValue}',
      ),
    ];
  }
}

class StatData {
  final String statName;
  final double statValue;

  StatData(this.statName, this.statValue);
}
