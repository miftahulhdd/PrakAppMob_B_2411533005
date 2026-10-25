import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'models.dart';
import 'transaction_tile.dart';
import 'utils.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = true;
  String _filter = 'all'; // all | income | expense
  List<TransactionModel> _all = [];

  @override
  void initState() {
    super.initState();
    DatabaseHelper.instance.dataVersion.addListener(_loadData);
    _loadData();
  }

  @override
  void dispose() {
    DatabaseHelper.instance.dataVersion.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    final UserModel? user = AppSession.user;
    if (user == null) return;

    final List<TransactionModel> data =
        await DatabaseHelper.instance.getTransactions(user.id);

    if (!mounted) return;
    setState(() {
      _all = data;
      _isLoading = false;
    });
  }

  List<TransactionModel> get _filtered {
    if (_filter == 'income') {
      return _all.where((t) => t.isIncome).toList();
    }
    if (_filter == 'expense') {
      return _all.where((t) => !t.isIncome).toList();
    }
    return _all;
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
    final List<TransactionModel> list = _filtered;
    final int total = list.fold<int>(
      0,
      (sum, t) => sum + (t.isIncome ? t.amount : -t.amount),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                Expanded(
                  child: list.isEmpty
                      ? const Center(child: Text('Belum ada transaksi'))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 2,
                              child: TransactionTile(transaction: list[index]),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
