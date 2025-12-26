// lib/models/user_data_model.dart

class UserData {
  final int idUsuario;
  final String firebaseUid;
  final String email;
  final String nombre;
  final String rol;

  UserData({
    required this.idUsuario,
    required this.firebaseUid,
    required this.email,
    required this.nombre,
    required this.rol,
  });

  // Un constructor "vacío" o inicial para cuando no hay usuario
  factory UserData.initial() {
    return UserData(
      idUsuario: 0,
      firebaseUid: '',
      email: '',
      nombre: '',
      rol: 'invitado',
    );
  }

  // FIX: Añadido el constructor `fromJson` que faltaba
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      idUsuario: json['id_usuario'] ?? 0,
      firebaseUid: json['firebase_uid'] ?? '',
      email: json['email'] ?? '',
      nombre: json['nombre'] ?? 'Usuario Desconocido',
      rol: json['rol'] ?? 'invitado',
    );
  }
}
