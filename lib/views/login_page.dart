// lib/src/views/login_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';

class LoginController extends GetxController {
  final userController = TextEditingController(text: 'test@test');
  final passwordController = TextEditingController(text: '1234');
  var obscurePassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  void login(BuildContext context) {
    if (userController.text.isEmpty || passwordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error!'),
            content: const Text(
              'El usuario y la contraseña no pueden estar vacíos',
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Entiendo'),
              ),
            ],
          );
        },
      );
      return;
    }

    if (!userController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          action: SnackBarAction(label: 'Cerrar', onPressed: () {}),
          content: const Text('El correo no es válido'),
        ),
      );
      return;
    }

    GetStorage().write('isLoggedIn', true);
    GetStorage().write('user', userController.text);

    context.goNamed('home', pathParameters: {'user': userController.text});
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
                    style: const TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 0.8),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Correo',
                      labelStyle: const TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.8),
                      ),
                      hintText: 'Ingrese su correo',
                      hintStyle: const TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.6),
                      ),
                      filled: false,
                      enabledBorder: enabledBorderStyle,
                      focusedBorder: focusedBorderStyle,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Color.fromRGBO(255, 255, 255, 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Obx(
                    () => TextField(
                      controller: controller.passwordController,
                      obscureText: controller.obscurePassword.value,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.8),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: const TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 0.8),
                        ),
                        hintText: 'Ingrese su contraseña',
                        hintStyle: const TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 0.6),
                        ),
                        filled: false,
                        enabledBorder: enabledBorderStyle,
                        focusedBorder: focusedBorderStyle,
                        prefixIcon: const Icon(
                          Icons.password_rounded,
                          color: Color.fromRGBO(255, 255, 255, 0.8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscurePassword.value
                                ? Icons.remove_red_eye
                                : Icons.visibility_off,
                            color: const Color.fromRGBO(255, 255, 255, 0.8),
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 280,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          198,
                          244,
                          32,
                        ),
                        foregroundColor: const Color.fromARGB(255, 31, 30, 30),
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () => controller.login(context),
                      child: const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              offset: Offset(1.5, 2),
                              blurRadius: 5.0,
                              color: Color.fromARGB(98, 63, 63, 63),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => context.goNamed('register'),
                    child: const Text(
                      '¿No tienes cuenta? Regístrate',
                      style: TextStyle(color: Colors.white),
                    ),
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
