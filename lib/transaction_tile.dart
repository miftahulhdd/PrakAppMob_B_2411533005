import 'package:flutter/material.dart';

import 'models.dart';
import 'transaction_detail_screen.dart';
import 'utils.dart';

// Satu baris transaksi (dipakai di Beranda dan Riwayat)
class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction.isIncome;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: categoryColor(transaction.category),
        child: Icon(categoryIcon(transaction.category), color: Colors.white),
      ),
      title: Text(transaction.title),
      subtitle: Text(formatDate(transaction.date)),
      trailing: Text(
        '${isIncome ? '+' : '-'} ${formatRupiah(transaction.amount)}',
        style: TextStyle(
          color: isIncome ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        // NAVIGASI PUSH DENGAN DATA (Passing Data)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TransactionDetailScreen(transaction: transaction),
          ),
        );
      },
    );
  }
}
