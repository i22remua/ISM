// lib/services/firebase_chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Necesario para obtener el usuario actual

class FirebaseChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instancia para acceder a la autenticación

  Future<void> sendMessage(int localId, String text) async {
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('Error: Usuario no autenticado.');
    }

    try {
      await _firestore
          .collection('locales_chats')
          .doc(localId.toString()) 
          .collection('mensajes')
          .add({
            'userId': currentUser.uid, // Obtenido automáticamente
            'userName': currentUser.displayName ?? 'Usuario Anónimo', // Obtenido automáticamente
            'text': text, // Corregido para que coincida con la pantalla de chat
            'timestamp': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Error al enviar mensaje: $e');
    }
  }

  // Obtener un stream de mensajes para escuchar en tiempo real
  Stream<QuerySnapshot> getMessages(int localId) {
    return _firestore
        .collection('locales_chats')
        .doc(localId.toString())
        .collection('mensajes')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Comprueba si el ID de un mensaje corresponde al del usuario actual
  bool isCurrentUser(String userId) {
    final User? currentUser = _auth.currentUser;
    return currentUser != null && currentUser.uid == userId;
  }
}
