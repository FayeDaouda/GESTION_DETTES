import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/auth_controller.dart';
import 'controllers/client_controller.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Injection des controllers au démarrage
  Get.put(AuthController());
  Get.put(ClientController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Tu peux aussi récupérer ici un controller si besoin avec Get.find()

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Gestion Clients',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/dashboard', page: () => DashboardPage()),
        // ajoute d’autres pages ici
      ],
    );
  }
}
