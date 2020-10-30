import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../screens/cart_screen.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../widgets/app_drawer.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/products_overview';

  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;

  @override
  Widget build(BuildContext context) {
    void _onSelectPopupItem(FilterOptions filter) {
      switch (filter) {
        case FilterOptions.Favorites:
          setState(() => _showOnlyFavorites = true);
          break;
        case FilterOptions.All:
          setState(() => _showOnlyFavorites = false);
          break;
        default:
          return;
      }
    }

    void _onPressBadge() =>
        Navigator.of(context).pushNamed(CartScreen.ROUTE_NAME);

    return Scaffold(
      appBar: AppBar(
        title: Text("Products Overview"),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            onSelected: _onSelectPopupItem,
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text("Only favorites"),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text("Show all"),
                value: FilterOptions.All,
              ),
            ],
          ),
          Consumer<CartProvider>(
            builder: (ctx, cart, child) => Badge(
              child: child,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: _onPressBadge,
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: ProductsGrid(
        showOnlyFavorites: _showOnlyFavorites,
      ),
    );
  }
}
