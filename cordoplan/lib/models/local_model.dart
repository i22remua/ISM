

class Local {
  final int idLocal;
  final int idPropietario;
  final String nombre;
  final String descripcion;
  final String tipoOcio;
  final String ubicacion; // Nuevo campo
  final double latitud;
  final double longitud;
  final int aforoMaximo;
  final int aforoActual;
  final bool activo;

  Local({
    required this.idLocal,
    required this.idPropietario,
    required this.nombre,
    required this.descripcion,
    required this.tipoOcio,
    required this.ubicacion, // Añadido al constructor
    required this.latitud,
    required this.longitud,
    required this.aforoMaximo,
    required this.aforoActual,
    required this.activo,
  });

  factory Local.fromJson(Map<String, dynamic> json) {
    double _safeToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int _safeToInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    return Local(
      idLocal: _safeToInt(json['id_local'] ?? json['id'] ?? json['idLocal']),
      idPropietario: _safeToInt(json['id_propietario'] ?? json['id_usuario'] ?? json['idPropietario']),
      nombre: (json['nombre'] as String?) ?? 'Nombre no disponible',
      descripcion: (json['descripcion'] as String?) ?? 'Sin descripción',
      tipoOcio: (json['tipo_ocio'] as String?) ?? (json['tipoOcio'] as String?) ?? 'No especificado',
      ubicacion: (json['ubicacion'] as String?) ?? '', // Nuevo campo
      latitud: _safeToDouble(json['latitud']),
      longitud: _safeToDouble(json['longitud']),
      aforoMaximo: _safeToInt(json['aforo_maximo'] ?? json['aforoMaximo']),
      aforoActual: _safeToInt(json['aforo_actual'] ?? json['aforoActual']),
      activo: json['activo'] == true || json['activo'] == 1,
    );
  }
}
