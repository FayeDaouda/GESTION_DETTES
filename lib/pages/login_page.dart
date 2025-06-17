import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'dashboard_page.dart';


class LoginPage extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

 void _tryLogin(BuildContext context) {
  String user = userController.text.trim();
  String pass = passwordController.text.trim();
  bool success = authController.login(user, pass);
  if (success) {
    // Redirection vers DashboardPage
    Get.off(() => DashboardPage());
  } else {
    Get.snackbar('Erreur', authController.errorMessage.value,
        snackPosition: SnackPosition.BOTTOM);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: userController,
              decoration: InputDecoration(labelText: 'Login'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _tryLogin(context),
              child: const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}
