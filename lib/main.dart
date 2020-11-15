import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/splash_screen.dart';

import './helpers/custom_route.dart';
import './providers/auth_provider.dart';
import './providers/products_provider.dart';
import './providers/cart_provider.dart';
import './providers/orders_provider.dart';

import './screens/product_detail_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/cart_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => AuthProvider(provContext: ctx),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
          create: (ctx) => ProductsProvider(),
          update: (ctx, authProvider, prevValue) =>
              prevValue..updateAuthProvider(authProvider),
        ),
        ChangeNotifierProvider(create: (ctx) => CartProvider()),
        ChangeNotifierProvider(create: (ctx) => OrderProvider(context: ctx)),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, authProvider, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.android: CustomPageTransitionBuilder(),
              TargetPlatform.iOS: CustomPageTransitionBuilder()
            }),
          ),
          home: authProvider.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: authProvider.tryAutoLogin(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return SplashScreen();
                    return AuthScreen();
                  },
                ),
          routes: {
            AuthScreen.ROUTE_NAME: (_) => AuthScreen(),
            ProductsOverviewScreen.ROUTE_NAME: (_) => ProductsOverviewScreen(),
            CartScreen.ROUTE_NAME: (_) => CartScreen(),
            ProductDetailScreen.ROUTE_NAME: (_) => ProductDetailScreen(),
            OrdersScreen.ROUTE_NAME: (_) => OrdersScreen(),
            UserProductsScreen.ROUTE_NAME: (_) => UserProductsScreen(),
            EditProductScreen.ROUTE_NAME: (_) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
