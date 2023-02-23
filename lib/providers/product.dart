import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFavorite;

  Product(
      {required this.description,
      required this.id,
      required this.imageUrl,
      this.isFavorite = false,
      required this.price,
      required this.title});

  Future<void> toggleFavorite(String? token, String? userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.parse(
        'https://flutter-shop-b9c11-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token');
    try {
      final res = await http.put(url, body: json.encode(isFavorite));

      if (res.statusCode >= 400) {
        isFavorite = oldStatus;
        notifyListeners();
      }
    } catch (error) {
      isFavorite = oldStatus;
      notifyListeners();
    }
  }
}
