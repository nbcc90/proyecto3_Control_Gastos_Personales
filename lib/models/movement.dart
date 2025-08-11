import 'package:gastos_personales/enums/movement_type.dart';

class Movement {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final MovementType type;
  final String? note;

  Movement({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'category': category,
    'date': date.toIso8601String(),
    'type': type.name,
    'note': note,
  };

  factory Movement.fromJson(Map<String, dynamic> json) => Movement(
    id: json['id'] as String,
    amount: (json['amount'] as num).toDouble(),
    category: json['category'] as String,
    date: DateTime.parse(json['date'] as String),
    type: (json['type'] as String) == 'income'
        ? MovementType.income
        : MovementType.expense,
    note: json['note'] as String?,
  );
}