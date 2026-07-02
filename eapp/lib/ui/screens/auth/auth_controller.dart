import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  late final AuthService _auth;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    _auth = Get.find<AuthService>();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('X', 'እባክዎን ሁሉንም መስኮች ይሙሉ (Please fill all fields)');
      return;
    }

    isLoading.value = true;
    final success = await _auth.login(email, password);
    isLoading.value = false;

    if (success) {
      Get.offAllNamed(AppRoutes.mainLayout);
    } else {
      Get.snackbar('ስህተት (Error)', 'የኢሜል ወይም የይለፍ ቃል ስህተት ነው (Invalid email or password)');
    }
  }

  Future<void> register() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar('X', 'እባክዎን ሁሉንም መስኮች ይሙሉ (Please fill all fields)');
      return;
    }

    isLoading.value = true;
    final success = await _auth.register(username, email, password);
    isLoading.value = false;

    if (success) {
      Get.offAllNamed(AppRoutes.mainLayout);
    } else {
      Get.snackbar('ስህተት (Error)', 'ይህ ኢሜል ወይም መለያ ስም ቀድሞ ተይዟል (Username/Email already exists)');
    }
  }
}
