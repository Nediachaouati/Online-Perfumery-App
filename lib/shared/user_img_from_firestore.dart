import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ImgUser extends StatefulWidget {
  const ImgUser({Key? key}) : super(key: key);
  @override
  State<ImgUser> createState() => _ImgUserState();
}

class _ImgUserState extends State<ImgUser> {
  final credential = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(credential!.uid).get(), //chercher user data
      builder: (context, snapshot) { // avatar par défaut
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const CircleAvatar(
            radius: 71,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage("assets/img/avatar1.png"),
          );
        }

        // récupère le chemin de l’image sauvegardée dans Firestore
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final imgPath = data["imgLink"] ?? "assets/img/avatar1.png";

        return CircleAvatar(
          radius: 71,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage(imgPath),
        );
      },
    );
  }
}