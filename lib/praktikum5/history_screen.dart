import 'package:flutter/material.dart';
import 'transaction_data.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'all'; // all | income | expense

  List<TransactionItem> get _filtered {
    if (_filter == 'income') {
      return dummyTransactions.where((t) => t.isIncome).toList();
    }
    if (_filter == 'expense') {
      return dummyTransactions.where((t) => !t.isIncome).toList();
    }
    return dummyTransactions.toList();
  }

  Widget _buildFilterChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      selectedColor: Colors.amber,
      onSelected: (_) {
        setState(() {
          _filter = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<TransactionItem> list = _filtered;
    final int total = list.fold<int>(
      0,
      (sum, t) => sum + (t.isIncome ? t.amount : -t.amount),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                _buildFilterChip('Semua', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Pemasukan', 'income'),
                const SizedBox(width: 8),
                _buildFilterChip('Pengeluaran', 'expense'),
              ],
            ),
          ),

          // Ringkasan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${list.length} transaksi'),
                Text(
                  'Total: ${formatRupiah(total)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Daftar transaksi
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('Belum ada transaksi'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2,
                        child: TransactionTile(item: list[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}