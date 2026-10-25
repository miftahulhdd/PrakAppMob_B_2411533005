import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'models.dart';
import 'transaction_tile.dart';
import 'utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  int _income = 0;
  int _expense = 0;
  List<TransactionModel> _recent = [];

  @override
  void initState() {
    super.initState();
    // Muat ulang otomatis saat ada transaksi ditambah / dihapus
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

    final Map<String, int> totals =
        await DatabaseHelper.instance.getTotals(user.id);
    final List<TransactionModel> recent =
        await DatabaseHelper.instance.getTransactions(user.id, limit: 5);

    if (!mounted) return;
    setState(() {
      _income = totals['income'] ?? 0;
      _expense = totals['expense'] ?? 0;
      _recent = recent;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String name = AppSession.user?.name ?? 'Pengguna';

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Keuangan')),

      // Tombol mengambang (FAB) untuk tambah transaksi
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/add');
        },
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GreetingWidget(name: name),
                  const SizedBox(height: 20),
                  BalanceCardWidget(income: _income, expense: _expense),
                  const SizedBox(height: 20),
                  const ActionButtonsWidget(),
                  const SizedBox(height: 20),
                  const Text(
                    'Transaksi Terakhir',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildTransactionList(),
                  const SizedBox(height: 80), // ruang agar tidak tertutup FAB
                ],
              ),
            ),
    );
  }

  Widget _buildTransactionList() {
    if (_recent.isEmpty) {
      return const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              'Belum ada transaksi.\nTekan tombol + untuk menambahkan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          for (int i = 0; i < _recent.length; i++) ...[
            TransactionTile(transaction: _recent[i]),
            if (i != _recent.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// STATELESS WIDGET: Sapaan pengguna (Praktikum 1)
// ---------------------------------------------------------------
class GreetingWidget extends StatelessWidget {
  final String name;

  const GreetingWidget({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.amber.shade800,
          child: const Icon(Icons.person, size: 30, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, $name',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const Text(
                'Selamat datang kembali!',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------
// STATEFUL WIDGET: Kartu saldo dengan tombol sensor (Praktikum 1)
// ---------------------------------------------------------------
class BalanceCardWidget extends StatefulWidget {
  final int income;
  final int expense;

  const BalanceCardWidget({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  State<BalanceCardWidget> createState() => _BalanceCardWidgetState();
}

class _BalanceCardWidgetState extends State<BalanceCardWidget> {
  bool _isBalanceVisible = true;

  void _toggleVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

  Widget _buildSummary(IconData icon, String label, int value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            Text(
              _isBalanceVisible ? formatRupiah(value) : 'Rp *****',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final int balance = widget.income - widget.expense;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.amber.shade800,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saldo Utama',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  IconButton(
                    icon: Icon(
                      _isBalanceVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: _toggleVisibility,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _isBalanceVisible ? formatRupiah(balance) : 'Rp *********',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummary(
                    Icons.arrow_downward,
                    'Pemasukan',
                    widget.income,
                  ),
                  _buildSummary(
                    Icons.arrow_upward,
                    'Pengeluaran',
                    widget.expense,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------
// WIDGET TOMBOL AKSI (Row) - Praktikum 2
// ---------------------------------------------------------------
class ActionButtonsWidget extends StatelessWidget {
  const ActionButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          Icons.arrow_downward,
          'Pemasukan',
          Colors.green,
          {'type': 'income'},
        ),
        _buildActionButton(
          context,
          Icons.arrow_upward,
          'Pengeluaran',
          Colors.red,
          {'type': 'expense'},
        ),
        _buildActionButton(
          context,
          Icons.swap_horiz,
          'Transfer',
          Colors.blue,
          {'type': 'expense', 'category': 'Transfer'},
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    Map<String, String> arguments,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // Membuka form tambah transaksi dengan jenis yang sudah terpilih
        Navigator.pushNamed(context, '/add', arguments: arguments);
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(51), // warna transparan
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
