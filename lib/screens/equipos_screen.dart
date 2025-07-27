// lib/screens/equipos_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_app_futsal/data/app_data.dart';
import 'package:mi_app_futsal/models/equipo.dart';

class EquiposScreen extends StatefulWidget {
  const EquiposScreen({super.key});

  @override
  State<EquiposScreen> createState() => _EquiposScreenState();
}

class _EquiposScreenState extends State<EquiposScreen> {
  // Controladores para los campos de texto del formulario de añadir/editar
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _entrenadorController = TextEditingController();
  final TextEditingController _coloresController = TextEditingController();

  // Función para mostrar el diálogo de añadir o editar equipo
  void _showEquipoDialog({Equipo? equipo}) {
    // Si se pasa un equipo, estamos en modo edición, precargamos los datos
    if (equipo != null) {
      _nombreController.text = equipo.nombre;
      _entrenadorController.text = equipo.entrenador;
      _coloresController.text = equipo.colores;
    } else {
      // Si no se pasa equipo, estamos en modo añadir, limpiamos los campos
      _nombreController.clear();
      _entrenadorController.clear();
      _coloresController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(equipo == null ? 'Añadir Nuevo Equipo' : 'Editar Equipo'),
          content: SingleChildScrollView( // Permite desplazamiento si el contenido es largo
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ajusta el tamaño de la columna al contenido
              children: <Widget>[
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre del Equipo'),
                ),
                TextField(
                  controller: _entrenadorController,
                  decoration: const InputDecoration(labelText: 'Entrenador'),
                ),
                TextField(
                  controller: _coloresController,
                  decoration: const InputDecoration(labelText: 'Colores'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
            ElevatedButton(
              child: Text(equipo == null ? 'Añadir' : 'Guardar'),
              onPressed: () {
                // Obtiene la instancia de AppData para modificar los datos
                final appData = Provider.of<AppData>(context, listen: false);
                if (equipo == null) {
                  // Lógica para añadir nuevo equipo
                  if (_nombreController.text.isNotEmpty) {
                    // Verifica si el nombre del equipo ya existe
                    if (appData.equipos.any((e) => e.nombre.toLowerCase() == _nombreController.text.toLowerCase())) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ya existe un equipo con este nombre.')),
                      );
                      return; // No añade el equipo si ya existe
                    }
                    appData.addEquipo(
                      _nombreController.text,
                      _entrenadorController.text,
                      _coloresController.text,
                    );
                  }
                } else {
                  // Lógica para editar equipo existente
                  if (_nombreController.text.isNotEmpty) {
                    // Verifica si el nuevo nombre ya existe y no es el mismo equipo que estamos editando
                    if (appData.equipos.any((e) => e.nombre.toLowerCase() == _nombreController.text.toLowerCase() && e.id != equipo.id)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ya existe otro equipo con este nombre.')),
                      );
                      return;
                    }
                    appData.editEquipo(
                      equipo.id,
                      _nombreController.text,
                      _entrenadorController.text,
                      _coloresController.text,
                    );
                  }
                }
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
          ],
        );
      },
    );
  }

  // Función para mostrar el diálogo de confirmación de eliminación
  void _confirmDelete(BuildContext context, Equipo equipo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar el equipo "${equipo.nombre}"? Esto también eliminará a sus jugadores y partidos asociados.'),
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
                Provider.of<AppData>(context, listen: false).deleteEquipo(equipo.id);
                Navigator.of(context).pop(); // Cierra el diálogo de confirmación
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Equipo "${equipo.nombre}" eliminado.')),
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
    // Consumer es un widget de Provider que reconstruye su parte de la interfaz
    // cuando los datos de AppData cambian.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Equipos'),
        centerTitle: true,
      ),
      body: Consumer<AppData>(
        builder: (context, appData, child) {
          // Si no hay equipos, muestra un mensaje
          if (appData.equipos.isEmpty) {
            return const Center(
              child: Text(
                'No hay equipos registrados. ¡Añade uno!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }
          // Si hay equipos, los muestra en una lista
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: appData.equipos.length,
            itemBuilder: (context, index) {
              final equipo = appData.equipos[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipo.nombre,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text('Entrenador: ${equipo.entrenador}'),
                      Text('Colores: ${equipo.colores}'),
                      const SizedBox(height: 10),
                      // Mostrar estadísticas del equipo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatItem('PJ', equipo.pj),
                          _buildStatItem('PG', equipo.pg),
                          _buildStatItem('PE', equipo.pe),
                          _buildStatItem('PP', equipo.pp),
                          _buildStatItem('GF', equipo.gf),
                          _buildStatItem('GC', equipo.gc),
                          _buildStatItem('DG', equipo.dg),
                          _buildStatItem('Puntos', equipo.puntos, isBold: true),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Botones de acción para cada equipo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEquipoDialog(equipo: equipo), // Llama al diálogo en modo edición
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(context, equipo), // Llama al diálogo de confirmación de eliminación
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
      // Botón flotante para añadir un nuevo equipo
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEquipoDialog(), // Llama al diálogo en modo añadir
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget auxiliar para mostrar una estadística individual
  Widget _buildStatItem(String label, int value, {bool isBold = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
        ),
        Text(
          value.toString(),
          style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }
}
