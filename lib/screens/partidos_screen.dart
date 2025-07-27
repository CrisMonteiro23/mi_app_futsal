import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_app_futsal/data/app_data.dart';
import 'package:mi_app_futsal/models/partido.dart';
import 'package:mi_app_futsal/models/equipo.dart'; // Necesario para obtener la lista de equipos
import 'package:intl/intl.dart'; // Para formatear fechas y horas

class PartidosScreen extends StatefulWidget {
  const PartidosScreen({super.key});

  @override
  State<PartidosScreen> createState() => _PartidosScreenState();
}

class _PartidosScreenState extends State<PartidosScreen> {
  // Controladores para los campos de texto del formulario
  final TextEditingController _canchaController = TextEditingController();
  final TextEditingController _arbitroController = TextEditingController();
  final TextEditingController _golesLocalController = TextEditingController();
  final TextEditingController _golesVisitanteController = TextEditingController();

  // Variables para la selección de fecha y hora
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  Equipo? _selectedEquipoLocal;
  Equipo? _selectedEquipoVisitante;

  @override
  void dispose() {
    _canchaController.dispose();
    _arbitroController.dispose();
    _golesLocalController.dispose();
    _golesVisitanteController.dispose();
    super.dispose();
  }

  // Función para seleccionar la fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Función para seleccionar la hora
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Función para mostrar el diálogo de añadir partido
  void _showAddPartidoDialog() {
    final appData = Provider.of<AppData>(context, listen: false);
    final List<Equipo> equiposDisponibles = appData.equipos;

    if (equiposDisponibles.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Necesitas al menos dos equipos para programar un partido.')),
      );
      return;
    }

    // Reiniciar valores para el nuevo partido
    _canchaController.clear();
    _arbitroController.clear();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _selectedEquipoLocal = null; // Reiniciar selección
    _selectedEquipoVisitante = null; // Reiniciar selección

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: const Text('Programar Nuevo Partido'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Selector de fecha
                    ListTile(
                      title: Text('Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null && picked != _selectedDate) {
                          setStateInDialog(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                    ),
                    // Selector de hora
                    ListTile(
                      title: Text('Hora: ${_selectedTime.format(context)}'),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (picked != null && picked != _selectedTime) {
                          setStateInDialog(() {
                            _selectedTime = picked;
                          });
                        }
                      },
                    ),
                    // Dropdown para Equipo Local
                    DropdownButtonFormField<Equipo>(
                      decoration: const InputDecoration(labelText: 'Equipo Local'),
                      value: _selectedEquipoLocal,
                      items: equiposDisponibles.map((Equipo equipo) {
                        return DropdownMenuItem<Equipo>(
                          value: equipo,
                          child: Text(equipo.nombre),
                        );
                      }).toList(),
                      onChanged: (Equipo? newValue) {
                        setStateInDialog(() {
                          _selectedEquipoLocal = newValue;
                        });
                      },
                      isExpanded: true,
                    ),
                    // Dropdown para Equipo Visitante
                    DropdownButtonFormField<Equipo>(
                      decoration: const InputDecoration(labelText: 'Equipo Visitante'),
                      value: _selectedEquipoVisitante,
                      items: equiposDisponibles.map((Equipo equipo) {
                        return DropdownMenuItem<Equipo>(
                          value: equipo,
                          child: Text(equipo.nombre),
                        );
                      }).toList(),
                      onChanged: (Equipo? newValue) {
                        setStateInDialog(() {
                          _selectedEquipoVisitante = newValue;
                        });
                      },
                      isExpanded: true,
                    ),
                    TextField(
                      controller: _canchaController,
                      decoration: const InputDecoration(labelText: 'Cancha'),
                    ),
                    TextField(
                      controller: _arbitroController,
                      decoration: const InputDecoration(labelText: 'Árbitro'),
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
                  child: const Text('Programar'),
                  onPressed: () {
                    if (_selectedEquipoLocal == null ||
                        _selectedEquipoVisitante == null ||
                        _canchaController.text.isEmpty ||
                        _arbitroController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, completa todos los campos obligatorios.')),
                      );
                      return;
                    }
                    if (_selectedEquipoLocal!.id == _selectedEquipoVisitante!.id) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Los equipos local y visitante no pueden ser el mismo.')),
                      );
                      return;
                    }

                    // Combina fecha y hora seleccionadas
                    final DateTime partidoDateTime = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      _selectedTime.hour,
                      _selectedTime.minute,
                    );

                    appData.addPartido(
                      partidoDateTime,
                      _selectedTime.format(context), // Guarda la hora formateada
                      _selectedEquipoLocal!,
                      _selectedEquipoVisitante!,
                      _canchaController.text,
                      _arbitroController.text,
                    );
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

  // Función para mostrar el diálogo de registro de resultado
  void _showRegistrarResultadoDialog(Partido partido) {
    _golesLocalController.text = partido.golesLocal.toString();
    _golesVisitanteController.text = partido.golesVisitante.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Registrar Resultado: ${partido.equipoLocalNombre} vs ${partido.equipoVisitanteNombre}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _golesLocalController,
                decoration: InputDecoration(labelText: 'Goles ${partido.equipoLocalNombre}'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _golesVisitanteController,
                decoration: InputDecoration(labelText: 'Goles ${partido.equipoVisitanteNombre}'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Guardar Resultado'),
              onPressed: () {
                final int? golesLocal = int.tryParse(_golesLocalController.text);
                final int? golesVisitante = int.tryParse(_golesVisitanteController.text);

                if (golesLocal == null || golesVisitante == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, introduce un número válido de goles.')),
                  );
                  return;
                }

                Provider.of<AppData>(context, listen: false).registrarResultadoPartido(
                  partido.id,
                  golesLocal,
                  golesVisitante,
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Resultado registrado y estadísticas actualizadas.')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Función para mostrar el diálogo de confirmación de eliminación
  void _confirmDelete(BuildContext context, Partido partido) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar este partido: ${partido.equipoLocalNombre} vs ${partido.equipoVisitanteNombre}?'),
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
                Provider.of<AppData>(context, listen: false).deletePartido(partido.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Partido eliminado.')),
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
        title: const Text('Gestionar Partidos'),
        centerTitle: true,
      ),
      body: Consumer<AppData>(
        builder: (context, appData, child) {
          if (appData.partidos.isEmpty) {
            return const Center(
              child: Text(
                'No hay partidos programados. ¡Añade uno!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: appData.partidos.length,
            itemBuilder: (context, index) {
              final partido = appData.partidos[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${DateFormat('dd/MM/yyyy').format(partido.fecha)} - ${partido.hora}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text('Cancha: ${partido.cancha}'),
                      Text('Árbitro: ${partido.arbitro}'),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              partido.equipoLocalNombre,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              '${partido.golesLocal} - ${partido.golesVisitante}',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              partido.equipoVisitanteNombre,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Chip(
                          label: Text(partido.estado),
                          backgroundColor: partido.estado == 'Jugado' ? Colors.green.shade100 : Colors.orange.shade100,
                          labelStyle: TextStyle(color: partido.estado == 'Jugado' ? Colors.green.shade800 : Colors.orange.shade800),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          // Botón para registrar resultado (solo si el partido no ha sido jugado)
                          if (partido.estado == 'Programado')
                            IconButton(
                              icon: const Icon(Icons.score, color: Colors.green),
                              tooltip: 'Registrar Resultado',
                              onPressed: () => _showRegistrarResultadoDialog(partido),
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(context, partido),
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
        onPressed: () => _showAddPartidoDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
