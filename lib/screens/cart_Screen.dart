import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/cart.dart' show Cart;
import 'package:shop/providers/orders.dart';
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static String routeName = '/cart';
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(children: [
        Card(
          margin: const EdgeInsets.all(15),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  width: 10,
                ),
                Chip(
                  label: Text('\$${cart.totalAmount.toStringAsFixed(2)}'),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                OutlinedButton(
                    onPressed: cart.totalAmount <= 0
                        ? null
                        : () async {
                            await Provider.of<Orders>(context, listen: false)
                                .addOrder(cart.items.values.toList(),
                                    cart.totalAmount);

                            cart.clear();
                          },
                    child: const Text('Order Now'))
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
            child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (ctx, i) => CartItem(
                    cart.items.values.toList()[i].id,
                    cart.items.keys.toList()[i],
                    cart.items.values.toList()[i].price,
                    cart.items.values.toList()[i].quantity,
                    cart.items.values.toList()[i].title)))
      ]),
    );
  }
}
