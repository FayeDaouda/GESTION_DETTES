import 'package:get/get.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;
  var username = ''.obs;
  var errorMessage = ''.obs;

  // Mock utilisateur
  final Map<String, String> _mockUsers = {
    'admin': 'admin123',
  };

  bool login(String user, String password) {
    if (_mockUsers.containsKey(user) && _mockUsers[user] == password) {
      isLoggedIn.value = true;
      username.value = user;
      errorMessage.value = '';
      return true;
    } else {
      errorMessage.value = 'Identifiants invalides';
      return false;
    }
  }

  void logout() {
    isLoggedIn.value = false;
    username.value = '';
  }
}
