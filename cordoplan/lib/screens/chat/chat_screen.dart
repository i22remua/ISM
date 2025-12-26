// lib/screens/chat/chat_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/chat_api_service.dart';
import '../../providers/user_provider.dart';

class ChatScreen extends StatefulWidget {
  // FIX: El ID que se recibe ahora es el del local para el foro.
  final int localId;

  const ChatScreen({Key? key, required this.localId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatApiService _apiService = ChatApiService();
  late Future<List<dynamic>> _messagesFuture;
  Timer? _refreshTimer;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = Provider.of<UserProvider>(context, listen: false).userData?.idUsuario;
    _loadMessages();

    // FIX: Iniciar un temporizador para refrescar los mensajes periódicamente
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadMessages();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // Cancelar el temporizador para evitar fugas de memoria
    _messageController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    setState(() {
      _messagesFuture = _apiService.getForumMessages(widget.localId);
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      try {
        await _apiService.postForumMessage(widget.localId, _messageController.text);
        _messageController.clear();
        _loadMessages(); // Recargar mensajes inmediatamente después de enviar
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar mensaje: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foro del Local'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _messagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar mensajes: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aún no hay mensajes. ¡Sé el primero en opinar!'));
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final bool isMe = message['id_usuario'] == _currentUserId;

                    return ListTile(
                      title: Text(
                        message['nombre_usuario'] ?? 'Usuario',
                        style: TextStyle(fontWeight: FontWeight.bold, color: isMe ? Colors.blue : Colors.black),
                      ),
                      subtitle: Text(message['mensaje'] ?? ''),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu opinión...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
