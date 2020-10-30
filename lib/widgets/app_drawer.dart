import 'package:flutter/material.dart';

import '../screens/products_overview_screen.dart';
import '../screens/orders_screen.dart';

class AppDrawer extends StatelessWidget {
  // Widget buildNavTile(ctx) {

  // }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text("Hello friend"),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text("Shop"),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(ProductsOverviewScreen.ROUTE_NAME);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text("Orders"),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(OrdersScreen.ROUTE_NAME);
            },
          ),
        ],
      ),
    );
  }
}
