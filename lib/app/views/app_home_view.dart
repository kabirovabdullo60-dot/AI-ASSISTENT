import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/app_home_view_model.dart';

class AppHomeView extends StatelessWidget {
  const AppHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppHomeViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('AI Business Assistant')),
      body: Center(
        child: vm.isLoading
            ? const CircularProgressIndicator()
            : Text(vm.error ?? 'App home'),
      ),
    );
  }
}
