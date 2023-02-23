import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shop/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final DateTime dateTime;
  final List<CartItem> products;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.dateTime,
      required this.products});
}

class Orders with ChangeNotifier {
  final String? token;
  final String? userId;
  List<OrderItem> _orders = [];

  Orders(this.token, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> getOrders() async {
    final url = Uri.parse(
        'https://flutter-shop-b9c11-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token');
    final res = await http.get(url);
    final resData = json.decode(res.body) as Map<String, dynamic>;
    if (resData == null) return;
    final List<OrderItem> extractedData = [];
    resData.forEach((key, data) {
      extractedData.add(OrderItem(
        id: key,
        amount: data['amount'],
        dateTime: DateTime.parse(data['dateTime']),
        products: (data['products'] as List<dynamic>)
            .map((item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title'],
                ))
            .toList(),
      ));
    });

    _orders = extractedData.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://flutter-shop-b9c11-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token');
    final timestamp = DateTime.now();
    final res = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timestamp.toIso8601String(),
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
        }));
    _orders.insert(
        0,
        OrderItem(
          id: json.decode(res.body)['name'],
          amount: total,
          dateTime: timestamp,
          products: cartProducts,
        ));
    notifyListeners();
  }
}
