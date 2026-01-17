// lib/services/endpoints.dart
import 'dart:io' show Platform;

// --- Base URL Dinámica ---

// CAMBIO PARA DESARROLLO EN MÓVIL FÍSICO
// 1. Pon esto a `true` cuando ejecutes la app en tu móvil real.
// 2. Reemplaza 'TU_IP_DE_MAC' con la IP de tu Mac en la red Wi-Fi.
const bool useMacIp = true; // ¡PONER A `false` PARA EL EMULADOR!
const String macIp = '192.168.1.142'; // <-- REEMPLAZA ESTA IP

String getBaseUrl() {
  if (Platform.isAndroid && useMacIp) {
    return 'http://$macIp:3000/api';
  }
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000/api'; // Para el emulador de Android
  } else {
    return 'http://127.0.0.1:3000/api'; // Para iOS o Desktop
  }
}

final String baseUrl = getBaseUrl();

// Endpoints de Usuario
final String endpointUserSync = '$baseUrl/users/sync';
final String endpointFriendsNfc = '$baseUrl/users/friends/add/nfc';

// Endpoints de Locales y Exploración
final String endpointLocales = '$baseUrl/locales';
String endpointLocalDetail(int idLocal) => '$baseUrl/locales/$idLocal';
String endpointLocalEvents(int idLocal) => '$baseUrl/locales/$idLocal/eventos';

// Endpoints de Gestión de Aforo
String endpointAforoEntrada(int idLocal) => '$baseUrl/locales/$idLocal/nfc/entrada';
String endpointAforoSalida(int idLocal) => '$baseUrl/locales/$idLocal/nfc/salida';

// Endpoints de Gestión de Eventos
final String endpointCreateEvent = '$baseUrl/locales/eventos';
String endpointEventDetail(int idEvento) => '$baseUrl/locales/eventos/$idEvento';
String endpointCancelEvent(int idEvento) => '$baseUrl/locales/eventos/$idEvento/cancel';

// Endpoints de Administración
final String endpointAdminGetAllUsers = '$baseUrl/admin/users';
String endpointAdminUpdateUser(int userId) => '$baseUrl/admin/users/$userId';
String endpointAdminDeleteUser(int userId) => '$baseUrl/admin/users/$userId';

// FIX: Corregido a 'foro' para coincidir con el backend
String endpointForumMessages(int localId) => '$baseUrl/foro/$localId/messages';
String endpointForumPostMessage(int localId) => '$baseUrl/foro/$localId/messages';
