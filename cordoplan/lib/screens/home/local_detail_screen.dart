// lib/screens/home/local_detail_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/local_model.dart';
import '../../services/local_api_service.dart';
import '../../models/event_model.dart';
import '../../widgets/real_time_aforo_display.dart';

// ✅ IMPORTACIONES NECESARIAS
import 'event_detail_screen.dart';
import '../chat/chat_screen.dart';
// FIX: Importar la pantalla de escaneo NFC
import '../owner/aforo_nfc_screen.dart'; 

class LocalDetailScreen extends StatefulWidget {
  final Local local;

  const LocalDetailScreen({Key? key, required this.local}) : super(key: key);

  @override
  State<LocalDetailScreen> createState() => _LocalDetailScreenState();
}

class _LocalDetailScreenState extends State<LocalDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LocalApiService _apiService = LocalApiService();

  late StreamController<int> _aforoStreamController;
  Timer? _aforoTimer;

  late final int _localId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _localId = widget.local.idLocal;

    _aforoStreamController = StreamController<int>.broadcast();
    if (_localId > 0) {
      _startAforoSimulation();
    }
  }

  void _startAforoSimulation() {
    _aforoTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final newAforo = widget.local.aforoActual + (timer.tick % 5) - 2;
      if (!_aforoStreamController.isClosed) {
        _aforoStreamController.add(newAforo.clamp(0, widget.local.aforoMaximo));
      }
    });
  }

  // FIX: Función para navegar a la pantalla de escaneo NFC
  void _navigateToNfcScan() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AforoNfcScreen(local: widget.local),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _aforoTimer?.cancel();
    _aforoStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_localId <= 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error de Datos')),
        body: const Center(
          child: Text('Error: ID de Local inválido. No se puede cargar el detalle.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.local.nombre),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Detalles', icon: Icon(Icons.info_outline)),
            Tab(text: 'Aforo', icon: Icon(Icons.people_alt)),
            Tab(text: 'Eventos', icon: Icon(Icons.calendar_month)),
            Tab(text: 'Foro', icon: Icon(Icons.chat_bubble_outline)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(),
          _buildAforoTab(),
          _buildEventsTab(),
          _buildChatTab(),
        ],
      ),
      // FIX: Añadido botón flotante para el escaneo NFC
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToNfcScan,
        icon: const Icon(Icons.nfc),
        label: const Text('Registrar Entrada/Salida'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildDetailsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(Icons.place, 'Tipo de Ocio', widget.local.tipoOcio),
          const SizedBox(height: 10),
          const Text('Descripción:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(widget.local.descripcion, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          _buildDetailRow(Icons.perm_identity, 'Capacidad Máxima', '${widget.local.aforoMaximo} personas'),
        ],
      ),
    );
  }

  Widget _buildAforoTab() {
    return StreamBuilder<int>(
      stream: _aforoStreamController.stream,
      initialData: widget.local.aforoActual,
      builder: (context, snapshot) {
        return Center(
          child: RealTimeAforoDisplay(
            currentAforo: snapshot.data ?? widget.local.aforoActual,
            maxAforo: widget.local.aforoMaximo,
          ),
        );
      },
    );
  }

  Widget _buildEventsTab() {
    return FutureBuilder<List<Event>>(
      future: _apiService.fetchLocalEvents(_localId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${snapshot.error.toString().replaceAll('Exception:', '').trim()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay eventos programados.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final event = snapshot.data![index];
            return Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.event, color: Colors.blueAccent),
                title: Text(event.nombre),
                subtitle: Text('Fecha: ${event.fechaHora.toLocal().toString().split(' ')[0]}'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChatTab() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ChatScreen(localId: widget.local.idLocal)),
          );
        },
        child: const Text('Acceder al Foro del Local'),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 10),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 5),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
