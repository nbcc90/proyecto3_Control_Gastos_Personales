// lib/views/login.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:gastos_personales/models/user_store.dart';

class LoginController extends GetxController {
  final userController = TextEditingController(text: 'test@test');
  final passwordController = TextEditingController(text: '1234');
  final obscurePassword = true.obs;

  void togglePasswordVisibility() => obscurePassword.toggle();

  Future<void> login(BuildContext context) async {
    final email = userController.text.trim();
    final pass  = passwordController.text.trim();

    // Validaciones básicas
    if (email.isEmpty || pass.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: const Text('El usuario y la contraseña no pueden estar vacíos'),
          actions: [TextButton(onPressed: () => context.pop(), child: const Text('Entiendo'))],
        ),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El correo no es válido'), backgroundColor: Colors.red),
      );
      return;
    }

    // Autenticación contra la lista de usuarios guardados
    final error = await UserStore.login(email, pass);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    // Sesión OK (UserStore ya escribió isLoggedIn/currentUser)
    context.goNamed('home', pathParameters: {'user': email});
  }

  @override
  void onClose() {
    userController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final controller = Get.put(LoginController());

  final enabledBorderStyle = const UnderlineInputBorder(
    borderSide: BorderSide(color: Color.fromRGBO(255, 255, 255, 0.4), width: 1),
  );
  final focusedBorderStyle = const UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Color.fromARGB(255, 181, 42, 205)],
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    'Control de Gastos Personales',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(255, 255, 255, 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Registra tus ingresos y gastos',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromRGBO(255, 255, 255, 0.8),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Image.asset('assets/imagen1.png', height: 150),
                  const SizedBox(height: 50),

                  TextField(
                    controller: controller.userController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.8)),
                    decoration: InputDecoration(
                      labelText: 'Correo',
                      labelStyle: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.8)),
                      hintText: 'Ingrese su correo',
                      hintStyle: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.6)),
                      enabledBorder: enabledBorderStyle,
                      focusedBorder: focusedBorderStyle,
                      prefixIcon: const Icon(Icons.email_outlined, color: Color.fromRGBO(255, 255, 255, 0.8)),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Obx(() => TextField(
                    controller: controller.passwordController,
                    obscureText: controller.obscurePassword.value,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.8)),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.8)),
                      hintText: 'Ingrese su contraseña',
                      hintStyle: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.6)),
                      enabledBorder: enabledBorderStyle,
                      focusedBorder: focusedBorderStyle,
                      prefixIcon: const Icon(Icons.password_rounded, color: Color.fromRGBO(255, 255, 255, 0.8)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePassword.value ? Icons.remove_red_eye : Icons.visibility_off,
                          color: const Color.fromRGBO(255, 255, 255, 0.8),
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                  )),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: 280,
                    child: ElevatedButton(
                      onPressed: () => controller.login(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 198, 244, 32),
                        foregroundColor: const Color.fromARGB(255, 31, 30, 30),
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      child: const Text('Iniciar Sesión'),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text('¿No tienes cuenta? Regístrate', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}