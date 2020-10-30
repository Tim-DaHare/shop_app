import 'package:flutter/foundation.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/widgets/cart_item.dart';

class ShoppingCartItem {
  final Product product;
  int quantity;

  ShoppingCartItem({
    @required this.product,
    @required this.quantity,
  });

  double get totalPrice {
    return product.price * quantity;
  }
}

class CartProvider with ChangeNotifier {
  List<ShoppingCartItem> _items = [];

  List<ShoppingCartItem> get items {
    return [..._items];
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((cItem) => total += cItem.totalPrice);
    return total;
  }

  void addItem(Product product) {
    var existingItem = _items.firstWhere(
      (cItem) => cItem.product.id == product.id,
      orElse: () => null,
    );

    if (existingItem != null) {
      existingItem.quantity += 1;
      return;
    }

    _items.add(ShoppingCartItem(product: product, quantity: 1));
    notifyListeners();
  }

  void removeItem(ShoppingCartItem cartItem) {
    _items.remove(cartItem);
    notifyListeners();
  }

  void clearCart() {
    _items = [];
    notifyListeners();
  }
}
