import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gastos_personales/enums/movement_type.dart';
import 'package:gastos_personales/models/movement.dart';
import 'package:gastos_personales/views/cards.dart';
import 'package:gastos_personales/views/indicator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.user});

  final String user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final box = GetStorage();
  final pageController = PageController(initialPage: 0);
  int currentIndex = 0;

  List<Movement> items = [];
  String filterType = 'ALL'; // ALL | INCOME | EXPENSE

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = box.read('movements');
    if (raw == null) {
      setState(() => items = []);
      return;
    }
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      setState(() => items = list.map(Movement.fromJson).toList());
    } catch (_) {
      // si guardaste lista directa sin json, fallback:
      if (raw is List) {
        setState(
          () => items = raw
              .map((e) => Movement.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
        );
      }
    }
  }

  Future<void> _save() async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await box.write('movements', encoded);
  }

  double get totalIncome => items
      .where((e) => e.type == MovementType.income)
      .fold(0.0, (a, b) => a + b.amount);

  double get totalExpense => items
      .where((e) => e.type == MovementType.expense)
      .fold(0.0, (a, b) => a + b.amount);

  List<Movement> get filtered {
    switch (filterType) {
      case 'INCOME':
        return items.where((e) => e.type == MovementType.income).toList();
      case 'EXPENSE':
        return items.where((e) => e.type == MovementType.expense).toList();
      default:
        return items;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos personales'),
        actions: [
          IconButton(
            onPressed: () => setState(() {
              filterType = 'ALL';
            }),
            tooltip: 'Todos',
            icon: const Icon(Icons.filter_alt_off),
          ),
          IconButton(
            onPressed: () => setState(() {
              filterType = 'INCOME';
            }),
            tooltip: 'Ingresos',
            icon: const Icon(Icons.arrow_downward_rounded),
          ),
          IconButton(
            onPressed: () => setState(() {
              filterType = 'EXPENSE';
            }),
            tooltip: 'Egresos',
            icon: const Icon(Icons.arrow_upward_rounded),
          ),
          IconButton(
            onPressed: () => setState(() {
              //borra datos de sesion
              GetStorage().remove("user");
              GetStorage().remove("isLoggedIn");

              // ir a login
              context.goNamed('login');
            }),
            tooltip: 'Salir',
            icon: const Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),

      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => currentIndex = i),
        children: [_buildMovementsPage(context), _buildChartsPage(context)],
      ),

      floatingActionButton: currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _openAddMovementSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Agregar'),
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) {
          setState(() => currentIndex = i);
          pageController.animateToPage(
            i,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Movimientos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Gráficas',
          ),
        ],
      ),
    );
  }

  // ---------- Movimientos ----------
  Widget _buildMovementsPage(BuildContext context) {
    return Column(
      children: [
        CardPage(income: totalIncome, expense: totalExpense),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('Sin movimientos'))
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final m = filtered[i];
                    final sign = m.type == MovementType.income ? '+' : '-';
                    final color = m.type == MovementType.income
                        ? Colors.green
                        : Colors.red;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withOpacity(.12),
                        child: Icon(
                          m.type == MovementType.income
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: color,
                        ),
                      ),
                      title: Text(m.category),
                      subtitle: Text(
                        '${m.date.day}/${m.date.month}/${m.date.year}${m.note != null && m.note!.isNotEmpty ? ' · ${m.note}' : ''}',
                      ),
                      trailing: Text(
                        '$sign L. ${m.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onLongPress: () async {
                        final ok =
                            await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Eliminar'),
                                content: const Text(
                                  '¿Deseas eliminar este movimiento?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            ) ??
                            false;
                        if (ok) {
                          setState(
                            () => items.removeWhere((e) => e.id == m.id),
                          );
                          await _save();
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ---------- Gráficas ----------
  Widget _buildChartsPage(BuildContext context) {
    final income = totalIncome <= 0 ? 0.0001 : totalIncome;
    final expense = totalExpense <= 0 ? 0.0001 : totalExpense;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CardPage(income: totalIncome, expense: totalExpense),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1.3,
            child: Row(
              children: <Widget>[
                const SizedBox(height: 18),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('Sin movimientos'))
                      : PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                value: income,
                                showTitle: false,
                                radius: 90,
                                color: Colors.green,
                              ),
                              PieChartSectionData(
                                value: expense,
                                showTitle: false,
                                radius: 90,
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                ),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Indicator(
                      color: Colors.green,
                      text: 'Ingresos',
                      isSquare: false,
                    ),
                    SizedBox(height: 4),
                    Indicator(
                      color: Colors.red,
                      text: 'Egresos',
                      isSquare: false,
                    ),
                    SizedBox(height: 4),
                  ],
                ),
                const SizedBox(width: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Form ----------
  Future<void> _openAddMovementSheet(BuildContext context) async {
    final amountCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    DateTime date = DateTime.now();
    MovementType type = MovementType.expense;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
        ),
        child: StatefulBuilder(
          builder: (context, setS) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nuevo movimiento',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                // Tipo
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Egreso'),
                      selected: type == MovementType.expense,
                      onSelected: (_) =>
                          setS(() => type = MovementType.expense),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Ingreso'),
                      selected: type == MovementType.income,
                      onSelected: (_) => setS(() => type = MovementType.income),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Monto
                TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Monto',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Categoría
                TextField(
                  controller: categoryCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Categoría (p.ej. Comida, Transporte)',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Fecha
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: Text('${date.day}/${date.month}/${date.year}'),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            initialDate: date,
                          );
                          if (picked != null) setS(() => date = picked);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Nota
                TextField(
                  controller: noteCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Nota (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Guardar
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar'),
                    onPressed: () async {
                      final amount =
                          double.tryParse(amountCtrl.text.trim()) ?? 0;
                      final category = categoryCtrl.text.trim();

                      if (amount <= 0 || category.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Monto > 0 y categoría son obligatorios',
                            ),
                          ),
                        );
                        return;
                      }

                      final id = DateTime.now().millisecondsSinceEpoch
                          .toString();
                      final newItem = Movement(
                        id: id,
                        amount: amount,
                        category: category,
                        date: date,
                        type: type,
                        note: noteCtrl.text.trim(),
                      );

                      setState(() => items.insert(0, newItem));
                      await _save();
                      if (mounted) Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
