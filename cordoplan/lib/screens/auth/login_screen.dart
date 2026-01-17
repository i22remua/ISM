
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_auth_service.dart';
import '../../providers/user_provider.dart';
import '../home/home_map_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error),
    );
  }

  void _handleSignIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackbar('Por favor, ingresa email y contraseña.');
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final userData = await _authService.signInAndSync(
        _emailController.text,
        _passwordController.text,
      );

      Provider.of<UserProvider>(context, listen: false).setUser(userData);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeMapScreen(userRole: userData['rol'] ?? 'invitado'),
        ),
      );

    } catch (e) {
      String errorMessage = e.toString().contains(':') ? e.toString().split(':')[1].trim() : e.toString();
      _showErrorSnackbar('Error de inicio de sesión: $errorMessage');
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Logo de la aplicación
                Image.asset(
                  'assets/images/logo.png', 
                  height: 180, 
                ),
                const SizedBox(height: 32),

                Text(
                  'Bienvenido de nuevo',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Inicia sesión para continuar',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                // Campo de Email
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Campo de Contraseña
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 32),

                // Botón de Iniciar Sesión
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _handleSignIn,
                        child: const Text('Iniciar Sesión'),
                      ),
                const SizedBox(height: 16),

                // Enlace de registro
                TextButton(
                  onPressed: _navigateToRegister,
                  child: Text(
                    '¿No tienes cuenta? Regístrate aquí',
                    style: TextStyle(color: theme.colorScheme.secondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
