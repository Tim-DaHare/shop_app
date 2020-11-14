import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/edit_product_screen.dart';

import '../providers/products_provider.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';

class UserProductsScreen extends StatefulWidget {
  static const String ROUTE_NAME = "/user_products";

  @override
  _UserProductsScreenState createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  var _isLoading = false;

  Future<void> _onRefresh(BuildContext ctx) async {
    try {
      setState(() => _isLoading = true);
      await Provider.of<ProductsProvider>(
        ctx,
        listen: false,
      ).fetchProducts(true);
      setState(() => _isLoading = false);
    } catch (error) {
      print(error);
    }
  }

  @override
  void initState() {
    _onRefresh(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final productsProvider = Provider.of<ProductsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Products"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => navigator.pushNamed(EditProductScreen.ROUTE_NAME),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading && productsProvider.items.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () => _onRefresh(context),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ListView.builder(
                  itemCount: productsProvider.items.length,
                  itemBuilder: (_, index) => Column(
                    children: [
                      UserProductItem(
                        product: productsProvider.items[index],
                      ),
                      Divider(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
