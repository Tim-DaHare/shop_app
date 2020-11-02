import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../models/product.dart';

class _EditProductFormValues {
  String title;
  String description;
  double price;
  String imageUrl;
}

class EditProductScreen extends StatefulWidget {
  static const String ROUTE_NAME = "/edit_product";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  final _formValues = _EditProductFormValues();
  var isInitialized = false;

  Product productToEdit;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!isInitialized) {
      productToEdit = ModalRoute.of(context).settings.arguments as Product;

      if (productToEdit == null) {
        isInitialized = true;
        return;
      }

      _formValues.title = productToEdit.title;
      _formValues.price = productToEdit.price;
      _formValues.description = productToEdit.description;

      _imageUrlController.text = productToEdit.imageUrl;
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _descriptionFocusNode.removeListener(_updateImageUrl);

    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();

    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void _onSubmit() {
    final isValid = _form.currentState.validate();
    if (!isValid) return;

    final productsProvider =
        Provider.of<ProductsProvider>(context, listen: false);

    _form.currentState.save();

    if (productToEdit != null) {
      productsProvider.editProduct(Product(
        id: productToEdit.id,
        title: _formValues.title,
        description: _formValues.description,
        price: _formValues.price,
        imageUrl: _formValues.imageUrl,
        isFavorite: productToEdit.isFavorite,
      ));
    } else {
      productsProvider.addProduct(
        title: _formValues.title,
        price: _formValues.price,
        description: _formValues.description,
        imageUrl: _formValues.imageUrl,
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final focusScope = FocusScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _onSubmit,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: "${_formValues.title ?? ""}",
                  decoration: InputDecoration(labelText: "Title"),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                      focusScope.requestFocus(_priceFocusNode),
                  onSaved: (newValue) => _formValues.title = newValue,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "This is wrong";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: "${_formValues.price ?? ""}",
                  decoration: InputDecoration(labelText: "Price"),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                      focusScope.requestFocus(_descriptionFocusNode),
                  keyboardType: TextInputType.number,
                  focusNode: _priceFocusNode,
                  onSaved: (newValue) =>
                      _formValues.price = double.parse(newValue),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Please enter a price";
                    }

                    final price = double.tryParse(value);
                    if (price == null) {
                      return "Please enter a valid number";
                    }
                    if (price <= 0) {
                      return "Please enter a positive number";
                    }

                    return null;
                  },
                ),
                TextFormField(
                  initialValue: "${_formValues.description ?? ""}",
                  decoration: InputDecoration(labelText: "Description"),
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  focusNode: _descriptionFocusNode,
                  onSaved: (newValue) => _formValues.description = newValue,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Please enter a description";
                    }
                    if (value.length < 10) {
                      return "Should be at least 10 characters long";
                    }
                    return null;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(
                        top: 8,
                        right: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        ),
                      ),
                      child: _imageUrlController.text.isEmpty
                          ? Text("Enter image url")
                          : Image.network(
                              _imageUrlController.text,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: "Image Url"),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        controller: _imageUrlController,
                        focusNode: _imageUrlFocusNode,
                        onFieldSubmitted: (_) => _onSubmit,
                        onSaved: (newValue) => _formValues.imageUrl = newValue,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter an image url";
                          }
                          if (!value.startsWith('http') &&
                              !value.startsWith('https')) {
                            return "Please enter a valid url";
                          }
                          if (!value.endsWith('png') &&
                              !value.endsWith('jpg') &&
                              !value.endsWith('jpeg')) {
                            return "Please enter a valid image url";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
