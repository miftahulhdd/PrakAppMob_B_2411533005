import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prak1smpe5/main.dart';

void main() {
  testWidgets('Aplikasi menampilkan halaman login', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Expense Tracker'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Tombol Daftar membuka halaman registrasi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Form Registrasi Pengguna'), findsOneWidget);
    expect(find.text('Buat akun baru'), findsOneWidget);
  });
}
