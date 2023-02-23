import 'package:flutter/material.dart';
import 'package:shop/providers/auth.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/providers/orders.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/screens/auth_screen.dart';
import 'package:shop/screens/cart_Screen.dart';
import 'package:shop/screens/edit_product_screen.dart';
import 'package:shop/screens/orders_screens.dart';
import 'package:shop/screens/product_detail_screen.dart';
import 'package:shop/screens/products_screen.dart';
import 'package:shop/screens/splash_screen.dart';
import 'package:shop/screens/user_products_screen.dart';
import './providers/products.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: Auth()),
          ChangeNotifierProxyProvider<Auth, Products>(
              create: (ctx) => Products('', '', []),
              update: (ctx, auth, previous) => Products(auth.token, auth.userId,
                  previous == null ? [] : previous.products)),
          ChangeNotifierProvider.value(value: Cart()),
          ChangeNotifierProxyProvider<Auth, Orders>(
              create: (ctx) => Orders('', '', []),
              update: (ctx, auth, previous) =>
                  Orders(auth.token, auth.userId, previous!.orders)),
        ],
        child: Consumer<Auth>(
          builder: (context, auth, _) => MaterialApp(
            title: 'Shopping App',
            theme: ThemeData(
              primarySwatch: Colors.cyan,
              accentColor: Colors.amber,
              fontFamily: 'Lato',
            ),
            home: auth.isAuth
                ? ProductsScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, snapshot) =>
                        snapshot.connectionState == ConnectionState.waiting
                            ? const SplashScreen()
                            : AuthScreen()),
            routes: {
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen()
            },
          ),
        ));
  }
}
