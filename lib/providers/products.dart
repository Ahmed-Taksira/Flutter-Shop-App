import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop/providers/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  final String? token;
  final String? userId;

  Products(this.token, this.userId, this._products);

  List<Product> _products = [
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

  List<Product> get products {
    return [..._products];
  }

  List<Product> get favorites {
    return _products.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _products.firstWhere((element) => element.id == id);
  }

  Future<void> getProducts([bool eachUser = false]) async {
    final filterUrl = eachUser ? '&orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://flutter-shop-b9c11-default-rtdb.firebaseio.com/products.json?auth=$token$filterUrl');
    final res = await http.get(url);
    try {
      final extractedData = json.decode(res.body) as Map<String, dynamic>;
      if (extractedData == null) return;

      url = Uri.parse(
          'https://flutter-shop-b9c11-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$token');
      final favoritesRes = await http.get(url);
      final favoritesData = json.decode(favoritesRes.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((id, prodData) {
        loadedProducts.add(Product(
            id: id,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            isFavorite:
                favoritesData == null ? false : favoritesData[id] ?? false,
            imageUrl: prodData['imageUrl']));
      });
      _products = loadedProducts;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addProduct(Product product) {
    final url = Uri.parse(
        'https://flutter-shop-b9c11-default-rtdb.firebaseio.com/products.json?auth=$token');
    return http
        .post(url,
            body: json.encode({
              'title': product.title,
              'description': product.description,
              'imageUrl': product.imageUrl,
              'price': product.price,
              'creatorId': userId
            }))
        .then((res) {
      final newProd = Product(
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
        title: product.title,
        isFavorite: false,
        id: json.decode(res.body)['name'],
      );
      _products.add(newProd);
      notifyListeners();
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> updateProduct(String id, Product product) async {
    final index = _products.indexWhere((element) => element.id == id);
    if (index >= 0) {
      final url = Uri.parse(
          'https://flutter-shop-b9c11-default-rtdb.firebaseio.com/products/$id.json?auth=$token');
      await http.patch(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'isFavorite': product.isFavorite,
          }));

      _products[index] = product;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    final url = Uri.parse(
        'https://flutter-shop-b9c11-default-rtdb.firebaseio.com/products/$id.json?auth=$token');
    http.delete(url);
    _products.removeWhere((element) => element.id == id);
    notifyListeners();
  }
}
