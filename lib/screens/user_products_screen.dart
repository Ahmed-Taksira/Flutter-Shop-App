import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/screens/edit_product_screen.dart';
import 'package:shop/widgets/MainDrawer.dart';
import 'package:shop/widgets/user_product_item.dart';

class UserProductsScreen extends StatefulWidget {
  static String routeName = '/user-products';

  @override
  State<UserProductsScreen> createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  @override
  void initState() {
    Provider.of<Products>(context, listen: false).getProducts(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<Products>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(EditProductScreen.routeName),
              icon: const Icon(
                Icons.add_circle,
                color: Colors.white,
              ))
        ],
      ),
      drawer: MainDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView.builder(
            itemCount: productsProvider.products.length,
            itemBuilder: (ctx, i) => UserProductItem(
                  productsProvider.products[i].id,
                  productsProvider.products[i].title,
                  productsProvider.products[i].imageUrl,
                )),
      ),
    );
  }
}
