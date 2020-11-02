import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartItem extends StatelessWidget {
  final ShoppingCartItem cartItem;

  const CartItem({
    Key key,
    @required this.cartItem,
  }) : super(key: key);

  Future<bool> _cartItemConfirmDismiss(wCtx) {
    return showDialog(
      context: wCtx,
      builder: (ctx) => AlertDialog(
        title: Text("Are you sure?"),
        content: Text("Do you want to remove the item from the cart?"),
        actions: [
          FlatButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text("No"),
          ),
          FlatButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text("Yes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Dismissible(
      key: ValueKey(cartItem.product.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _cartItemConfirmDismiss(context),
      onDismissed: (_) => cartProvider.removeItem(cartItem),
      background: Container(
        color: Theme.of(context).errorColor,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: FittedBox(
                  child:
                      Text("\$ ${cartItem.product.price.toStringAsFixed(2)}"),
                ),
              ),
            ),
            title: Text(cartItem.product.title),
            subtitle:
                Text("Total: \$${cartItem.totalPrice.toStringAsFixed(2)}"),
            trailing: Text("${cartItem.quantity} x"),
          ),
        ),
      ),
    );
  }
}
