import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/home_view_model.dart';
import 'views/home_view.dart';

void main() {
  runApp(const WebApp());
}

class WebApp extends StatelessWidget {
  const WebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
      ],
      child: MaterialApp(
        title: 'AI Business Assistant — Web',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: const HomeView(),
      ),
    );
  }
}
