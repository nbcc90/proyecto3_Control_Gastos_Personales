import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:gastos_personales/models/user_store.dart';
class RegistroPage extends StatelessWidget {
  RegistroPage({super.key});

  final nombreController = TextEditingController();
  final userController = TextEditingController();
  final telefonoController = TextEditingController();
  final passwordController = TextEditingController();

  final enabledBorderStyle = const UnderlineInputBorder(
    borderSide: BorderSide(color: Color.fromRGBO(255, 255, 255, 0.4), width: 1),
  );
  final focusedBorderStyle = const UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2),
  );

  void _mostrarError(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.redAccent),
    );
  }

  bool _validarDatos(BuildContext context) {
    final nombre = nombreController.text.trim();
    final correo = userController.text.trim();
    final telefono = telefonoController.text.trim();
    final contrasena = passwordController.text.trim();

    if (nombre.isEmpty ||
        correo.isEmpty ||
        telefono.isEmpty ||
        contrasena.isEmpty) {
      _mostrarError(context, 'Todos los campos son obligatorios');
      return false;
    }

    if (!correo.contains('@')) {
      _mostrarError(context, 'El correo debe contener "@"');
      return false;
    }

    if (contrasena.length < 6) {
      _mostrarError(context, 'La contraseña debe tener al menos 6 caracteres');
      return false;
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(contrasena)) {
      _mostrarError(
        context,
        'La contraseña debe contener al menos un carácter especial',
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Ajusta al aparecer el teclado
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Color.fromARGB(255, 181, 42, 205)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => context.pop(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Registro',
                        style: TextStyle(fontSize: 28, color: Colors.white),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: nombreController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                          labelStyle: const TextStyle(color: Colors.white),
                          enabledBorder: enabledBorderStyle,
                          focusedBorder: focusedBorderStyle,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: userController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Correo',
                          labelStyle: const TextStyle(color: Colors.white),
                          enabledBorder: enabledBorderStyle,
                          focusedBorder: focusedBorderStyle,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: telefonoController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Teléfono',
                          labelStyle: const TextStyle(color: Colors.white),
                          enabledBorder: enabledBorderStyle,
                          focusedBorder: focusedBorderStyle,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          labelStyle: const TextStyle(color: Colors.white),
                          enabledBorder: enabledBorderStyle,
                          focusedBorder: focusedBorderStyle,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          minimumSize: const Size(200, 50),
                        ),
                        onPressed: () async {
                          if (_validarDatos(context)) {
                            final user = AppUser(
                              name: nombreController.text.trim(),
                              email: userController.text.trim(),
                              phone: telefonoController.text.trim(),
                              password: passwordController.text.trim(),
                            );

                            final error = await UserStore.register(user);
                            if (error != null) {
                              _mostrarError(context, error);
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Usuario registrado con éxito')),
                            );
                            context.pop(); // volver al login
                          }
                        },
                        child: const Text(
                          'Registrar',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
