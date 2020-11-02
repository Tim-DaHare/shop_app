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

  ShoppingCartItem addItem(Product product) {
    var existingItem = _items.firstWhere(
      (cItem) => cItem.product.id == product.id,
      orElse: () => null,
    );

    if (existingItem != null) {
      existingItem.quantity += 1;
      return existingItem;
    }

    final cartItem = ShoppingCartItem(product: product, quantity: 1);

    _items.add(cartItem);
    notifyListeners();

    return cartItem;
  }

  void removeItem(ShoppingCartItem cartItem, {int quantityToRemove}) {
    // Remove only the selected quantity
    if (quantityToRemove != null) {
      final itemIndex = _items.indexOf(cartItem);

      if (itemIndex < 0)
        return; // do nothing if cartItem is not included in list

      final newQuantity = _items[itemIndex].quantity - quantityToRemove;
      newQuantity > 0
          ? _items[itemIndex].quantity = newQuantity
          : _items.remove(cartItem);
    }
    // Just remove the entire cart item from the cart
    else {
      _items.remove(cartItem);
    }

    notifyListeners();
  }

  void clearCart() {
    _items = [];
    notifyListeners();
  }
}
