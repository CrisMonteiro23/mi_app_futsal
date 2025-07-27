// lib/screens/estadisticas_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_app_futsal/data/app_data.dart';
import 'package:mi_app_futsal/models/jugador.dart';
import 'package:mi_app_futsal/models/situacion.dart';
import 'package:csv/csv.dart'; // Para exportar a CSV
import 'package:flutter/services.dart'; // Para copiar al portapapeles
import 'package:url_launcher/url_launcher.dart'; // Para abrir enlaces (útil para CSV)

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Dos pestañas: Jugadores y Tipos de Situación
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Estadísticas de Análisis'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Por Jugador', icon: Icon(Icons.person)),
              Tab(text: 'Por Tipo de Situación', icon: Icon(Icons.category)),
            ],
          ),
        ),
        body: Consumer<AppData>(
          builder: (context, appData, child) {
            final playerStats = appData.getPlayerStats();
            final situacionTypeStats = appData.getSituacionTypeStats();
            final allSituations = appData.situacionesRegistradas;

            return TabBarView(
              children: [
                // Pestaña 1: Estadísticas por Jugador
                _buildPlayerStatsTable(context, playerStats, appData.jugadoresDisponibles),
                // Pestaña 2: Estadísticas por Tipo de Situación
                _buildSituationTypeStatsTable(context, situacionTypeStats),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _exportDataToCsv(context, Provider.of<AppData>(context, listen: false)),
          label: const Text('Exportar a CSV'),
          icon: const Icon(Icons.download),
        ),
      ),
    );
  }

  // --- Widgets para Tablas de Estadísticas ---

  Widget _buildPlayerStatsTable(BuildContext context, Map<String, Map<String, int>> stats, List<Jugador> jugadores) {
    if (stats.isEmpty || jugadores.isEmpty) {
      return const Center(
        child: Text(
          'No hay datos de jugadores para mostrar estadísticas.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Ordenar jugadores alfabéticamente por nombre
    jugadores.sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DataTable(
          columnSpacing: 16,
          dataRowHeight: 50,
          headingRowColor: MaterialStateProperty.all(Colors.blue.shade100),
          columns: const [
            DataColumn(label: Text('Jugador', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('A Favor', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            DataColumn(label: Text('En Contra', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
          ],
          rows: jugadores.map((jugador) {
            final playerStat = stats[jugador.id] ?? {'favor': 0, 'contra': 0};
            final favor = playerStat['favor']!;
            final contra = playerStat['contra']!;
            final total = favor + contra;
            return DataRow(
              cells: [
                DataCell(Text(jugador.nombre)),
                DataCell(Text(favor.toString(), textAlign: TextAlign.center)),
                DataCell(Text(contra.toString(), textAlign: TextAlign.center)),
                DataCell(Text(total.toString(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSituationTypeStatsTable(BuildContext context, Map<String, Map<String, int>> stats) {
    if (stats.isEmpty) {
      return const Center(
        child: Text(
          'No hay datos de tipos de situación para mostrar estadísticas.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Convertir el mapa a una lista de entradas para poder ordenarlas
    final List<MapEntry<String, Map<String, int>>> sortedStats = stats.entries.toList();
    sortedStats.sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase())); // Ordenar por nombre de tipo

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DataTable(
          columnSpacing: 16,
          dataRowHeight: 50,
          headingRowColor: MaterialStateProperty.all(Colors.blue.shade100),
          columns: const [
            DataColumn(label: Text('Tipo de Llegada', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('A Favor', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            DataColumn(label: Text('En Contra', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
          ],
          rows: sortedStats.map((entry) {
            final tipo = entry.key;
            final typeStat = entry.value;
            final favor = typeStat['favor']!;
            final contra = typeStat['contra']!;
            final total = favor + contra;
            return DataRow(
              cells: [
                DataCell(Text(tipo)),
                DataCell(Text(favor.toString(), textAlign: TextAlign.center)),
                DataCell(Text(contra.toString(), textAlign: TextAlign.center)),
                DataCell(Text(total.toString(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // --- Funcionalidad de Exportación a CSV ---

  void _exportDataToCsv(BuildContext context, AppData appData) async {
    final List<List<dynamic>> rawData = [];

    // Encabezados para los datos crudos
    rawData.add([
      'ID Situacion',
      'Fecha y Hora',
      'Es A Favor',
      'Tipo de Llegada',
      'Jugadores en Cancha (Nombres)',
      'Jugadores en Cancha (IDs)',
    ]);

    // Añadir cada situación registrada
    for (var situacion in appData.situacionesRegistradas) {
      rawData.add([
        situacion.id,
        situacion.timestamp.toIso8601String(),
        situacion.esAFavor ? 'Sí' : 'No',
        situacion.tipoLlegada,
        situacion.jugadoresEnCanchaNombres.join(', '), // Nombres separados por coma
        situacion.jugadoresEnCanchaIds.join(', '), // IDs separados por coma
      ]);
    }

    // Convertir la lista de listas a formato CSV
    final String csv = const ListToCsvConverter().convert(rawData);

    // --- Opciones de Exportación ---
    // 1. Copiar al portapapeles
    await Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Datos crudos copiados al portapapeles. Pégalos en Excel.'),
        duration: Duration(seconds: 3),
      ),
    );

    // 2. Descargar como archivo (solo funciona en web o si se implementa lógica de guardado de archivos en móvil/desktop)
    // Para web, podemos crear un "data URI" y abrirlo en una nueva pestaña para que el navegador lo descargue.
    if (Theme.of(context).platform == TargetPlatform.android || Theme.of(context).platform == TargetPlatform.iOS) {
      // En móvil, necesitarías un paquete como path_provider y file_picker
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La descarga directa de archivos en móvil requiere permisos adicionales. Datos copiados al portapapeles.'),
          duration: Duration(seconds: 5),
        ),
      );
    } else { // Para web, desktop
      final Uri dataUri = Uri.dataFromString(
        csv,
        mimeType: 'text/csv',
        encoding: SystemEncoding(), // Usa la codificación del sistema
        headers: {
          'Content-Disposition': 'attachment; filename=futsal_data.csv',
        },
      );
      // Abrir en una nueva pestaña para forzar la descarga
      if (await canLaunchUrl(dataUri)) {
        await launchUrl(dataUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo iniciar la descarga del archivo CSV.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }

    // NOTA sobre gráficos en Excel:
    // La generación de gráficos directamente en un archivo Excel (.xlsx) desde una aplicación Flutter
    // es una funcionalidad muy compleja que generalmente requiere librerías de backend o servicios especializados.
    // Esta implementación exporta los datos crudos en formato CSV, que es fácilmente importable en Excel.
    // Una vez en Excel, puedes usar las herramientas de Excel para crear los gráficos deseados.
  }
}
