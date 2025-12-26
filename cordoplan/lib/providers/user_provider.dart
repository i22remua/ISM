// lib/providers/user_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user_data_model.dart';

class UserProvider with ChangeNotifier {
  UserData? _userData;

  UserData? get userData => _userData;

  // Método para actualizar y notificar del nuevo usuario
  void setUser(Map<String, dynamic> apiResponse) {
    _userData = UserData(
      idUsuario: apiResponse['id_usuario'] ?? 0,
      firebaseUid: apiResponse['firebase_uid'] ?? '',
      email: apiResponse['email'] ?? '',
      nombre: apiResponse['nombre'] ?? '',
      rol: apiResponse['rol'] ?? 'invitado',
    );
    notifyListeners();
  }

  // Método para limpiar los datos al cerrar sesión
  void clearUser() {
    _userData = null;
    notifyListeners();
  }
}
