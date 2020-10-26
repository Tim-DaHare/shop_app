import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  static const String ROUTE_NAME = '/product_detail';

  const ProductDetailScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Product product = ModalRoute.of(context).settings.arguments;
    if (product == null)
      throw Exception(
        'Product detail page did not recieve a product as an argument',
      );

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
    );
  }
}
