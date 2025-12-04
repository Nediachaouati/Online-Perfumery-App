import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/shared/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Récupère user connecté
  final user = FirebaseAuth.instance.currentUser;


  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void dispose() {//nettoyage
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

 
  void _showEditDialog({
    required String title,
    required String currentValue,
    required String field,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    controller.text = currentValue;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Modifier $title"),
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: "Nouveau $title",
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;

              try {
                await FirebaseFirestore.instance //update dans Firestore
                    .collection('users')
                    .doc(user!.uid)
                    .update({field: controller.text.trim()});

                if (!mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Mis à jour !")));
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Erreur : $e")));
              }
            },
            child: const Text("Sauvegarder"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Aucun utilisateur connecté")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: appbarGreen,
        title: const Text("Profil"),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pop(context);
            },
          ),
        ],
      ),
      // donnes reel depuis firestore
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .snapshots(), // Met à jour automatiquement si les données changent
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          String imgLink = data?['imgLink'] ?? 'assets/img/avatar1.png';
          String fullName = data?['username'] ?? 'No Name';
          String email = data?['email'] ?? '';
          String age = data?['age'] ?? '';

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // AVATAR
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.white,
                        backgroundImage: imgLink.startsWith('assets/')
                            ? AssetImage(imgLink) as ImageProvider
                            : NetworkImage(imgLink),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(Icons.add_a_photo, size: 20),
                            color: Colors.grey,
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (_) => _buildAvatarGrid(),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  //CARTE INFO 
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 25,
                        horizontal: 20,
                      ),
                      child: Column(
                        children: [
                          _buildEditableRow(
                            icon: Icons.person,
                            label: "Nom",
                            value: fullName,
                            onEdit: () => _showEditDialog(
                              title: "Nom",
                              currentValue: fullName,
                              field: 'username',
                              controller: _nameController,
                            ),
                          ),
                          const Divider(height: 30),
                          _buildEditableRow(
                            icon: Icons.email,
                            label: "Email",
                            value: email,
                            onEdit: () => _showEditDialog(
                              title: "Email",
                              currentValue: email,
                              field: 'email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          const Divider(height: 30),
                          _buildEditableRow(
                            icon: Icons.cake,
                            label: "Âge",
                            value: age,
                            onEdit: () => _showEditDialog(
                              title: "Âge",
                              currentValue: age,
                              field: 'age',
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ligne modifiable
  Widget _buildEditableRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Row(
      children: [
        Icon(icon, color: appbarGreen),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$label:",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: onEdit,
        ),
      ],
    );
  }

  // grille avatar 
  Widget _buildAvatarGrid() {
    final avatars = [
      "avatar1.png",
      "avatar2.png",
      "avatar3.png",
      "avatar4.png",
    ];
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 4,
        children: avatars.map((img) {
          return GestureDetector(
            onTap: () async {
              String newImg = "assets/img/$img";
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .update({"imgLink": newImg});
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset("assets/img/$img", fit: BoxFit.cover),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
