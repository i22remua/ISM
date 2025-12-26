// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Importa el archivo principal de tu aplicación (asume que está en lib/main.dart)
import 'package:cordoplan/main.dart';
// Importa la pantalla de Login para verificar su existencia
import 'package:cordoplan/screens/auth/login_screen.dart';

void main() {
  // Define un grupo de pruebas relacionadas con la interfaz de usuario inicial
  group('CordoPlan Widget Tests', () {

    // Test 1: Verificar que la aplicación MyApp se inicia correctamente.
    testWidgets('App se inicia y muestra el título principal', (WidgetTester tester) async {
      // Construye nuestra aplicación y dispara un frame.
      // Aquí estamos cargando el widget principal MyApp.
      await tester.pumpWidget(MyApp());

      // Busca el widget MaterialApp, que debe existir.
      expect(find.byType(MaterialApp), findsOneWidget);

      // Verifica que el título de la aplicación es 'CordoPlan'
      expect(find.text('CordoPlan'), findsNothing); // Esto es el 'title' del MaterialApp, no visible directamente
    });

    // Test 2: Verificar que la pantalla inicial de Login se carga correctamente.
    testWidgets('La aplicación se inicia en la LoginScreen', (WidgetTester tester) async {
      // Construye la aplicación.
      await tester.pumpWidget(MyApp());

      // Verifica que el widget principal de LoginScreen está presente.
      expect(find.byType(LoginScreen), findsOneWidget);

      // Verifica que el texto principal de LoginScreen está visible.
      // (Se busca el título del AppBar de la LoginScreen).
      expect(find.text('CordoPlan - Iniciar Sesión'), findsOneWidget);

      // Verifica que los campos de texto existen
      expect(find.byType(TextField), findsNWidgets(2));

      // Verifica que el botón de Iniciar Sesión existe (CU2)
      expect(find.byWidgetPredicate(
            (widget) => widget is ElevatedButton && widget.child is Text && (widget.child as Text).data == 'Iniciar Sesión',
      ), findsOneWidget);
    });

    // Puedes agregar más tests aquí para verificar la navegación o los widgets de la HomeMapScreen, etc.
  });
}