// lib/screens/owner/aforo_nfc_screen.dart
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../../services/local_api_service.dart';
import '../../models/local_model.dart';

class AforoNfcScreen extends StatefulWidget {
  final Local local;

  const AforoNfcScreen({super.key, required this.local});

  @override
  _AforoNfcScreenState createState() => _AforoNfcScreenState();
}

class _AforoNfcScreenState extends State<AforoNfcScreen> {
  final LocalApiService _apiService = LocalApiService();
  late int _aforoActual;
  String _statusMessage = "Listo para escanear...";
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _aforoActual = widget.local.aforoActual;
  }

  Future<void> _startNfcScan(String mode) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = "Acerca la pulsera NFC para registrar la ${mode}...";
    });

    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        throw 'NFC no disponible en este dispositivo.';
      }

      await NfcManager.instance.startSession(
        pollingOptions: const {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
        },
        onDiscovered: (NfcTag tag) async {
          try {
            Map<String, dynamic> result;
            String successMessage;

            if (mode == 'entrada') {
              result = await _apiService.registrarEntradaNfc(widget.local.idLocal);
              // FIX: Mensaje personalizado para la entrada
              successMessage = '¡Entrada registrada con éxito!\nAutomáticamente has entrado en el sorteo de un bonocopas para esta noche. ¡Suerte!';
            } else {
              result = await _apiService.registrarSalidaNfc(widget.local.idLocal);
              // FIX: Mensaje personalizado para la salida
              successMessage = '¡Salida registrada correctamente! Gracias por tu visita.';
            }

            await NfcManager.instance.stopSession();
            setState(() {
              _aforoActual = result['aforoActual'];
              // FIX: Usar el nuevo mensaje personalizado
              _statusMessage = successMessage;
              _isProcessing = false;
            });

          } catch (e) {
            await NfcManager.instance.stopSession();
            setState(() {
              _statusMessage = 'Error al procesar la etiqueta: ${e.toString()}';
              _isProcessing = false;
            });
          }
        },
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Error de NFC: ${e.toString()}';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Control de Aforo de ${widget.local.nombre}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indicador de Aforo
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'Aforo Actual',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$_aforoActual / ${widget.local.aforoMaximo}',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Botones de Acción
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_upward),
              label: const Text('Registrar Entrada'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: _isProcessing ? null : () => _startNfcScan('entrada'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_downward),
              label: const Text('Registrar Salida'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: _isProcessing ? null : () => _startNfcScan('salida'),
            ),
            const SizedBox(height: 40),

            // Mensaje de Estado
            if (_statusMessage.isNotEmpty)
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                // FIX: Estilo mejorado para el mensaje de éxito
                style: TextStyle(
                  fontSize: 18,
                  color: _statusMessage.contains('Error') ? Colors.red : Colors.green[800],
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic, // <-- AÑADIDO
                ),
              ),

            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: LinearProgressIndicator(),
              )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    try {
      NfcManager.instance.stopSession();
    } catch (_) {
      // Ignorar si no había ninguna sesión activa
    }
    super.dispose();
  }
}
