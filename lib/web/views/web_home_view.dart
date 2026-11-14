import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/web_home_view_model.dart';

class WebHomeView extends StatelessWidget {
  const WebHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WebHomeViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('AI Business Assistant — Web')),
      body: Center(
        child: vm.isLoading
            ? const CircularProgressIndicator()
            : Text(vm.error ?? 'Web home'),
      ),
    );
  }
}
