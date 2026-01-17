// lib/services/local_api_service.dart
import '../models/local_model.dart';
import '../models/event_model.dart';
import 'endpoints.dart';
import 'http_client.dart';

class LocalApiService {
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

  Future<List<Local>> fetchLocales() async {
    final response = await _httpClient.get(endpointLocales);
    return _mapResponseList<Local>(response, Local.fromJson);
  }

  Future<List<Local>> searchLocales(String query) async {
    final url = '$endpointLocales?query=$query';
    final response = await _httpClient.get(url);
    return _mapResponseList<Local>(response, Local.fromJson);
  }


  Future<Local> fetchLocalDetails(int idLocal) async {
    // Usamos la función de endpoint (ej: /api/locales/123)
    final response = await _httpClient.get(endpointLocalDetail(idLocal));

    if (response is Map<String, dynamic>) {
      return Local.fromJson(response);
    }
    throw Exception(
        "Invalid response format: Expected a single Map for local details.");
  }

  Future<List<Event>> fetchLocalEvents(int idLocal) async {
    final response = await _httpClient.get(endpointLocalEvents(idLocal));

    return _mapResponseList<Event>(response, Event.fromJson);
  }

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

  Future<Map<String, dynamic>> createLocal(
      Map<String, dynamic> localData) async {
    return await _httpClient.post(
      endpointLocales,
      body: localData,
      requireAuth: true, 
    );
  }

  Future<Map<String, dynamic>> modifyLocal(int idLocal,
      Map<String, dynamic> localData) async {
    return await _httpClient.put(
      endpointLocalDetail(idLocal),
      body: localData,
      requireAuth: true,
    );
  }

  Future<Map<String, dynamic>> createEvent(
      Map<String, dynamic> eventData) async {
    return await _httpClient.post(
      endpointCreateEvent,
      body: eventData,
      requireAuth: true,
    );
  }

  Future<Map<String, dynamic>> modifyEvent(int idEvento,
      Map<String, dynamic> eventData) async {
    final response = await _httpClient.put(
      endpointEventDetail(idEvento),
      body: eventData,
      requireAuth: true,
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> cancelEvent(int idEvento) async {
    return await _httpClient.post(
        endpointCancelEvent(idEvento),
        body: {},
        requireAuth: true
    );
  }

  // ----------------------------------------------------------------------
  // CONTROL DE AFORO (NFC)
  // ----------------------------------------------------------------------

  // Registra una entrada por NFC y devuelve el nuevo estado del aforo
  Future<Map<String, dynamic>> registrarEntradaNfc(int idLocal) async {
    return await _httpClient.post(
      endpointAforoEntrada(idLocal),
      body: {},
      requireAuth: true,
    );
  }

  // Registra una salida por NFC y devuelve el nuevo estado del aforo
  Future<Map<String, dynamic>> registrarSalidaNfc(int idLocal) async {
    return await _httpClient.post(
      endpointAforoSalida(idLocal),
      body: {},
      requireAuth: true,
    );
  }
}
