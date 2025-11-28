import 'package:ecommerceapp/firebase_options.dart';
import 'package:ecommerceapp/pages/home.dart';
import 'package:ecommerceapp/pages/sign_in.dart';
import 'package:ecommerceapp/provider/cart.dart';
import 'package:ecommerceapp/provider/google_signin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Cart()),
        ChangeNotifierProvider(create: (_) => GoogleSignInProvider()),
      ],
      child: MaterialApp(
        title: "myApp",
        debugShowCheckedModeBanner: false,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }

            if (snapshot.hasError) {
             
              return const Scaffold(
                body: Center(
                  child: Text(
                    "Something went wrong",
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                ),
              );
            }

            if (snapshot.hasData) {
              return const Home();
            }

            return const Login();
          },
        ),
      ),
    );
  }
}
