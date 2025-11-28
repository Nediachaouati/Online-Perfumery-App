import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/item.dart';

class ApiService {
  static const String url = 'https://dummyjson.com/products';

  static Future<List<Item>> getProducts() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List products = data['products'];
      return products.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }
}