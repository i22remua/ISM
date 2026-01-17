// lib/screens/owner/owner_dashboard_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'create_local_screen.dart';
import 'create_event_screen.dart';
import 'cancel_event_screen.dart';
import '../../services/local_api_service.dart';
import '../../models/local_model.dart';
import '../../providers/user_provider.dart';

import '../admin/account_management_screen.dart';
import '../admin/aforo_monitoring_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  @override
  _OwnerDashboardScreenState createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final LocalApiService _apiService = LocalApiService();

  // Esta función solo la usan los propietarios
  void _navigateToModifyLocal() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final int? ownerId = userProvider.userData?.idUsuario;

    if (ownerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se pudo identificar al propietario.')),
      );
      return;
    }
    
    try {
      final List<Local> allLocales = await _apiService.fetchLocales();
      final ownerLocal = allLocales.firstWhere(
        (local) => local.idPropietario == ownerId,
        orElse: () => throw Exception('No se encontró un local asociado a este propietario.'),
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CreateLocalScreen(existingLocal: ownerLocal),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final role = userProvider.userData?.rol ?? '';

    final String title = role == 'Administrador' ? 'Panel del Administrador' : 'Panel del Propietario';
    final List<Widget> menuOptions = _buildMenuOptions(context, role);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: menuOptions.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Muestra un loading si el rol aún no se ha cargado
          : ListView(
              padding: const EdgeInsets.all(24.0),
              children: menuOptions,
            ),
    );
  }

  List<Widget> _buildMenuOptions(BuildContext context, String role) {
    if (role == 'Administrador') {
      return [
        _buildManagementCard(
          context,
          icon: Icons.manage_accounts,
          title: 'Gestionar Cuentas de Usuario',
          subtitle: 'Activar, desactivar o cambiar roles de usuarios.',
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AccountManagementScreen()));
          },
        ),
        _buildManagementCard(
          context,
          icon: Icons.bar_chart,
          title: 'Monitorear Aforo Global',
          subtitle: 'Ver el aforo de todos los locales en tiempo real.',
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AforoMonitoringScreen()));
          },
        ),
      ];
    } else if (role == 'Propietario') {
      return [
        _buildManagementCard(context, icon: Icons.add_business, title: 'Crear Nuevo Local', subtitle: 'Añade tu establecimiento a CordoPlan.', onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateLocalScreen()));
        }),
        _buildManagementCard(context, icon: Icons.edit_location_alt, title: 'Modificar Mi Local', subtitle: 'Actualiza la información, aforo y detalles.', onTap: _navigateToModifyLocal),
        _buildManagementCard(context, icon: Icons.event, title: 'Crear un Evento', subtitle: 'Promociona un nuevo evento en tu local.', onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateEventScreen()));
        }),
        _buildManagementCard(context, icon: Icons.cancel_presentation, title: 'Gestionar Eventos', subtitle: 'Modifica o cancela un evento programado.', onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => CancelEventScreen()));
        }),
      ];
    }
    return []; // Devuelve una lista vacía mientras se determina el rol
  }

  Widget _buildManagementCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
