import 'package:ecommerceapp/pages/verify_email.dart';
import 'package:ecommerceapp/shared/snackBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/pages/sign_in.dart';
import 'package:ecommerceapp/shared/colors.dart';
import 'package:ecommerceapp/shared/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool isVisable = true;
  String selectedImage = "assets/img/avatar.png";

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final ageController = TextEditingController();
  //final titleController = TextEditingController();

  bool isPassword8Char = false;
  bool isPasswordHas1Number = false;
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasSpecialCharacters = false;

  onPasswordChanged(String password) {
    setState(() {
      isPassword8Char = password.length >= 8;
      isPasswordHas1Number = password.contains(RegExp(r'[0-9]'));
      hasUppercase = password.contains(RegExp(r'[A-Z]'));
      hasLowercase = password.contains(RegExp(r'[a-z]'));
      hasSpecialCharacters = password.contains(
        RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
      );
    });
  }

  register() async {
    if (!_formKey.currentState!.validate()) {
      showSnackBar(context, "Please fill all fields correctly");
      return;
    }

    setState(() => isLoading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text,
          );

      // Enregistrer dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
            "imgLink": selectedImage,
            'username': usernameController.text,
            'age': ageController.text,
            // "title": titleController.text,
            "email": emailController.text,
          });

      // ENVOYER L'EMAIL DE VÉRIFICATION
      await credential.user!.sendEmailVerification();

      if (!mounted) return;

      // REDIRECTION VERS VerifyEmailPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VerifyEmailPage()),
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.code);
    } catch (err) {
      showSnackBar(context, "Error: $err");
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    ageController.dispose();
    //titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: appbarGreen,
      ),
      backgroundColor: const Color.fromARGB(255, 247, 247, 247),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(33.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // --- AVATAR ---
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(125, 78, 91, 110),
                    ),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 71,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage(selectedImage),
                        ),
                        Positioned(
                          left: 99,
                          bottom: -10,
                          child: IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (_) => Container(
                                  height: 200,
                                  padding: const EdgeInsets.all(16),
                                  child: GridView.count(
                                    crossAxisCount: 4,
                                    children: [
                                      for (var img in [
                                        "avatar1.png",
                                        "avatar2.png",
                                        "avatar3.png",
                                        "avatar4.png",
                                      ])
                                        GestureDetector(
                                          onTap: () {
                                            setState(
                                              () => selectedImage =
                                                  "assets/img/$img",
                                            );
                                            Navigator.pop(context);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Image.asset(
                                              "assets/img/$img",
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_a_photo),
                            color: const Color.fromARGB(255, 94, 115, 128),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 33),

                  // --- FORM ---
                  _buildTextField(usernameController, "Username", Icons.person),
                  const SizedBox(height: 22),
                  _buildTextField(
                    ageController,
                    "Age",
                    Icons.cake,
                    keyboardType: TextInputType.number,
                  ),
                  //const SizedBox(height: 22),
                  //_buildTextField(titleController, "Title", Icons.work),
                  const SizedBox(height: 22),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v!.contains('@') ? null : "Invalid email",
                    decoration: decorationTextfield.copyWith(
                      hintText: "Email",
                      suffixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 22),
                  TextFormField(
                    controller: passwordController,
                    obscureText: isVisable,
                    onChanged: onPasswordChanged,
                    validator: (_) => isPassword8Char ? null : "8+ chars",
                    decoration: decorationTextfield.copyWith(
                      hintText: "Password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          isVisable ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => isVisable = !isVisable),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- PASSWORD CHECKS ---
                  _buildCheck("8+ chars", isPassword8Char),
                  _buildCheck("1 number", isPasswordHas1Number),
                  _buildCheck("Uppercase", hasUppercase),
                  _buildCheck("Lowercase", hasLowercase),
                  _buildCheck("Special char", hasSpecialCharacters),
                  const SizedBox(height: 33),

                  // --- REGISTER BUTTON ---
                  ElevatedButton(
                    onPressed: register,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Register",
                            style: TextStyle(fontSize: 19),
                          ),
                  ),
                  const SizedBox(height: 33),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Have an account? ",
                        style: TextStyle(fontSize: 18),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const Login()),
                        ),
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 18,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: decorationTextfield.copyWith(
        hintText: hint,
        suffixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildCheck(String text, bool condition) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: condition ? Colors.green : Colors.white,
              border: Border.all(color: Colors.grey),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 15),
          ),
          const SizedBox(width: 11),
          Text(text),
        ],
      ),
    );
  }
}
