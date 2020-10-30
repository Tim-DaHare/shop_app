import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/products_provider.dart';
import './providers/cart_provider.dart';
import 'providers/orders_provider.dart';
import './screens/product_detail_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/cart_screen.dart';
import './screens/orders_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => ProductsProvider()),
        ChangeNotifierProvider(create: (ctx) => CartProvider()),
        ChangeNotifierProvider(create: (ctx) => OrderProvider()),
      ],
      child: MaterialApp(
        title: 'MyShop',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.deepOrange,
          fontFamily: 'Lato',
        ),
        initialRoute: ProductsOverviewScreen.ROUTE_NAME,
        routes: {
          ProductsOverviewScreen.ROUTE_NAME: (_) => ProductsOverviewScreen(),
          CartScreen.ROUTE_NAME: (_) => CartScreen(),
          ProductDetailScreen.ROUTE_NAME: (_) => ProductDetailScreen(),
          OrdersScreen.ROUTE_NAME: (_) => OrdersScreen(),
        },
      ),
    );
  }
}
