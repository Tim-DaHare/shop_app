import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders_provider.dart' as provider;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const String ROUTE_NAME = "/orders";

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<provider.OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Orders"),
      ),
      drawer: AppDrawer(),
      body: ListView.builder(
        itemCount: orderProvider.totalOrders,
        itemBuilder: (ctx, i) => OrderItem(order: orderProvider.orders[i]),
      ),
    );
  }
}
