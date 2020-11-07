import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';

import '../models/product.dart';
import '../screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final Product product;

  const UserProductItem({
    Key key,
    @required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductsProvider>(
      context,
      listen: false,
    );
    final scaffold = Scaffold.of(context);

    void _onPressEdit() {
      Navigator.of(context).pushNamed(
        EditProductScreen.ROUTE_NAME,
        arguments: product,
      );
    }

    Future<void> _onPressDelete() async {
      try {
        await productProvider.deleteProduct(product);
      } catch (e) {
        scaffold.showSnackBar(
          SnackBar(
            content: Text("Deletion failed", textAlign: TextAlign.center),
          ),
        );
      }
    }

    return ListTile(
      title: Text(product.title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(product.imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
              onPressed: _onPressEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              color: Theme.of(context).errorColor,
              onPressed: _onPressDelete,
            ),
          ],
        ),
      ),
    );
  }
}
