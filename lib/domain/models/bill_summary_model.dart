import 'package:trueledger/core/utils/date_helper.dart';

class BillSummary {
  final String id;
  final String name;
  final int amount;
  final DateTime? dueDate;
  final String type;

  BillSummary({
    required this.id,
    required this.name,
    required this.amount,
    this.dueDate,
    required this.type,
  });

  factory BillSummary.fromMap(Map<String, dynamic> map) {
    return BillSummary(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? map['title'] ?? 'Bill').toString(),
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      dueDate: DateHelper.parseDue(map['due']?.toString() ?? ''),
      type: map['type']?.toString() ?? 'BILL',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'due': dueDate?.toIso8601String(),
        'type': type,
      };
}
