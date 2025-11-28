import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/pages/about_page.dart';
import 'package:ecommerceapp/pages/checkout.dart';
import 'package:ecommerceapp/pages/details_screen.dart';
import 'package:ecommerceapp/pages/profile_page.dart';
import 'package:ecommerceapp/provider/cart.dart';
import 'package:ecommerceapp/services/api_service.dart';
import 'package:ecommerceapp/shared/appbar.dart';
import 'package:ecommerceapp/shared/colors.dart';
import 'package:ecommerceapp/model/item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Item>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = ApiService.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    final carttt = Provider.of<Cart>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        actions: const [ProductsAndPrice()],
        backgroundColor: appbarGreen,
        title: const Text("Home"),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const UserAccountsDrawerHeader(
                    accountEmail: Text("Loading..."),
                    accountName: Text("Loading..."),
                    currentAccountPicture: CircleAvatar(),
                  );
                }
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                String fullName = data?['username'] ?? 'User';
                String email = data?['email'] ?? user?.email ?? '';
                String imgLink = data?['imgLink'] ?? 'assets/img/avatar1.png';

                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/img/tesst.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: imgLink.startsWith('assets/')
                        ? AssetImage(imgLink) as ImageProvider
                        : NetworkImage(imgLink),
                  ),
                  accountEmail: Text(email),
                  accountName: Text(fullName),
                );
              },
            ),
            ListTile(
              title: const Text("Home"),
              leading: const Icon(Icons.home),
              onTap: () {},
            ),
            ListTile(
              title: const Text("My products"),
              leading: const Icon(Icons.shopping_cart),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Checkout()),
              ),
            ),
            ListTile(
              title: const Text("Profile"),
              leading: const Icon(Icons.person),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              ),
            ),

            ListTile(
              title: const Text("About US"),
              leading: const Icon(Icons.person),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutPage()),
              ),
            ),
            ListTile(
              title: const Text("Logout"),
              leading: const Icon(Icons.exit_to_app),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted)
                  Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 22, left: 8, right: 8),
        child: FutureBuilder<List<Item>>(
          future: _productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    Text("Error: ${snapshot.error}"),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _productsFuture = ApiService.getProducts();
                        });
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            final products = snapshot.data!.take(10).toList();
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 40,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Details(product: products[index]),
                      ),
                    );
                  },
                  child: AnimatedProductCard(
                    item: products[index],
                    onAdd: () {
                      carttt.add(products[index]);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Added to cart!"),
                          duration: Duration(seconds: 1),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class AnimatedProductCard extends StatefulWidget {
  final Item item;
  final VoidCallback onAdd;
  const AnimatedProductCard({required this.item, required this.onAdd, Key? key})
    : super(key: key);

  @override
  State<AnimatedProductCard> createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<AnimatedProductCard> {
  bool _isHovered = false;
  bool _added = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
        transformAlignment: Alignment.center,
        child: Container(
          width: 35,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Hero(
                  tag: 'product-${widget.item.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(55),
                    child: Image.network(
                      widget.item.imgPath,
                      fit: BoxFit.cover,
                      loadingBuilder: (c, child, p) => p == null
                          ? child
                          : const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(55),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${widget.item.price}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => _added = true);
                          widget.onAdd();
                          Future.delayed(const Duration(milliseconds: 800), () {
                            if (mounted) setState(() => _added = false);
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _added ? 85 : 75,
                          height: 34,
                          decoration: BoxDecoration(
                            color: _added
                                ? Colors.green
                                : const Color.fromARGB(255, 62, 94, 70),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: _added
                                ? [
                                    const BoxShadow(
                                      color: Colors.green,
                                      blurRadius: 6,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _added ? Icons.check : Icons.add,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                if (!_added) const SizedBox(width: 3),
                                Text(
                                  _added ? "Added" : "Add",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
