import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/providers/auth_provider.dart';

import './products_provider.dart';
import './cart_provider.dart';

class OrderItem {
  final String id;
  final List<ShoppingCartItem> products;
  DateTime _dateTime;

  OrderItem({
    @required this.id,
    @required this.products,
    DateTime dateTime,
  }) {
    _dateTime = dateTime ?? DateTime.now();
  }

  DateTime get dateTime {
    return _dateTime;
  }

  double get totalAmount {
    var total = 0.0;
    products.forEach((prod) => total += prod.totalPrice);
    return total;
  }

  int get productCount {
    return products.length;
  }
}

class OrderProvider with ChangeNotifier {
  final BuildContext context;
  List<OrderItem> _orders = [];

  OrderProvider({@required this.context});

  AuthProvider get _authProvider {
    return Provider.of<AuthProvider>(context, listen: false);
  }

  ProductsProvider get _productsProvider {
    return Provider.of<ProductsProvider>(context, listen: false);
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  int get totalOrders {
    return _orders.length;
  }

  Future<void> fetchOrders() async {
    final url =
        "https://flutter-shop-app-faab7.firebaseio.com/orders.json?auth=${_authProvider.token}";

    final response = await http.get(url);
    print(_authProvider.token);
    List<OrderItem> newItems = [];

    final ordersData = jsonDecode(response.body) as Map<String, dynamic>;
    if (ordersData == null) return;

    ordersData.forEach((orderId, orderData) {
      final orderProducts = (orderData["products"] as List<dynamic>).map(
        (productData) {
          final matchingProduct =
              _productsProvider.findById(productData["product_id"]);
          return ShoppingCartItem(
            product: matchingProduct,
            quantity: productData["quantity"],
          );
        },
      ).toList();

      newItems.add(
        OrderItem(
          id: orderId,
          products: orderProducts,
          dateTime: DateTime.parse(orderData["dateTime"]),
        ),
      );
    });

    _orders = newItems.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<ShoppingCartItem> products) async {
    final url =
        "https://flutter-shop-app-faab7.firebaseio.com/orders.json?auth=${_authProvider.token}";

    final dateTime = DateTime.now();
    final response = await http.post(
      url,
      body: jsonEncode({
        "dateTime": dateTime.toIso8601String(),
        "products": products
            .map((cartItem) => {
                  "product_id": cartItem.product.id,
                  "quantity": cartItem.quantity,
                })
            .toList()
      }),
    );

    _orders.add(OrderItem(
      id: jsonDecode(response.body)["name"],
      dateTime: dateTime,
      products: products,
    ));
    notifyListeners();
  }
}
