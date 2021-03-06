import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import '../widgets/cart_item.dart';

class CartScreen extends StatefulWidget {
  static const String ROUTE_NAME = "/cart";

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    void _onPressOrder() async {
      setState(() => _isLoading = true);
      await orderProvider.addOrder(cartProvider.items);
      setState(() => _isLoading = false);

      cartProvider.clearCart();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: const TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      "\$${cartProvider.totalAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.title.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  FlatButton(
                    onPressed: cartProvider.itemCount > 0 && !_isLoading
                        ? _onPressOrder
                        : null,
                    child: !_isLoading
                        ? Text("Order Now")
                        : CircularProgressIndicator(),
                    textColor: Theme.of(context).primaryColor,
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cartProvider.itemCount,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CartItem(
                  cartItem: cartProvider.items[i],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
