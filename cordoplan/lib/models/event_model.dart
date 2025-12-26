// lib/models/event_model.dart

class Event {
  final int idEvento;
  final int idLocal;
  final String nombre;
  final String descripcion;
  final DateTime fechaHora;
  final int creadoPor;

  Event({
    required this.idEvento,
    required this.idLocal,
    required this.nombre,
    required this.descripcion,
    required this.fechaHora,
    required this.creadoPor,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic value) {
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is num) return value.toInt();
      return 0;
    }

    DateTime _toDateTime(dynamic value) {
      if (value is String) {
        // La API envía un texto como '2025-12-09 16:32:58'. 
        // Esto representa la hora local que el usuario eligió.
        // Simplemente reemplazamos el espacio por una 'T' para que sea un formato válido.
        // Como no hay información de zona horaria, Dart lo interpretará correctamente como una hora LOCAL.
        final formattedString = value.replaceFirst(' ', 'T');
        return DateTime.tryParse(formattedString) ?? DateTime.now();
      }
      // Si el valor no es un string, devuelve la hora actual como fallback.
      return DateTime.now();
    }

    return Event(
      idEvento: _toInt(json['id_evento'] ?? json['idEvento']),
      idLocal: _toInt(json['id_local'] ?? json['idLocal']),
      nombre: json['nombre'] as String? ?? 'Sin nombre',
      descripcion: json['descripcion'] as String? ?? 'Sin descripción',
      // Se aceptan 'fecha_hora' y 'fechaHora' y se parsea correctamente como hora local.
      fechaHora: _toDateTime(json['fecha_hora'] ?? json['fechaHora']),
      creadoPor: _toInt(json['creado_por'] ?? json['creadoPor']),
    );
  }
}
