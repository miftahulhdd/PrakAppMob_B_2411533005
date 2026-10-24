import 'package:flutter/material.dart';
import 'transaction_detail_screen.dart';

// Model data transaksi (statis)
class TransactionItem {
  final String title;
  final int amount;
  final bool isIncome;
  final String category;
  final String date;
  final IconData icon;
  final Color color;

  const TransactionItem({
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.date,
    required this.icon,
    required this.color,
  });

  String get amountText => '${isIncome ? '+' : '-'} ${formatRupiah(amount)}';
}

// Mengubah angka 5000000 menjadi "Rp 5.000.000"
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

// Data statis, diurutkan dari yang terbaru
const List<TransactionItem> dummyTransactions = [
  TransactionItem(
    title: 'Nonton Bioskop',
    amount: 75000,
    isIncome: false,
    category: 'Hiburan',
    date: '20 September 2026',
    icon: Icons.movie,
    color: Colors.purple,
  ),
  TransactionItem(
    title: 'Bonus Proyek',
    amount: 750000,
    isIncome: true,
    category: 'Pemasukan',
    date: '19 September 2026',
    icon: Icons.account_balance_wallet,
    color: Colors.teal,
  ),
  TransactionItem(
    title: 'Belanja Bulanan',
    amount: 300000,
    isIncome: false,
    category: 'Belanja',
    date: '18 September 2026',
    icon: Icons.shopping_bag,
    color: Colors.orange,
  ),
  TransactionItem(
    title: 'Isi Bensin',
    amount: 150000,
    isIncome: false,
    category: 'Transportasi',
    date: '16 September 2026',
    icon: Icons.directions_car,
    color: Colors.blueAccent,
  ),
  TransactionItem(
    title: 'Makan Siang',
    amount: 50000,
    isIncome: false,
    category: 'Makanan',
    date: '13 September 2026',
    icon: Icons.fastfood,
    color: Colors.redAccent,
  ),
  TransactionItem(
    title: 'Gaji Bulanan',
    amount: 5000000,
    isIncome: true,
    category: 'Pemasukan',
    date: '1 September 2026',
    icon: Icons.attach_money,
    color: Colors.green,
  ),
];

// Widget satu baris transaksi, jika di-tap membuka halaman detail
class TransactionTile extends StatelessWidget {
  final TransactionItem item;

  const TransactionTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: item.color,
        child: Icon(item.icon, color: Colors.white),
      ),
      title: Text(item.title),
      subtitle: Text(item.date),
      trailing: Text(
        item.amountText,
        style: TextStyle(
          color: item.isIncome ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        // NAVIGASI PUSH DENGAN DATA (Passing Data)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailScreen(
              title: item.title,
              amount: item.amountText,
              category: item.category,
              date: item.date,
            ),
          ),
        );
      },
    );
  }
}