import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static String routeName = 'edit-product';

  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  Product _editedProduct =
      Product(description: '', id: '', imageUrl: '', price: 0, title: '');
  bool _isInit = true;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  var _isLoading = false;

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  @override
  void didChangeDependencies() {
    if (widget._isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments as String?;
      if (productId != null) {
        widget._editedProduct =
            Provider.of<Products>(context).findById(productId);
        widget._initValues = {
          'title': widget._editedProduct.title,
          'description': widget._editedProduct.description,
          'price': widget._editedProduct.price.toString(),
          'imageUrl': '',
        };
        widget._imageUrlController.text = widget._editedProduct.imageUrl;
      }
    }
    widget._isInit = false;
    super.didChangeDependencies();
  }

  void _saveForm() async {
    final isValid = widget._form.currentState?.validate();
    if (!isValid!) return;
    widget._form.currentState?.save();
    setState(() {
      widget._isLoading = true;
    });
    if (widget._editedProduct.id != '') {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(widget._editedProduct.id, widget._editedProduct);
    } else {
      Provider.of<Products>(context, listen: false)
          .addProduct(widget._editedProduct)
          .catchError((error) {
        return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text('Somethign went wrong!'),
                  content: Text(error.toString()),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Close'))
                  ],
                ));
      });
    }
    setState(() {
      widget._isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message'),
      ),
      body: widget._isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.amber,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                  key: widget._form,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: widget._initValues['title'] as String,
                        decoration: const InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter a title';
                          }
                          return null;
                        },
                        onSaved: (newValue) => widget._editedProduct = Product(
                          description: widget._editedProduct.description,
                          id: widget._editedProduct.id,
                          isFavorite: widget._editedProduct.isFavorite,
                          imageUrl: widget._editedProduct.imageUrl,
                          price: widget._editedProduct.price,
                          title: newValue as String,
                        ),
                      ),
                      TextFormField(
                        initialValue: widget._initValues['price'] as String,
                        decoration: const InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter a price';
                          }
                          if (double.tryParse(value) == null ||
                              double.parse(value) <= 0) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                        onSaved: (newValue) => widget._editedProduct = Product(
                          description: widget._editedProduct.description,
                          id: widget._editedProduct.id,
                          isFavorite: widget._editedProduct.isFavorite,
                          imageUrl: widget._editedProduct.imageUrl,
                          price: double.parse(newValue as String),
                          title: widget._editedProduct.title,
                        ),
                      ),
                      TextFormField(
                        initialValue:
                            widget._initValues['description'] as String,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter a description';
                          }
                          return null;
                        },
                        maxLines: 3,
                        onSaved: (newValue) => widget._editedProduct = Product(
                          description: newValue as String,
                          id: widget._editedProduct.id,
                          isFavorite: widget._editedProduct.isFavorite,
                          imageUrl: widget._editedProduct.imageUrl,
                          price: widget._editedProduct.price,
                          title: widget._editedProduct.title,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(top: 15, right: 10),
                            decoration: BoxDecoration(
                                border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            )),
                            child: widget._imageUrlController.text.isEmpty
                                ? const Text('Enter Url')
                                : FittedBox(
                                    child: Image.network(
                                        widget._imageUrlController.text),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Image Url'),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.url,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter an image Url';
                                }
                                if (!value.startsWith('https') ||
                                    !value.startsWith('https')) {
                                  return 'Enter a valid url';
                                }
                                return null;
                              },
                              controller: widget._imageUrlController,
                              onEditingComplete: () => setState(() {}),
                              onSaved: (newValue) =>
                                  widget._editedProduct = Product(
                                description: widget._editedProduct.description,
                                id: widget._editedProduct.id,
                                isFavorite: widget._editedProduct.isFavorite,
                                imageUrl: newValue as String,
                                price: widget._editedProduct.price,
                                title: widget._editedProduct.title,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 50),
                        child: ElevatedButton(
                          onPressed: () => _saveForm(),
                          child: const Text('Add Product'),
                          style: ElevatedButton.styleFrom(
                              primary: Theme.of(context).accentColor),
                        ),
                      )
                    ],
                  )),
            ),
    );
  }
}
