// lib/screens/admin/account_management_screen.dart
import 'package:flutter/material.dart';
import '../../models/user_data_model.dart';
import '../../services/admin_api_service.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({Key? key}) : super(key: key);

  @override
  _AccountManagementScreenState createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  final AdminApiService _apiService = AdminApiService();
  late Future<List<UserData>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _apiService.getAllUsers();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = _apiService.getAllUsers();
    });
  }

  // Lógica para editar el rol de un usuario
  Future<void> _handleEditUser(UserData user) async {
    const List<String> roles = ['Usuario', 'Propietario', 'Administrador'];

    final String? newRole = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Cambiar rol de ${user.nombre}'),
        children: roles.map((role) {
          return SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(role),
            child: Text(role, style: user.rol == role ? const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue) : null),
          );
        }).toList(),
      ),
    );

    if (newRole != null && newRole != user.rol) {
      try {
        await _apiService.updateUserRole(user.idUsuario, newRole);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rol actualizado con éxito.')),
        );
        _refreshUsers(); // Refrescar la lista
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el rol: ${e.toString()}')),
        );
      }
    }
  }

  // Lógica para eliminar un usuario con diálogo de confirmación
  Future<void> _handleDeleteUser(int userId, String userName) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar al usuario $userName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sí, Eliminar'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteUser(userId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario eliminado con éxito.')),
        );
        _refreshUsers(); // Refrescar la lista
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar usuario: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Cuentas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshUsers,
            tooltip: 'Refrescar Lista',
          ),
        ],
      ),
      body: FutureBuilder<List<UserData>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar usuarios: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron usuarios.'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(user.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Email: ${user.email} | Rol: ${user.rol}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _handleEditUser(user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _handleDeleteUser(user.idUsuario, user.nombre),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
