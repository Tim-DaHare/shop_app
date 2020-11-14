import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/auth_provider.dart';

import '../models/product.dart';

class ProductsProvider with ChangeNotifier {
  AuthProvider _authProvider;

  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  void updateAuthProvider(AuthProvider newAuthProvider) {
    _authProvider = newAuthProvider;
  }

  Future<void> fetchProducts([bool filterForUser = false]) async {
    final filterString = filterForUser
        ? "&orderBy=\"userId\"&equalTo=\"${_authProvider.userId}\""
        : "";
    final productsUrl =
        "https://flutter-shop-app-faab7.firebaseio.com/products.json?auth=${_authProvider.token}$filterString";

    final favoritesUrl =
        "https://flutter-shop-app-faab7.firebaseio.com/userFavorites/${_authProvider.userId}.json?auth=${_authProvider.token}";

    try {
      final productsResponse = await http.get(productsUrl);
      if (productsResponse.statusCode >= 300) {
        throw HttpException("Fetching products failed");
      }

      final productsData =
          jsonDecode(productsResponse.body) as Map<String, dynamic>;
      if (productsData == null) return;

      final favoritesReponse = await http.get(favoritesUrl);
      if (favoritesReponse.statusCode >= 300) {
        throw HttpException("Fetching favorites failed");
      }

      final favoritesData =
          jsonDecode(favoritesReponse.body) as Map<String, dynamic>;

      final List<Product> loadedProducts = [];
      productsData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData["title"],
          price: prodData["price"],
          description: prodData["description"],
          imageUrl: prodData["imageUrl"],
          isFavorite:
              favoritesData != null ? (favoritesData[prodId] ?? false) : false,
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<Product> addProduct(Product product) async {
    final url =
        "https://flutter-shop-app-faab7.firebaseio.com/products.json?auth=${_authProvider.token}";

    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'userId': _authProvider.userId,
        }),
      );

      final newProduct = Product(
        id: jsonDecode(response.body)["name"],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        isFavorite: product.isFavorite,
      );

      _items.add(newProduct);
      notifyListeners();

      return newProduct;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<Product> editProduct(Product editedProduct) async {
    final productIndex =
        _items.indexWhere((prod) => prod.id == editedProduct.id);
    if (productIndex < 0) return null; // product doesn't exist

    final url =
        "https://flutter-shop-app-faab7.firebaseio.com/products/${editedProduct.id}.json?auth=${_authProvider.token}";

    try {
      final repsonse = await http.patch(
        url,
        body: jsonEncode({
          "title": editedProduct.title,
          "price": editedProduct.price,
          "description": editedProduct.description,
          "imageUrl": editedProduct.imageUrl,
          "isFavorite": editedProduct.isFavorite,
        }),
      );
      print(repsonse.body);

      _items[productIndex] = editedProduct;
      notifyListeners();

      return editedProduct;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> toggleFavorite(Product product) async {
    final url =
        "https://flutter-shop-app-faab7.firebaseio.com/userFavorites/${_authProvider.userId}/${product.id}.json?auth=${_authProvider.token}";

    final originalValue = product.isFavorite;
    product.isFavorite = !product.isFavorite;
    notifyListeners(); //optimistic update

    try {
      final response = await http.put(
        url,
        body: jsonEncode(product.isFavorite),
      );
      if (response.statusCode >= 300) {
        throw HttpException(
          "Could not toggle favorite for product: ${product.title}",
        );
      }
    } catch (error) {
      // revert optimistic update if request fails
      product.isFavorite = originalValue;
      notifyListeners();

      print(error);
      throw (error);
    }
  }

  Future<void> deleteProduct(Product productToRemove) async {
    final url =
        "https://flutter-shop-app-faab7.firebaseio.com/products/${productToRemove.id}.json?auth=${_authProvider.token}";

    final productIndex = _items.indexOf(productToRemove);
    if (productIndex < 0) return; // Product doest exist

    try {
      _items.remove(productToRemove);
      notifyListeners(); // notify the optimistic update

      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        throw HttpException(
          "Could not delete product: ${productToRemove.title}",
        );
      }
    } catch (error) {
      // Undo the optimistic update if the request fails
      _items.insert(productIndex, productToRemove);
      notifyListeners(); // notify the optimistic update

      throw error;
    }
  }
}
