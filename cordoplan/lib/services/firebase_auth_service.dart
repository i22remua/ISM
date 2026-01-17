// lib/services/firebase_auth_service.dart
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'endpoints.dart'; // FIX: Importar la configuración centralizada de endpoints

// FIX: Se elimina la URL hardcodeada para usar la configuración centralizada
// const String _apiUrl = 'http://10.0.2.2:3000/api/users';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Decodifica la respuesta de la API, manejando tanto objetos como listas de un solo objeto.
  Map<String, dynamic> _decodeApiResponse(String responseBody) {
    final decoded = jsonDecode(responseBody);
    if (decoded is List) {
      if (decoded.isNotEmpty) {
        // Si es una lista, devuelve el primer objeto.
        return decoded.first as Map<String, dynamic>;
      }
      throw Exception('La respuesta del servidor es una lista vacía.');
    }
    if (decoded is Map<String, dynamic>) {
      // Si ya es un mapa, lo devuelve directamente.
      return decoded;
    }
    throw Exception('Formato de respuesta inesperado del servidor.');
  }

  // RF-U01 / CU1: Registro y Sincronización con MySQL
  Future<Map<String, dynamic>> registerAndSync(String email, String password, String name, String role) async {
    try {
      // 1. Registro en Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Sincronización con el Backend (MySQL)
      String firebaseUid = userCredential.user!.uid;

      final response = await http.post(
        // FIX: Usar la variable del endpoint centralizado
        Uri.parse(endpointUserSync),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firebase_uid': firebaseUid,
          'email': email,
          'nombre': name,
          'rol': role,
          'isNewUser': true,
        }),
      );

      if (response.statusCode == 201) {
        return _decodeApiResponse(response.body);
      } else {
        throw Exception('Fallo al sincronizar con el servidor: ${response.body}');
      }
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Error inesperado durante el registro: ${e.toString()}');
    }
  }

  // RF-U01 / CU2: Inicio de Sesión y Sincronización
  Future<Map<String, dynamic>> signInAndSync(String email, String password) async {
    try {
      // 1. Inicio de sesión en Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Sincronización para obtener datos de MySQL
      String firebaseUid = userCredential.user!.uid;

      final response = await http.post(
        // FIX: Usar la variable del endpoint centralizado
        Uri.parse(endpointUserSync),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firebase_uid': firebaseUid,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        return _decodeApiResponse(response.body);
      } else {
        throw Exception('Fallo al sincronizar con el servidor: ${response.body}');
      }
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Error inesperado durante el inicio de sesión: ${e.toString()}');
    }
  }

  /// Cierra la sesión activa del usuario en Firebase.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // Manejar el error de cierre de sesión
      throw Exception('Error al cerrar sesión: $e');
    }
  }


  // RNF-06: Obtiene el Token de ID actual
  Future<String?> getCurrentIdToken() async {
    return await _auth.currentUser?.getIdToken();
  }
}
