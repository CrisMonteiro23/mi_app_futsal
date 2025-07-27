// lib/screens/estadisticas_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_app_futsal/data/app_data.dart';
import 'package:mi_app_futsal/models/equipo.dart';
import 'package:mi_app_futsal/models/jugador.dart';
import 'package:intl/intl.dart'; // Asegúrate de que esta importación esté aquí

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController( // Permite tener pestañas
      length: 3, // Número de pestañas: Tabla de Posiciones, Goleadores, Asistencias
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Estadísticas de Liga'),
          centerTitle: true,
          bottom: const TabBar( // Pestañas en la parte inferior del AppBar
            tabs: [
              Tab(text: 'Tabla de Posiciones', icon: Icon(Icons.table_chart)),
              Tab(text: 'Máximos Goleadores', icon: Icon(Icons.sports_soccer)),
              Tab(text: 'Máximos Asistentes', icon: Icon(Icons.sports)),
            ],
          ),
        ),
        body: Consumer<AppData>(
          builder: (context, appData, child) {
            // Ordena los equipos por puntos para la tabla de posiciones
            final List<Equipo> equiposOrdenados = List.from(appData.equipos);
            equiposOrdenados.sort((a, b) => b.puntos.compareTo(a.puntos));

            // Ordena jugadores por goles para máximos goleadores
            final List<Jugador> goleadores = List.from(appData.jugadores);
            goleadores.sort((a, b) => b.goles.compareTo(a.goles));

            // Ordena jugadores por asistencias para máximos asistentes
            final List<Jugador> asistentes = List.from(appData.jugadores);
            asistentes.sort((a, b) => b.asistencias.compareTo(a.asistencias));

            return TabBarView(
              children: [
                // Pestaña 1: Tabla de Posiciones
                _buildTablaPosiciones(equiposOrdenados),
                // Pestaña 2: Máximos Goleadores
                _buildJugadorStatsList(goleadores, 'Goles'),
                // Pestaña 3: Máximos Asistentes
                _buildJugadorStatsList(asistentes, 'Asistencias'),
              ],
            );
          },
        ),
      ),
    );
  }

  // Widget para construir la tabla de posiciones
  Widget _buildTablaPosiciones(List<Equipo> equipos) {
    if (equipos.isEmpty) {
      return const Center(
        child: Text(
          'No hay equipos para mostrar la tabla de posiciones.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Permite desplazamiento horizontal para la tabla
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DataTable(
          columnSpacing: 12, // Espacio entre columnas
          dataRowHeight: 50, // Altura de las filas de datos
          headingRowColor: MaterialStateProperty.all(Colors.blue.shade100), // Color de la cabecera
          columns: const [
            DataColumn(label: Text('Equipo', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('PJ', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            DataColumn(label: Text('PG', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            DataColumn(label: Text('PE', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            DataColumn(label: Text('PP', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            DataColumn(label: Text('GF', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            DataColumn(label: Text('GC', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            DataColumn(label: Text('DG', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            DataColumn(label: Text('Puntos', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
          ],
          rows: equipos.map((equipo) {
            return DataRow(
              cells: [
                DataCell(Text(equipo.nombre)),
                DataCell(Text(equipo.pj.toString(), textAlign: TextAlign.center)),
                DataCell(Text(equipo.pg.toString(), textAlign: TextAlign.center)),
                DataCell(Text(equipo.pe.toString(), textAlign: TextAlign.center)),
                DataCell(Text(equipo.pp.toString(), textAlign: TextAlign.center)),
                DataCell(Text(equipo.gf.toString(), textAlign: TextAlign.center)),
                DataCell(Text(equipo.gc.toString(), textAlign: TextAlign.center)),
                DataCell(Text(equipo.dg.toString(), textAlign: TextAlign.center)),
                DataCell(Text(equipo.puntos.toString(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // Widget para construir listas de estadísticas de jugadores (goleadores/asistentes)
  Widget _buildJugadorStatsList(List<Jugador> jugadores, String statType) {
    if (jugadores.isEmpty || (statType == 'Goles' && jugadores.every((j) => j.goles == 0)) || (statType == 'Asistencias' && jugadores.every((j) => j.asistencias == 0))) {
      return Center(
        child: Text(
          'No hay ${statType.toLowerCase()} para mostrar.',
          style: const TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: jugadores.length,
      itemBuilder: (context, index) {
        final jugador = jugadores[index];
        int statValue = 0;
        if (statType == 'Goles') {
          statValue = jugador.goles;
        } else if (statType == 'Asistencias') {
          statValue = jugador.asistencias;
        }

        // No mostrar jugadores con 0 en la estadística si no es el primer elemento
        if (statValue == 0 && index > 0) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text(
                '${index + 1}', // Posición en el ranking
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              '${jugador.nombre} ${jugador.apellido}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Equipo: ${jugador.equipoNombre} - Posición: ${jugador.posicion}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  statValue.toString(),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                Text(statType),
              ],
            ),
          ),
        );
      },
    );
  }
}
