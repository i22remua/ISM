// lib/screens/home/event_detail_screen.dart
import 'package:flutter/material.dart';
import '../../models/event_model.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.nombre),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Descripción del Evento',
              style: Theme.of(context).textTheme.headlineSmall, // Corregido: headline6 -> headlineSmall
            ),
            const SizedBox(height: 8),
            Text(event.descripcion),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text('Fecha: ${event.fechaHora.toLocal().toString().split(' ')[0]}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Icon(Icons.access_time, size: 20),
                const SizedBox(width: 8),
                Text('Hora: ${event.fechaHora.toLocal().toString().split(' ')[1].substring(0, 5)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
