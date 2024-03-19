import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../isar_service.dart';
import '../pages/page_memo_home.dart';
import '../pages/page_file_home.dart';
import '../widgets/app_drawer.dart';

void main() {
  isarService.openDB();
  runApp(const ProviderScope(child: MyApp()),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PageMemoHome(),
      routes: {
        DrawerIndex.page0.route: (context) => const PageMemoHome(),
        DrawerIndex.page1.route: (context) => const PageFileHome(),
      },
    );
  }
}