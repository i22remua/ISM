// lib/services/nfc_manager_service.dart
import 'package:nfc_manager/nfc_manager.dart';

import 'package:nfc_manager/nfc_manager.dart' as nfc;



import 'endpoints.dart';
import 'http_client.dart';

class NfcManagerService {
  final HttpClient _httpClient = HttpClient();
  
  get Ndef => null;

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

  Future<Map<String, dynamic>> addFriendByNfc(String nfcTagIdObjetivo) async {
    return await _httpClient.post(
      endpointFriendsNfc,
      body: {
        'nfc_tag_id_objetivo': nfcTagIdObjetivo,
      },
      requireAuth: true, // Requiere que el Usuario esté autenticado
    );
  }
  
  Future<void> startNfcReadingSession({required Function(String tagId) onTagDiscovered}) async {
    
    if (await NfcManager.instance.isAvailable() == false) {
      // Usar la verificación simple aquí es suficiente si la app maneja la indisponibilidad.
      // throw Exception("NFC no está disponible en este dispositivo.");
    }
    
    NfcManager.instance.startSession(
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