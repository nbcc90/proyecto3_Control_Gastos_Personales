import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:control_gastos/controllers/movements_controller.dart';
import 'package:control_gastos/controllers/user_controller.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  final String user;
  HomePage({super.key, required this.user});

  final MovementsController movementsController = Get.put(
    MovementsController(),
  );
  final UserController userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    // Asignar el usuario si no está ya en el controlador
    if (!userController.isLoggedIn) {
      userController.setUser(user);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Gastos", style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // Filtrar por fecha en el futuro
            },
          ),
        ],
      ),

      // Drawer con el perfil y opción de cerrar sesión
      drawer: Drawer(
        child: Column(
          children: [
            Obx(
              () => UserAccountsDrawerHeader(
                accountName: Text(userController.username.value),
                accountEmail: const Text("usuario@email.com"),
                currentAccountPicture: const CircleAvatar(
                  backgroundImage: AssetImage('assets/profile.jpg'),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Inicio"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text("Gráficos"),
              onTap: () {
                // Navegar a gráficos
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Cerrar sesión"),
              onTap: () {
                userController.logout(); // limpiar datos del usuario
                context.go('/login'); // redirigir al login
              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          _buildSummary(),
          const Divider(),
          Expanded(child: _buildMovementsList()),
        ],
      ),

      // Menú inferior de navegación
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            context.pushNamed('add');
          } else if (index == 2) {
            // Ir a gráficos
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Agregar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Gráficos',
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _summaryCard(
              "Gastos",
              movementsController.totalExpenses,
              Colors.red,
            ),
            _summaryCard(
              "Ingresos",
              movementsController.totalIncome,
              Colors.green,
            ),
            _summaryCard("Saldo", movementsController.balance, Colors.blue),
          ],
        ),
      );
    });
  }

  Widget _summaryCard(String title, double amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        Text(
          amount.toStringAsFixed(2),
          style: TextStyle(fontSize: 16, color: color),
        ),
      ],
    );
  }

  Widget _buildMovementsList() {
    return Obx(() {
      if (movementsController.movements.isEmpty) {
        return const Center(child: Text("No hay movimientos registrados"));
      }
      return ListView.builder(
        itemCount: movementsController.movements.length,
        itemBuilder: (context, index) {
          final mov = movementsController.movements[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: mov.isIncome ? Colors.green : Colors.red,
              child: Icon(
                IconData(mov.icon, fontFamily: 'MaterialIcons'),
                color: Colors.white,
              ),
            ),
            title: Text(
              mov.note?.isNotEmpty == true ? mov.note! : mov.category,
            ),
            subtitle: Text(
              "${mov.date.day}/${mov.date.month}/${mov.date.year}",
            ),
            trailing: Text(
              "${mov.isIncome ? '+' : '-'}${mov.amount}",
              style: TextStyle(
                color: mov.isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      );
    });
  }
}
