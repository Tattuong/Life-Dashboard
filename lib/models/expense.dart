class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final int colorIndex;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.colorIndex = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String(),
        'colorIndex': colorIndex,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        category: json['category'] as String? ?? 'Other',
        date: DateTime.parse(json['date'] as String),
        colorIndex: json['colorIndex'] as int? ?? 0,
      );
}

class ExpenseCategory {
  final String name;
  final int colorIndex;

  const ExpenseCategory(this.name, this.colorIndex);

  static const defaults = [
    ExpenseCategory('Food', 0),
    ExpenseCategory('Transport', 1),
    ExpenseCategory('Shopping', 2),
    ExpenseCategory('Entertainment', 3),
    ExpenseCategory('Bills', 4),
    ExpenseCategory('Health', 5),
    ExpenseCategory('Other', 7),
  ];
}
