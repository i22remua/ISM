// lib/models/user_model.dart

class User {
  final int idUsuario;
  final String nombre;
  final String email;
  final String rol; 
  final String firebaseUid;
  final String? nfcTagId; // ID de la pulsera NFC (puede ser nulo si no está asignado)

  User({
    required this.idUsuario,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.firebaseUid,
    this.nfcTagId,
  });

  // Método de fábrica para crear una instancia de User desde la respuesta JSON del Backend
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUsuario: json['id_usuario'] as int,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      rol: json['rol'] as String,
      firebaseUid: json['firebase_uid'] as String,
      nfcTagId: json['nfc_tag_id'] as String?, // Usamos String? porque puede ser null
    );
  }
}