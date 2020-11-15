import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/products_overview_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';
import '../helpers/custom_route.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text("Hello friend"),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: const Text("Shop"),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(ProductsOverviewScreen.ROUTE_NAME);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: const Text("Orders"),
            onTap: () {
              // Navigator.of(context).pushReplacement(CustomRoute(
              //   builder: (ctx) => OrdersScreen(),
              // ));
              Navigator.of(context)
                  .pushReplacementNamed(OrdersScreen.ROUTE_NAME);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: const Text("Manage Products"),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserProductsScreen.ROUTE_NAME);
            },
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text("Logout"),
            onTap: () {
              Provider.of<AuthProvider>(
                context,
                listen: false,
              ).logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
