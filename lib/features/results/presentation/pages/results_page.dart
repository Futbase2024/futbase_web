import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/bloc/auth_bloc.dart';
import '../widgets/results_content.dart';

/// Página de Resultados - Vista de calendario semanal global
/// Esta página standalone usa el mismo ResultsContent que el Dashboard
class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Error: Usuario no encontrado')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: ResultsContent(user: user),
    );
  }
}
