import 'package:flutter/foundation.dart';
import 'package:shop_app/providers/cart_provider.dart';

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
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  int get totalOrders {
    return _orders.length;
  }

  void addOrder(List<ShoppingCartItem> products) {
    const url = "https://flutter-shop-app-faab7.firebaseio.com/orders.json";

    _orders.add(OrderItem(
      id: '1',
      products: products,
    ));
    notifyListeners();
  }
}
