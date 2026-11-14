import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/web_home_view_model.dart';
import 'views/web_home_view.dart';

class WebApp extends StatelessWidget {
  const WebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WebHomeViewModel()),
      ],
      child: MaterialApp(
        title: 'AI Business Assistant — Web',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: const WebHomeView(),
      ),
    );
  }
}
