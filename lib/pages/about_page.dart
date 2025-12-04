import 'package:flutter/material.dart';
import 'package:ecommerceapp/shared/colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appbarGreen,
        title: const Text("About Us"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
           
            CircleAvatar(
              radius: 70,
              backgroundImage: const AssetImage("assets/img/tesst.jpg"),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 24),

            
            const Text(
              "LUXE FRAGRANCES",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Premium Online Perfumery",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 30),

           
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "LUXE FRAGRANCES is your premier destination for luxury perfumes and niche fragrances. "
                  "Discover exclusive scents from the world’s most prestigious brands: Chanel, Dior, Creed, Tom Ford, Amouage and many more.\n\n"
                  "We offer authentic products, fast worldwide shipping, and a curated selection of rare and limited-edition perfumes. "
                  "Whether you’re looking for a signature scent or a unique gift, we bring elegance and sophistication straight to your door.",
                  style: TextStyle(fontSize: 16, height: 1.7),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 30),

            
            const Card(
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.email, color: appbarGreen),
                      title: Text("contact@luxefragrances.com"),
                    ),
                    ListTile(
                      leading: Icon(Icons.phone, color: appbarGreen),
                      title: Text("+216 76 45 89 12"),
                    ),
                    ListTile(
                      leading: Icon(Icons.location_on, color: appbarGreen),
                      title: Text("123 Avenue Yassime\n75008 Tunis, Tunisie"),
                    ),
                    ListTile(
                      leading: Icon(Icons.language, color: appbarGreen),
                      title: Text("www.luxefragrances.com"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            
            
          ],
        ),
      ),
    );
  }
}
