import 'package:ecommerceapp/model/item.dart';
import 'package:flutter/material.dart';

class Cart with ChangeNotifier { //notifier auto interface quand panier change
  List selectedProducts = [];
  int price = 0;

  add(Item product) {
    selectedProducts.add(product);
    price += product.price.round();
    notifyListeners();
  }

  delete(Item product) {
    selectedProducts.remove(product);
    price -= product.price.round();

    notifyListeners();
  }

  get itemCount {
    return selectedProducts.length;
  }
}