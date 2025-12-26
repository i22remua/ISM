// lib/models/local_model.dart

class Local {
  final int idLocal;
  final int idPropietario;
  final String nombre;
  final String descripcion;
  final String tipoOcio;
  final double latitud;
  final double longitud;
  final int aforoMaximo;
  final int aforoActual;
  final bool activo;

  // Constructor base (sin cambios)
  Local({
    required this.idLocal,
    required this.idPropietario,
    required this.nombre,
    required this.descripcion,
    required this.tipoOcio,
    required this.latitud,
    required this.longitud,
    required this.aforoMaximo,
    required this.aforoActual,
    required this.activo,
  });

  factory Local.fromJson(Map<String, dynamic> json) {

    // Función de utilidad robusta para convertir a double
    double _safeToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Función de utilidad robusta para convertir a int
    int _safeToInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    return Local(
      // FIX: Se aceptan múltiples claves para mayor robustez.
      idLocal: _safeToInt(json['id_local'] ?? json['id'] ?? json['idLocal']),
      idPropietario: _safeToInt(json['id_propietario'] ?? json['id_usuario'] ?? json['idPropietario']),

      nombre: (json['nombre'] as String?) ?? 'Nombre no disponible',
      descripcion: (json['descripcion'] as String?) ?? 'Sin descripción',
      // FIX: Se aceptan 'tipo_ocio' y 'tipoOcio'.
      tipoOcio: (json['tipo_ocio'] as String?) ?? (json['tipoOcio'] as String?) ?? 'No especificado',

      latitud: _safeToDouble(json['latitud']),
      longitud: _safeToDouble(json['longitud']),
      // FIX: Se aceptan 'aforo_maximo' y 'aforoMaximo'.
      aforoMaximo: _safeToInt(json['aforo_maximo'] ?? json['aforoMaximo']),
      // FIX: Se aceptan 'aforo_actual' y 'aforoActual'.
      aforoActual: _safeToInt(json['aforo_actual'] ?? json['aforoActual']),

      activo: json['activo'] == true || json['activo'] == 1,
    );
  }
}
