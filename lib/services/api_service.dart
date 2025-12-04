import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/item.dart';

class ApiService {
  static const String url = 'https://dummyjson.com/products';

  static Future<List<Item>> getProducts() async {
    //req get 
    final response = await http.get(Uri.parse(url));
   //si res ok 
    if (response.statusCode == 200) {
      //décode json en Map
      final data = json.decode(response.body);
      final List products = data['products'];
      // Convertit chaque objet JSON en objet Item grâce à fromJson
      return products.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }
}