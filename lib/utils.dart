import 'package:flutter/material.dart';

const Color kPrimaryColor = Colors.amber;

const List<String> kExpenseCategories = [
  'Makanan',
  'Transportasi',
  'Hiburan',
  'Belanja',
  'Transfer',
  'Lainnya',
];

const List<String> kIncomeCategories = [
  'Gaji',
  'Bonus',
  'Lainnya',
];

const List<String> _monthNames = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

// 5000000 -> "Rp 5.000.000"
String formatRupiah(int value) {
  final bool negative = value < 0;
  final String digits = value.abs().toString();
  final StringBuffer buffer = StringBuffer();

  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }

  return '${negative ? '-' : ''}Rp $buffer';
}

// DateTime -> "13 September 2026"
String formatDate(DateTime d) {
  return '${d.day} ${_monthNames[d.month - 1]} ${d.year}';
}

// DateTime -> "13/09/2026"
String formatDateShort(DateTime d) {
  return '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}

IconData categoryIcon(String category) {
  switch (category) {
    case 'Makanan':
      return Icons.fastfood;
    case 'Transportasi':
      return Icons.directions_car;
    case 'Hiburan':
      return Icons.movie;
    case 'Belanja':
      return Icons.shopping_bag;
    case 'Transfer':
      return Icons.swap_horiz;
    case 'Gaji':
      return Icons.attach_money;
    case 'Bonus':
      return Icons.account_balance_wallet;
    default:
      return Icons.category;
  }
}

Color categoryColor(String category) {
  switch (category) {
    case 'Makanan':
      return Colors.redAccent;
    case 'Transportasi':
      return Colors.blueAccent;
    case 'Hiburan':
      return Colors.purple;
    case 'Belanja':
      return Colors.orange;
    case 'Transfer':
      return Colors.indigo;
    case 'Gaji':
      return Colors.green;
    case 'Bonus':
      return Colors.teal;
    default:
      return Colors.blueGrey;
  }
}
