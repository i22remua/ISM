
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../services/local_api_service.dart';
import '../../../models/local_model.dart';
import 'map_picker_screen.dart';

class CreateLocalScreen extends StatefulWidget {
  final Local? existingLocal;

  const CreateLocalScreen({Key? key, this.existingLocal}) : super(key: key);

  @override
  _CreateLocalScreenState createState() => _CreateLocalScreenState();
}

class _CreateLocalScreenState extends State<CreateLocalScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _capacityController = TextEditingController();
  final _addressController = TextEditingController(); // Nuevo controlador
  final LocalApiService _apiService = LocalApiService();
  
  LatLng? _selectedLocation;
  bool _isLoading = false;
  String _pageTitle = 'Registrar Nuevo Local';

  @override
  void initState() {
    super.initState();
    if (widget.existingLocal != null) {
      _loadLocalData(widget.existingLocal!); // Carga los datos existentes
      _pageTitle = 'Modificar Local';
    } 
  }

  void _loadLocalData(Local local) {
    _nameController.text = local.nombre;
    _descriptionController.text = local.descripcion;
    _capacityController.text = local.aforoMaximo.toString();
    _addressController.text = local.ubicacion; // Carga la dirección
    _selectedLocation = LatLng(local.latitud, local.longitud);
  }

  void _navigateToMapPicker() async {
    final LatLng? result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(
          initialLocation: _selectedLocation ?? const LatLng(37.8821, -4.7797),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  void _handleSubmit() async {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona la ubicación del local en el mapa.')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final Map<String, dynamic> localData = {
        'nombre': _nameController.text,
        'descripcion': _descriptionController.text,
        'aforo_maximo': int.tryParse(_capacityController.text) ?? 0,
        'ubicacion': _addressController.text, // Envía la dirección
        'latitud': _selectedLocation!.latitude,
        'longitud': _selectedLocation!.longitude,
        'tipo_ocio': 'Discoteca', // Simplificado
      };

      if (widget.existingLocal == null) {
        await _apiService.createLocal(localData);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Local creado con éxito!')));
      } else {
        await _apiService.modifyLocal(widget.existingLocal!.idLocal, localData);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Local modificado con éxito!')));
      }

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar local: ${e.toString()}')),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CustomTextField(controller: _nameController, labelText: 'Nombre del Local', icon: Icons.title),
            const SizedBox(height: 16),
            CustomTextField(controller: _descriptionController, labelText: 'Descripción', icon: Icons.description),
            const SizedBox(height: 16),
            CustomTextField(controller: _capacityController, labelText: 'Aforo Máximo', icon: Icons.people_outline, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            
            // Nuevo campo para la dirección
            CustomTextField(controller: _addressController, labelText: 'Dirección del Local', icon: Icons.location_on_outlined),
            const SizedBox(height: 24),

            // Selección de Ubicación en el mapa
            ListTile(
              leading: const Icon(Icons.map, color: Colors.blueAccent),
              title: const Text('Abrir Mapa'),
              subtitle: Text(
                _selectedLocation != null
                    ? 'Ubicación seleccionada: (${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)})'
                    : 'Pulsa para elegir la ubicación en el mapa',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _navigateToMapPicker,
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text(
                widget.existingLocal == null ? 'Registrar Local' : 'Guardar Cambios',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
