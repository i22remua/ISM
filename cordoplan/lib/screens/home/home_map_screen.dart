// lib/screens/home/home_map_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/local_api_service.dart';
import '../../models/local_model.dart';
import 'local_detail_screen.dart';
import 'owner_dashboard_screen.dart'; // Para navegación a gestión
import 'local_search_screen.dart'; // Para navegación a búsqueda

class HomeMapScreen extends StatefulWidget {
  final String userRole;
  // NOTA: Para producción, también se debería pasar el userId de MySQL aquí
  // final int userId;

  const HomeMapScreen({Key? key, required this.userRole}) : super(key: key);

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  GoogleMapController? _mapController;
  final LocalApiService _apiService = LocalApiService();
  final TextEditingController _searchController = TextEditingController();

  Set<Marker> _markers = {};
  LatLng _initialPosition = const LatLng(37.8821, -4.7797); // Córdoba por defecto
  bool _isLoading = true;
  bool _locationPermissionGranted = false;

  // Flag para identificar si la búsqueda está activa
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _determinePosition(); // RNF-11
      final locales = await _apiService.fetchLocales(); // RF-U02
      _updateMarkers(locales);
    } catch (e) {
      debugPrint("Error al inicializar: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al inicializar: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // RNF-11: Obtiene ubicación y ajusta la posición inicial
  Future<void> _determinePosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position pos = await Geolocator.getCurrentPosition();

        setState(() {
          _initialPosition = LatLng(pos.latitude, pos.longitude);
          _locationPermissionGranted = true;
        });

        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(_initialPosition),
          );
        }
      }
    } catch (e) {
      debugPrint("Error obteniendo ubicación: $e");
    }
  }

  // RF-U03: Realiza la búsqueda de locales
  Future<void> _searchLocales(String query) async {
    setState(() { _isLoading = true; });
    try {
      final locales = await _apiService.searchLocales(query);
      _updateMarkers(locales);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(locales.first.toLatLng(), 15),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en la búsqueda: $e')),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _updateMarkers(List<Local> locales) {
    setState(() {
      _markers = locales.map((local) {
        return Marker(
          markerId: MarkerId(local.idLocal.toString()),
          position: local.toLatLng(),
          infoWindow: InfoWindow(
            title: local.nombre,
            snippet: "Aforo: ${local.aforoActual}/${local.aforoMaximo}", // RF-U05
            onTap: () => _navigateToLocalDetails(local),
          ),
        );
      }).toSet();
    });
  }

  void _navigateToLocalDetails(Local local) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocalDetailScreen(local: local),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isManagementRole = widget.userRole == "Propietario" || widget.userRole == "Administrador";

    return Scaffold(
      appBar: AppBar(
        title: const Text("CordoPlan - Mapa de Ocio"),
        actions: [
          // Navegación a la pantalla de búsqueda (RF-U03)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LocalSearchScreen()),
              );
            },
            tooltip: 'Buscar Locales',
          ),

          // Botón de gestión para Propietarios/Admin
          if (isManagementRole)
            IconButton(
              icon: const Icon(Icons.business_center),
              tooltip: "Gestión de Local",
              onPressed: () {
                // Navegar al Dashboard. Usarás el userId que debes obtener en el LoginScreen.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OwnerDashboardScreen(
                      userRole: widget.userRole,
                      userId: 1, // ❌ REEMPLAZAR con el ID real del usuario del Login
                    ),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeApp,
            tooltip: "Recargar Locales",
          )
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
                target: _initialPosition, zoom: 14),
            onMapCreated: (controller) {
              _mapController = controller;
              controller.animateCamera(
                CameraUpdate.newLatLng(_initialPosition),
              );
            },
            myLocationEnabled: _locationPermissionGranted, // RNF-11
            myLocationButtonEnabled: _locationPermissionGranted,
            markers: _markers, // RF-U02
          ),

          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

// Extensión para facilitar la conversión del modelo
extension on Local {
  LatLng toLatLng() => LatLng(latitud, longitud);
}