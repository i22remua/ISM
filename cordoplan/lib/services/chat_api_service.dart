// lib/services/chat_api_service.dart
import 'dart:async';
import '../services/http_client.dart';
import 'endpoints.dart';

class ChatApiService {
  final HttpClient _httpClient = HttpClient();

  // Obtiene los mensajes del foro de un local
  Future<List<dynamic>> getForumMessages(int localId) async {
    final response = await _httpClient.get(
      endpointForumMessages(localId),
      requireAuth: true,
    );
    if (response is List) {
      return response;
    }
    throw Exception('La respuesta para el foro no es una lista de mensajes.');
  }

  // Envía un nuevo mensaje al foro de un local
  Future<void> postForumMessage(int localId, String message) async {
    await _httpClient.post(
      endpointForumPostMessage(localId),
      body: {
        'id_local': localId,
        'mensaje': message,
      },
      requireAuth: true,
    );
  }
}
