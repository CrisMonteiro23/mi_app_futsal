// lib/screens/jugadores_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_app_futsal/data/app_data.dart';
import 'package:mi_app_futsal/models/jugador.dart';
import 'package:mi_app_futsal/models/equipo.dart'; // Necesario para obtener la lista de equipos

class JugadoresScreen extends StatefulWidget {
  const JugadoresScreen({super.key});

  @override
  State<JugadoresScreen> createState() => _JugadoresScreenState();
}

class _JugadoresScreenState extends State<JugadoresScreen> {
  // Controladores para los campos de texto del formulario
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _numeroCamisetaController = TextEditingController();
  final TextEditingController _posicionController = TextEditingController();
  String? _selectedEquipoId; // Para el ID del equipo seleccionado en el dropdown
  bool _isLesionado = false; // Para el estado de lesión

  // Opciones de posición para el dropdown
  final List<String> _posiciones = ['Portero', 'Cierre', 'Ala', 'Pívot'];

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _numeroCamisetaController.dispose();
    _posicionController.dispose();
    super.dispose();
  }

  // Función para mostrar el diálogo de añadir o editar jugador
  void _showJugadorDialog({Jugador? jugador}) {
    final appData = Provider.of<AppData>(context, listen: false);
    final List<Equipo> equiposDisponibles = appData.equipos;

    // Si no hay equipos, no se puede añadir un jugador
    if (equiposDisponibles.isEmpty && jugador == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero debes añadir al menos un equipo.')),
      );
      return;
    }

    // Precargar datos si estamos editando
    if (jugador != null) {
      _nombreController.text = jugador.nombre;
      _apellidoController.text = jugador.apellido;
      _numeroCamisetaController.text = jugador.numeroCamiseta.toString();
      _posicionController.text = jugador.posicion;
      _selectedEquipoId = jugador.equipoId;
      _isLesionado = jugador.lesionado;
    } else {
      // Limpiar campos para añadir
      _nombreController.clear();
      _apellidoController.clear();
      _numeroCamisetaController.clear();
      _posicionController.clear();
      _selectedEquipoId = equiposDisponibles.isNotEmpty ? equiposDisponibles.first.id : null; // Selecciona el primer equipo por defecto
      _isLesionado = false;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Usamos StatefulBuilder para que el diálogo pueda reconstruirse (para el Dropdown y Checkbox)
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: Text(jugador == null ? 'Añadir Nuevo Jugador' : 'Editar Jugador'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: _nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    TextField(
                      controller: _apellidoController,
                      decoration: const InputDecoration(labelText: 'Apellido'),
                    ),
                    // Dropdown para seleccionar el equipo
                    DropdownButtonFormField<String>(
                      value: _selectedEquipoId,
                      decoration: const InputDecoration(labelText: 'Equipo'),
                      items: equiposDisponibles.map((Equipo equipo) {
                        return DropdownMenuItem<String>(
                          value: equipo.id,
                          child: Text(equipo.nombre),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setStateInDialog(() { // Actualiza el estado del diálogo
                          _selectedEquipoId = newValue;
                        });
                      },
                      isExpanded: true, // Hace que el dropdown ocupe todo el ancho
                    ),
                    TextField(
                      controller: _posicionController,
                      decoration: const InputDecoration(labelText: 'Posición (ej: Portero, Cierre, Ala, Pívot)'),
                    ),
                    TextField(
                      controller: _numeroCamisetaController,
                      decoration: const InputDecoration(labelText: 'Número de Camiseta'),
                      keyboardType: TextInputType.number, // Solo permite números
                    ),
                    Row(
                      children: [
                        const Text('Lesionado:'),
                        Checkbox(
                          value: _isLesionado,
                          onChanged: (bool? newValue) {
                            setStateInDialog(() { // Actualiza el estado del diálogo
                              _isLesionado = newValue ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text(jugador == null ? 'Añadir' : 'Guardar'),
                  onPressed: () {
                    if (_nombreController.text.isEmpty ||
                        _apellidoController.text.isEmpty ||
                        _selectedEquipoId == null ||
                        _posicionController.text.isEmpty ||
                        _numeroCamisetaController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, completa todos los campos obligatorios.')),
                      );
                      return;
                    }

                    final int? numeroCamiseta = int.tryParse(_numeroCamisetaController.text);
                    if (numeroCamiseta == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('El número de camiseta debe ser un número válido.')),
                      );
                      return;
                    }

                    // Encontrar el nombre del equipo a partir del ID seleccionado
                    final String equipoNombre = equiposDisponibles
                        .firstWhere((e) => e.id == _selectedEquipoId)
                        .nombre;

                    if (jugador == null) {
                      appData.addJugador(
                        _nombreController.text,
                        _apellidoController.text,
                        _selectedEquipoId!,
                        equipoNombre,
                        _posicionController.text,
                        numeroCamiseta,
                        _isLesionado,
                      );
                    } else {
                      appData.editJugador(
                        jugador.id,
                        _nombreController.text,
                        _apellidoController.text,
                        _selectedEquipoId!,
                        equipoNombre,
                        _posicionController.text,
                        numeroCamiseta,
                        _isLesionado,
                      );
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Función para mostrar el diálogo de confirmación de eliminación
  void _confirmDelete(BuildContext context, Jugador jugador) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar a "${jugador.nombre} ${jugador.apellido}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Provider.of<AppData>(context, listen: false).deleteJugador(jugador.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Jugador "${jugador.nombre} ${jugador.apellido}" eliminado.')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Jugadores'),
        centerTitle: true,
      ),
      body: Consumer<AppData>(
        builder: (context, appData, child) {
          if (appData.jugadores.isEmpty) {
            return const Center(
              child: Text(
                'No hay jugadores registrados. ¡Añade uno!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: appData.jugadores.length,
            itemBuilder: (context, index) {
              final jugador = appData.jugadores[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${jugador.nombre} ${jugador.apellido} (#${jugador.numeroCamiseta})',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text('Equipo: ${jugador.equipoNombre}'),
                      Text('Posición: ${jugador.posicion}'),
                      Text('Lesionado: ${jugador.lesionado ? 'Sí' : 'No'}'),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatItem('Goles', jugador.goles),
                          _buildStatItem('Asistencias', jugador.asistencias),
                          _buildStatItem('TA', jugador.tarjetasAmarillas),
                          _buildStatItem('TR', jugador.tarjetasRojas),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showJugadorDialog(jugador: jugador),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(context, jugador),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showJugadorDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget auxiliar para mostrar una estadística individual
  Widget _buildStatItem(String label, int value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(value.toString(), style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
