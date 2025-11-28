import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GetDataFromFirestore extends StatefulWidget {
  final String documentId;
  const GetDataFromFirestore({Key? key, required this.documentId}) : super(key: key);

  @override
  State<GetDataFromFirestore> createState() => _GetDataFromFirestoreState();
}

class _GetDataFromFirestoreState extends State<GetDataFromFirestore> {
  final dialogUsernameController = TextEditingController();
  final credential = FirebaseAuth.instance.currentUser;

  myDialog(Map data, dynamic mykey) {
    dialogUsernameController.text = data[mykey] ?? "";
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        child: Container(
          padding: const EdgeInsets.all(22),
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(controller: dialogUsernameController, maxLength: 20),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(credential!.uid)
                          .update({mykey: dialogUsernameController.text});
                      Navigator.pop(context);
                    },
                    child: const Text("Edit", style: TextStyle(fontSize: 17)),
                  ),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(fontSize: 17))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(widget.documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Something went wrong");
        if (!snapshot.hasData || !snapshot.data!.exists) return const Text("Document does not exist");
        if (snapshot.connectionState == ConnectionState.done) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 9),
              _buildRow("Username", data['username'], 'username'),
              _buildRow("Email", data['email'], 'email'),
              _buildRow("Age", "${data['age']} years old", 'age'),
              _buildRow("Title", data['title'], 'title'),
              Center(
                child: TextButton(
                  onPressed: () => FirebaseFirestore.instance.collection('users').doc(credential!.uid).delete(),
                  child: const Text("Delete Data", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          );
        }
        return const Text("loading");
      },
    );
  }

  Widget _buildRow(String label, String? value, String key) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("$label: $value", style: const TextStyle(fontSize: 17)),
        Row(
          children: [
            IconButton(
              onPressed: () => FirebaseFirestore.instance.collection('users').doc(credential!.uid).update({key: FieldValue.delete()}),
              icon: const Icon(Icons.delete),
            ),
            IconButton(onPressed: () => myDialog({'$key': value}, key), icon: const Icon(Icons.edit)),
          ],
        ),
      ],
    );
  }
}