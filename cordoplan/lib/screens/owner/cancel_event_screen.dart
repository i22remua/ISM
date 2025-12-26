// lib/screens/owner/cancel_event_screen.dart
import 'package:flutter/material.dart';
import '../../services/local_api_service.dart';
import '../../models/event_model.dart';
import '../../models/local_model.dart';
import 'create_event_screen.dart'; // Importa la pantalla de edición

class CancelEventScreen extends StatefulWidget {
  @override
  _CancelEventScreenState createState() => _CancelEventScreenState();
}

class _CancelEventScreenState extends State<CancelEventScreen> {
  final LocalApiService _apiService = LocalApiService();
  Future<List<Event>>? _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _fetchOwnerEvents();
  }

  Future<List<Event>> _fetchOwnerEvents() async {
    final List<Local> allLocales = await _apiService.fetchLocales();
    if (allLocales.isEmpty) {
      throw Exception("No se encontró un local para cargar eventos.");
    }
    return await _apiService.fetchLocalEvents(allLocales.first.idLocal);
  }

  void _handleCancelEvent(int eventId) async {
    try {
      await _apiService.cancelEvent(eventId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento cancelado con éxito.')),
      );
      setState(() {
        _eventsFuture = _fetchOwnerEvents();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cancelar el evento: ${e.toString()}')),
      );
    }
  }

  // Navega a la pantalla de edición
  void _navigateToEditEvent(Event event) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateEventScreen(existingEvent: event),
      ),
    );
    // Cuando volvemos de la pantalla de edición, refrescamos la lista
    setState(() {
      _eventsFuture = _fetchOwnerEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestionar Eventos'), // Título actualizado
      ),
      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay eventos para mostrar.'));
          }

          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                title: Text(event.nombre),
                subtitle: Text(event.descripcion),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () => _navigateToEditEvent(event),
                      tooltip: 'Modificar Evento',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      onPressed: () => _handleCancelEvent(event.idEvento),
                      tooltip: 'Cancelar Evento',
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
