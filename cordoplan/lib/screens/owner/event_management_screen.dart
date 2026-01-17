// lib/screens/owner/event_management_screen.dart
import 'package:flutter/material.dart';
import '../../services/local_api_service.dart';
import '../../models/event_model.dart';
import '../../models/local_model.dart';
import 'aforo_nfc_screen.dart'; // Importar la nueva pantalla

class EventManagementScreen extends StatefulWidget {
  final Local local; 
  // Opcional: Podrías necesitar el id del usuario para validación (RNF-06)

  const EventManagementScreen({Key? key, required this.local}) : super(key: key);

  @override
  _EventManagementScreenState createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  final LocalApiService _apiService = LocalApiService();
  late Future<List<Event>> _eventsFuture;
  
  // Controladores para la creación de un nuevo evento
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _fetchEvents();
  }

  Future<List<Event>> _fetchEvents() async {
    // Obtener solo eventos futuros (la API se encarga de esto)
    return await _apiService.fetchLocalEvents(widget.local.idLocal); 
  }

  Future<void> _createEvent() async {
    if (_nameController.text.isEmpty || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan detalles del evento.')));
      return;
    }

    final DateTime finalDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Asumimos que el ID del creador se obtiene del usuario autenticado
    // int creatorId = 1; 
    
    final Map<String, dynamic> eventData = {
      'id_local': widget.local.idLocal,
      'nombre': _nameController.text,
      'descripcion': _descriptionController.text,
      'fecha_hora': finalDateTime.toIso8601String(),
      // 'creado_por': creatorId, 
    };

    try {
      // RF-P05 / CU11: Crear evento
      await _apiService.createEvent(eventData);
      
      setState(() {
        _eventsFuture = _fetchEvents(); // Recargar la lista
      });
      Navigator.of(context).pop(); // Cerrar el formulario
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evento creado con éxito!')));
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al crear evento: ${e.toString()}')));
    }
  }
  
  Future<void> _cancelEvent(int idEvento) async {
    try {
      // RF-P05 / CU12: Cancelar evento
      // La API debe verificar si el usuario es Admin o el Propietario de este local (RNF-06)
       await _apiService.cancelEvent(idEvento);

      setState(() {
        _eventsFuture = _fetchEvents(); // Recargar la lista
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evento cancelado.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cancelar evento: ${e.toString()}')));
    }
  }

  // Navegar a la pantalla de NFC
  void _navigateToNfcScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AforoNfcScreen(local: widget.local),
      ),
    );
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventos de ${widget.local.nombre}'),
        centerTitle: true,
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
            return const Center(child: Text('No hay eventos próximos.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final event = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(event.nombre),
                  subtitle: Text('Fecha: ${event.fechaHora.toLocal().toString().split(' ')[0]}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _showCancelDialog(event.idEvento),
                    tooltip: 'Cancelar Evento (CU12)',
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'aforo_nfc', // Tag único para el Hero
            onPressed: _navigateToNfcScreen,
            icon: const Icon(Icons.nfc),
            label: const Text('Control de Aforo'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'crear_evento', // Tag único
            onPressed: () => _showCreateEventDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Crear Evento'),
          ),
        ],
      ),
    );
  }
  
  void _showCancelDialog(int idEvento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Cancelación'),
        content: const Text('¿Estás seguro de que deseas cancelar este evento?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('No')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelEvent(idEvento);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, Cancelar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateEventDialog(BuildContext context) {
    _selectedDate = null;
    _selectedTime = null;
    _nameController.clear();
    _descriptionController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20, left: 20, right: 20
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Nuevo Evento para ${widget.local.nombre}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Título del Evento')),
                TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Descripción')),
                const SizedBox(height: 20),
                
                // Selectores de Fecha y Hora
                ListTile(
                  title: Text(_selectedDate == null ? 'Seleccionar Fecha' : _selectedDate!.toString().split(' ')[0]),
                  trailing: const Icon(Icons.date_range),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                ),
                ListTile(
                  title: Text(_selectedTime == null ? 'Seleccionar Hora' : _selectedTime!.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) setState(() => _selectedTime = picked);
                  },
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    // La lógica de creación se maneja en _createEvent()
                    _createEvent(); 
                  },
                  child: const Text('Confirmar Creación'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
