import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/home_view_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
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
