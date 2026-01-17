// lib/screens/home/local_search_screen.dart
import 'package:flutter/material.dart';
import '../../services/local_api_service.dart';
import '../../models/local_model.dart';
import 'local_detail_screen.dart'; 

class LocalSearchScreen extends StatefulWidget {
  const LocalSearchScreen({super.key});

  @override
  _LocalSearchScreenState createState() => _LocalSearchScreenState();
}

class _LocalSearchScreenState extends State<LocalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final LocalApiService _apiService = LocalApiService();
  List<Local> _searchResults = [];
  bool _isLoading = false;
  String _lastQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    
    // Evita la búsqueda si la consulta no ha cambiado
    if (trimmedQuery == _lastQuery && !_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _lastQuery = trimmedQuery;
    });

    try {
      // Llama al servicio de API para realizar la búsqueda en el backend
      final results = await _apiService.searchLocales(trimmedQuery);
      
      setState(() {
        _searchResults = results;
      });
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de búsqueda: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToLocalDetails(Local local) {
     Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LocalDetailScreen(local: local),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Locales'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre, tipo de ocio o cercanía (RF-U03)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _performSearch(_searchController.text),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: _performSearch,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Indicador de Carga
          _isLoading 
              ? const LinearProgressIndicator() 
              : const SizedBox(height: 4),

          // Resultados de Búsqueda
          Expanded(
            child: _searchResults.isEmpty && !_isLoading && _lastQuery.isNotEmpty
                ? Center(child: Text('No se encontraron resultados para "$_lastQuery"'))
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final local = _searchResults[index];
                      return ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(local.nombre),
                        subtitle: Text('Tipo: ${local.tipoOcio} | Ocupación: ${local.aforoActual}/${local.aforoMaximo}'),
                        onTap: () => _navigateToLocalDetails(local),
                      );
                    },
                  ),
          ),
          
          // Mensaje si no se ha buscado nada
          if (_searchResults.isEmpty && !_isLoading && _lastQuery.isEmpty)
             const Center(
               child: Padding(
                 padding: EdgeInsets.all(20.0),
                 child: Text('Ingresa un término para buscar locales cercanos.', style: TextStyle(color: Colors.grey)),
               ),
             ),
        ],
      ),
    );
  }
}
