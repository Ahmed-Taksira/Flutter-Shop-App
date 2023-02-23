import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/orders.dart' show Orders;
import 'package:shop/widgets/MainDrawer.dart';
import '../widgets/order_itemW.dart';

class OrdersScreen extends StatefulWidget {
  static String routeName = '/order';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    _isLoading = true;

    Provider.of<Orders>(context, listen: false)
        .getOrders()
        .then((_) => setState(() {
              _isLoading = false;
            }));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      drawer: MainDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.amber,
              ),
            )
          : ListView.builder(
              itemCount: ordersProvider.orders.length,
              itemBuilder: (_, i) => OrderItemW(ordersProvider.orders[i])),
    );
  }
}
