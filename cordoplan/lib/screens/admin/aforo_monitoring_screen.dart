// lib/screens/admin/aforo_monitoring_screen.dart
import 'package:flutter/material.dart';
import '../../models/local_model.dart';
import '../../services/local_api_service.dart';

class AforoMonitoringScreen extends StatefulWidget {
  const AforoMonitoringScreen({Key? key}) : super(key: key);

  @override
  _AforoMonitoringScreenState createState() => _AforoMonitoringScreenState();
}

class _AforoMonitoringScreenState extends State<AforoMonitoringScreen> {
  final LocalApiService _apiService = LocalApiService();
  late Future<List<Local>> _localesFuture;

  @override
  void initState() {
    super.initState();
    _localesFuture = _apiService.fetchLocales();
  }

  void _refreshLocales() {
    setState(() {
      _localesFuture = _apiService.fetchLocales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoreo de Aforo Global'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLocales,
            tooltip: 'Refrescar Datos',
          ),
        ],
      ),
      body: FutureBuilder<List<Local>>(
        future: _localesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar los locales: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay locales registrados.'));
          }

          final locales = snapshot.data!;

          return ListView.builder(
            itemCount: locales.length,
            itemBuilder: (context, index) {
              final local = locales[index];
              final double occupancy = local.aforoMaximo > 0
                  ? local.aforoActual / local.aforoMaximo
                  : 0.0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        local.nombre,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Aforo: ${local.aforoActual} / ${local.aforoMaximo}'),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: occupancy,
                        backgroundColor: Colors.grey[300],
                        color: occupancy > 0.8 ? Colors.red : Colors.green,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
