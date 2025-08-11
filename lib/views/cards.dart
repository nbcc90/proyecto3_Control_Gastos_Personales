import 'package:flutter/material.dart';

class CardPage extends StatelessWidget {
  final double income;
  final double expense;
  const CardPage({super.key, required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    final balance = income - expense;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _kpi('Ingresos', income),
            _kpi('Egresos', expense),
            _kpi('Balance', balance),
          ],
        ),
      ),
    );
  }

  Widget _kpi(String label, double value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text('L. ${value.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}