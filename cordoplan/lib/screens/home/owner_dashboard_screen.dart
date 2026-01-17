// lib/screens/home/owner_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../models/local_model.dart'; // Importamos el modelo Local
import '../../services/local_api_service.dart'; // Para obtener los datos del local del dueño
import '../owner/create_local_screen.dart';
import '../owner/event_management_screen.dart';
import '../../services/firebase_auth_service.dart';
import '../auth/login_screen.dart'; // Para redirigir al login
import '../admin/account_management_screen.dart';
import '../admin/aforo_monitoring_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  final String userRole;
  final int userId; 

  const OwnerDashboardScreen({
    Key? key,
    required this.userRole,
    required this.userId,
  }) : super(key: key);

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final LocalApiService _apiService = LocalApiService();
  Local? _myLocal;
  bool _isLoadingLocal = true;

  @override
  void initState() {
    super.initState();
    // Los Propietarios deben verificar y cargar los datos de su local al inicio.
    if (widget.userRole != 'Usuario') {
      _loadMyLocal();
    }
  }

  // Carga el local del propietario desde la API
  Future<void> _loadMyLocal() async {
    setState(() {
      _isLoadingLocal = true;
    });
    try {
     
      final local = await _apiService.fetchOwnerLocal(widget.userId);
      setState(() {
        _myLocal = local;
      });
    } catch (e) {
      // 404 Not Found es esperado si el propietario aún no tiene un local registrado
      debugPrint('No se encontró local: $e');
      _myLocal = null;
    } finally {
      setState(() {
        _isLoadingLocal = false;
      });
    }
  }

  void _handleLogout() async {
    await AuthService().signOut(); // Lógica de cierre de sesión de Firebase
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false, // Elimina todas las rutas anteriores
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = widget.userRole == 'Administrador';

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Admin Dashboard' : 'Gestión de Local'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido, ${widget.userRole}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // --- GESTIÓN DE PROPIETARIOS ---
            _buildManagementStatus(),

            _buildCard(
              context,
              _myLocal == null ? 'Registrar Nuevo Local' : 'Modificar Local',
              _myLocal == null ? 'Tu local aún no está visible.' : 'Modifica los detalles de ${_myLocal!.nombre}',
              _myLocal == null ? Icons.add_business : Icons.edit,
                  () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateLocalScreen(existingLocal: _myLocal),
                  ),
                );
                _loadMyLocal(); // Recargar después de la acción
              },
            ),

            _buildCard(
              context,
              'Gestión de Eventos',
              'Crea o cancela eventos para ${_myLocal?.nombre ?? 'tu local'}.',
              Icons.calendar_today,
              _myLocal == null
                  ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes registrar un local primero.')))
                  : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EventManagementScreen(local: _myLocal!),
                  ),
                );
              },
            ),

            // --- GESTIÓN DE ADMINISTRADORES ---
            if (isAdmin) ...[
              const Text('Funciones de Administración', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildCard(
                context,
                'Gestionar Cuentas',
                'Administrar roles y usuarios.',
                Icons.supervised_user_circle,
                () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AccountManagementScreen())),
              ),
              _buildCard(
                context,
                'Monitoreo de Aforo Global',
                'Ver aforo de todos los locales en tiempo real.',
                Icons.monitor_heart,
                () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AforoMonitoringScreen())),
              ),
            ],

            const Spacer(),
            Center(
              child: TextButton(
                onPressed: _handleLogout,
                child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementStatus() {
    if (_isLoadingLocal) {
      return const LinearProgressIndicator();
    }
    if (_myLocal == null && widget.userRole == 'Propietario') {
      return const Card(
        color: Colors.orangeAccent,
        margin: EdgeInsets.only(bottom: 20),
        child: ListTile(
          leading: Icon(Icons.warning, color: Colors.white),
          title: Text('ESTADO: Sin Local Registrado', style: TextStyle(color: Colors.white)),
          subtitle: Text('Usa la opción de abajo para registrar tu negocio.', style: TextStyle(color: Colors.white70)),
        ),
      );
    }
    if (_myLocal != null) {
      return Card(
        color: Colors.green,
        margin: const EdgeInsets.only(bottom: 20),
        child: ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.white),
          title: Text('ESTADO: Local Registrado: ${_myLocal!.nombre}', style: const TextStyle(color: Colors.white)),
          subtitle: Text('Aforo Actual: ${_myLocal!.aforoActual}/${_myLocal!.aforoMaximo}', style: const TextStyle(color: Colors.white70)),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}
