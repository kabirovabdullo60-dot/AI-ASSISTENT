import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/app_home_view_model.dart';
import 'views/app_home_view.dart';

class MobileApp extends StatelessWidget {
  const MobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppHomeViewModel()),
      ],
      child: MaterialApp(
        title: 'AI Business Assistant',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        home: const AppHomeView(),
      ),
    );
  }
}
