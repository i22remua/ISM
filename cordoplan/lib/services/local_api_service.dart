// lib/services/local_api_service.dart
import '../models/local_model.dart';
import '../models/event_model.dart';
import 'endpoints.dart';
import 'http_client.dart';

class LocalApiService {
  // FIX: Inicializar la variable final aquí para que esté definida
  final HttpClient _httpClient = HttpClient();

  // Función auxiliar para mapear una lista dinámica de JSON a un modelo específico
  List<T> _mapResponseList<T>(dynamic response,
      T Function(Map<String, dynamic> json) fromJson) {
    if (response is List) {
      return response
          .map((jsonItem) => fromJson(jsonItem as Map<String, dynamic>))
          .toList();
    }
    // Si la respuesta no es una lista o está mal formada
    throw Exception("Invalid response format: Expected a List.");
  }


  // ----------------------------------------------------------------------
  // EXPLORACIÓN Y DETALLE (USUARIO)
  // ----------------------------------------------------------------------

  // RF-U02: Obtener todos los locales para el mapa (Pública)
  Future<List<Local>> fetchLocales() async {
    final response = await _httpClient.get(endpointLocales);
    return _mapResponseList<Local>(response, Local.fromJson);
  }

  // RF-U03: Búsqueda de locales por query (Pública)
  Future<List<Local>> searchLocales(String query) async {
    // Nota: El endpoint es GET /api/locales/search?query={query}
    final url = '$endpointLocales/search?query=$query';
    final response = await _httpClient.get(url);
    return _mapResponseList<Local>(response, Local.fromJson);
  }


  // RF-U04, RF-U05: Obtener información detallada y aforo actual
  Future<Local> fetchLocalDetails(int idLocal) async {
    // Usamos la función de endpoint (ej: /api/locales/123)
    final response = await _httpClient.get(endpointLocalDetail(idLocal));

    if (response is Map<String, dynamic>) {
      return Local.fromJson(response);
    }
    throw Exception(
        "Invalid response format: Expected a single Map for local details.");
  }

  // RF-U06 / CU8: Obtener eventos de un local (Pública)
  Future<List<Event>> fetchLocalEvents(int idLocal) async {
    final response = await _httpClient.get(endpointLocalEvents(idLocal));

    return _mapResponseList<Event>(response, Event.fromJson);
  }

  // RF-P03: Obtiene el local asignado al ID de usuario actual (para OwnerDashboard)
  // Nota: El endpoint del backend debe usar req.user.id_usuario_peticion
  Future<Local> fetchOwnerLocal(int userId) async {
    // Endpoint simulado: GET /api/owner/my-local (Requiere token)
    final response = await _httpClient.get(
        '$baseUrl/owner/my-local', requireAuth: true);

    if (response is Map<String, dynamic>) {
      return Local.fromJson(response);
    }
    // Lanza excepción si el formato es incorrecto (o si el backend devolvió 404/no existe)
    throw Exception("Could not retrieve local details for this owner.");
  }

  // ----------------------------------------------------------------------
  // GESTIÓN (PROPIETARIO/ADMINISTRADOR)
  // ----------------------------------------------------------------------

  // RF-P02 / CU9: Crear un nuevo local
  Future<Map<String, dynamic>> createLocal(
      Map<String, dynamic> localData) async {
    return await _httpClient.post(
      endpointLocales,
      body: localData,
      requireAuth: true, // RNF-06: Requiere token
    );
  }

  // RF-P03 / CU10: Modificar la información de un local
  Future<Map<String, dynamic>> modifyLocal(int idLocal,
      Map<String, dynamic> localData) async {
    // FIX: Cambiado a PUT, el método estándar para actualizaciones
    return await _httpClient.put(
      endpointLocalDetail(idLocal),
      body: localData,
      requireAuth: true,
    );
  }

  // RF-P05 / CU11: Crear un nuevo evento
  Future<Map<String, dynamic>> createEvent(
      Map<String, dynamic> eventData) async {
    return await _httpClient.post(
      endpointCreateEvent,
      body: eventData,
      requireAuth: true,
    );
  }

  // RF-P05: Modificar evento existente
  Future<Map<String, dynamic>> modifyEvent(int idEvento,
      Map<String, dynamic> eventData) async {
    // FIX: Cambiado a PUT para coincidir con la definición de la API
    final response = await _httpClient.put(
      endpointEventDetail(idEvento),
      body: eventData,
      requireAuth: true,
    );
    return response as Map<String, dynamic>;
  }

  // RF-P05 / CU12: Cancelar evento
  Future<Map<String, dynamic>> cancelEvent(int idEvento) async {
    // Usar el método DELETE
    final response = await _httpClient.delete(
        endpointCancelEvent(idEvento),
        requireAuth: true
    );
    return response;
  }
}