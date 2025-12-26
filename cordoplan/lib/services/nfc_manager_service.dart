// lib/services/nfc_manager_service.dart
import 'package:nfc_manager/nfc_manager.dart';

import 'package:nfc_manager/nfc_manager.dart' as nfc;



import 'endpoints.dart';
import 'http_client.dart';

class NfcManagerService {
  final HttpClient _httpClient = HttpClient();
  
  get Ndef => null;

  // RF-P04: Función de gestión de aforo (Propietario/Admin)
  Future<Map<String, dynamic>> updateAforo(int idLocal, {required bool isEntry}) async {
    final url = isEntry 
        ? endpointAforoEntrada(idLocal) 
        : endpointAforoSalida(idLocal);

    return await _httpClient.post(
      url, 
      body: {}, 
      requireAuth: true // Requiere autenticación del Propietario/Admin
    );
  }

  // RF-U08 / CU7: Lógica para agregar amigo mediante pulsera NFC
  Future<Map<String, dynamic>> addFriendByNfc(String nfcTagIdObjetivo) async {
    return await _httpClient.post(
      endpointFriendsNfc,
      body: {
        'nfc_tag_id_objetivo': nfcTagIdObjetivo,
      },
      requireAuth: true, // Requiere que el Usuario esté autenticado
    );
  }
  
  // RF-U08: Iniciar la sesión de lectura NFC
  Future<void> startNfcReadingSession({required Function(String tagId) onTagDiscovered}) async {
    
    // Corrección de 'isAvailable' a 'checkAvailability'
    if (await NfcManager.instance.isAvailable() == false) {
      // Usar la verificación simple aquí es suficiente si la app maneja la indisponibilidad.
      // throw Exception("NFC no está disponible en este dispositivo.");
    }
    
    NfcManager.instance.startSession(
      // Corrección de 'pollingOptions' (Error de argumento requerido)
      pollingOptions: {}, 
      onDiscovered: (nfc.NfcTag tag) async {
        final ndef = Ndef.from(tag);
        if (ndef != null) {
          final record = ndef.cachedMessage?.records.first;
          if (record != null && record.payload != null) {
            final tagId = String.fromCharCodes(record.payload!); 
            onTagDiscovered(tagId);
          }
        }
        NfcManager.instance.stopSession();
      },
    );
  }
}