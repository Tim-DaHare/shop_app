import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavorite() async {
    final url =
        "https://flutter-shop-app-faab7.firebaseio.com/products/$id.json";

    final originalValue = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners(); //optimistic update

    try {
      final response = await http.patch(
        url,
        body: jsonEncode({
          "isFavorite": isFavorite,
        }),
      );
      if (response.statusCode >= 300) {
        throw HttpException("Could not toggle favorite for product: $title");
      }
    } catch (error) {
      // reset optimistic update if request fails
      isFavorite = originalValue;
      notifyListeners();

      print(error);
      throw (error);
    }
  }
}
