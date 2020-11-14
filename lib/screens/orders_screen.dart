import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders_provider.dart' as provider;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const String ROUTE_NAME = "/orders";

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future _fetchOrdersFuture;

  @override
  void initState() {
    _fetchOrdersFuture =
        Provider.of<provider.OrderProvider>(context, listen: false)
            .fetchOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider =
        Provider.of<provider.OrderProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Orders"),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _fetchOrdersFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text("Something went wrong!"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: orderProvider.totalOrders,
            itemBuilder: (ctx, i) => OrderItem(order: orderProvider.orders[i]),
          );
        },
      ),
    );
  }
}
