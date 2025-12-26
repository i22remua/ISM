// lib/screens/owner/create_event_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/local_api_service.dart';
import '../../models/event_model.dart'; // Importa el modelo de evento
import '../../../widgets/custom_text_field.dart';

class CreateEventScreen extends StatefulWidget {
  final Event? existingEvent; // Evento opcional para el modo de edición

  const CreateEventScreen({Key? key, this.existingEvent}) : super(key: key);

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final LocalApiService _apiService = LocalApiService();
  DateTime? _selectedDateTime;
  bool _isLoading = false;

  bool get _isEditing => widget.existingEvent != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      // Si estamos editando, rellenamos los campos con los datos del evento
      _nameController.text = widget.existingEvent!.nombre;
      _descriptionController.text = widget.existingEvent!.descripcion;
      _selectedDateTime = widget.existingEvent!.fechaHora;
    } else {
      // Si estamos creando, inicializamos la fecha y hora
      _selectedDateTime = DateTime.now();
    }
  }

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2020), // Permite fechas pasadas por si se edita
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year, pickedDate.month, pickedDate.day,
            pickedTime.hour, pickedTime.minute,
          );
        });
      }
    }
  }

  void _handleSubmit() async {
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una fecha y hora.')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // FIX: Formatear la fecha como un string local para evitar la conversión a UTC.
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      final String formattedDateTime = formatter.format(_selectedDateTime!);

      final eventData = {
        'nombre': _nameController.text,
        'descripcion': _descriptionController.text,
        'fecha_hora': formattedDateTime,
        'id_local': _isEditing ? widget.existingEvent!.idLocal : (await _apiService.fetchLocales()).first.idLocal,
      };

      if (_isEditing) {
        await _apiService.modifyEvent(widget.existingEvent!.idEvento, eventData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento modificado con éxito!')),
        );
      } else {
        await _apiService.createEvent(eventData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento creado con éxito!')),
        );
      }
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modificar Evento' : 'Crear Nuevo Evento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CustomTextField(
              controller: _nameController,
              labelText: 'Nombre del Evento',
              icon: Icons.title,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              labelText: 'Descripción del Evento',
              icon: Icons.description,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Fecha y Hora del Evento'),
              subtitle: Text(
                _selectedDateTime == null
                    ? 'No seleccionada'
                    : DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateTime!),
              ),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              child: Text(_isEditing ? 'Guardar Cambios' : 'Crear Evento'),
            ),
          ],
        ),
      ),
    );
  }
}
