import 'package:flutter/material.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/screens/cart_Screen.dart';
import 'package:shop/widgets/badge.dart';
import '../providers/product.dart';
import '../widgets/MainDrawer.dart';
import '../widgets/product_item.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

enum FilterOptions { Favorites, All }

class ProductsScreen extends StatefulWidget {
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool showFav = false;
  bool _isInit = true;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isLoading = true;
      Provider.of<Products>(context)
          .getProducts()
          .then((_) => _isLoading = false);
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<Products>(context);
    List<Product> products =
        showFav ? productsProvider.favorites : productsProvider.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Amazon',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions value) {
              setState(() {
                if (value == FilterOptions.All) {
                  showFav = false;
                } else {
                  showFav = true;
                }
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(
                child: Text('Favorites'),
                value: FilterOptions.Favorites,
              ),
              const PopupMenuItem(
                child: Text('Show all'),
                value: FilterOptions.All,
              ),
            ],
          ),
          Consumer<Cart>(
              builder: (_, cartProvider, ch) => Badge(
                    value: cartProvider.itemCount.toString(),
                    color: Theme.of(context).accentColor,
                    child: ch!,
                  ),
              child: IconButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(CartScreen.routeName),
                icon: const Icon(Icons.shopping_cart),
              ))
        ],
      ),
      drawer: MainDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.amber,
            ))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10),
              itemCount: products.length,
              padding: const EdgeInsets.all(10),
              itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                value: products[i],
                child: ProductItem(),
              ),
            ),
    );
  }
}
