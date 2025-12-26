// lib/services/admin_api_service.dart
import '../models/user_data_model.dart';
import 'endpoints.dart';
import 'http_client.dart';

class AdminApiService {
  final HttpClient _httpClient = HttpClient();

  // Obtiene todos los usuarios para el panel de administración (RF-A02)
  Future<List<UserData>> getAllUsers() async {
    final response = await _httpClient.get(endpointAdminGetAllUsers, requireAuth: true);
    if (response is List) {
      return response.map((userJson) => UserData.fromJson(userJson)).toList();
    }
    throw Exception('La respuesta del servidor no es una lista de usuarios.');
  }

  // Actualiza el rol de un usuario
  Future<void> updateUserRole(int userId, String newRole) async {
    await _httpClient.put(
      endpointAdminUpdateUser(userId),
      body: {'rol': newRole},
      requireAuth: true,
    );
  }

  // Elimina un usuario
  Future<void> deleteUser(int userId) async {
    await _httpClient.delete(
      endpointAdminDeleteUser(userId),
      requireAuth: true,
    );
  }
}
