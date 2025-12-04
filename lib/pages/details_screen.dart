import 'package:ecommerceapp/model/item.dart';
import 'package:ecommerceapp/shared/appbar.dart';
import 'package:ecommerceapp/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:ecommerceapp/provider/cart.dart';

class Details extends StatefulWidget {
  final Item product;
  const Details({Key? key, required this.product}) : super(key: key);

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  bool isShowMore = true;
  bool showSuccess = false;

  @override
  Widget build(BuildContext context) {
    final carttt = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        actions: const [ProductsAndPrice()],
        backgroundColor: appbarGreen,
        title: const Text("Details"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Center( //animation
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: Hero(
                      tag: 'product-${widget.product.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(55),
                        child: Image.network(
                          widget.product.imgPath,
                          width: MediaQuery.of(context).size.width * 0.45,
                          height:
                              (MediaQuery.of(context).size.width * 0.45) *
                              (3 / 2),
                          fit: BoxFit.cover,
                          loadingBuilder: (c, child, p) => p == null
                              ? child
                              : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                          errorBuilder: (c, e, s) =>
                              const Icon(Icons.error, size: 80),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "\$${widget.product.price}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "New",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (_) => const Icon(
                            Icons.star,
                            size: 22,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Description:",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.product.description, 
                    style: const TextStyle(fontSize: 16, height: 1.6),
                    maxLines: isShowMore ? 4 : null,
                    overflow: isShowMore ? TextOverflow.ellipsis : null,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => isShowMore = !isShowMore),
                  child: Text(
                    isShowMore ? "Show more" : "Show less",
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
          // Lottie Animation
          if (showSuccess)
            Center(
              child: Lottie.asset(
                'assets/lottie/Success Check.json',
                width: 180,
                height: 180,
                repeat: false,
                onLoaded: (_) => Future.delayed(
                  const Duration(seconds: 2),
                  () => setState(() => showSuccess = false),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          carttt.add(widget.product);
          setState(() => showSuccess = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Product added to cart!"),
              backgroundColor: Colors.green,
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.check),
      ),
    );
  }
}
