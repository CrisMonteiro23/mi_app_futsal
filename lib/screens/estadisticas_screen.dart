// lib/screens/estadisticas_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_app_futsal/data/app_data.dart';
import 'package:mi_app_futsal/models/jugador.dart';
import 'package:mi_app_futsal/models/situacion.dart';
import 'package:csv/csv.dart'; // Para exportar a CSV
import 'package:flutter/services.dart'; // Para copiar al portapapeles
import 'package:url_launcher/url_launcher.dart'; // Para abrir enlaces (útil para CSV)
import 'dart:convert'; // Necesaria para usar utf8 encoding
import 'package:fl_chart/fl_chart.dart'; // ¡NUEVA IMPORTACIÓN PARA GRÁFICOS!

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // ¡Cambiado a 3 pestañas: Jugadores, Tipos de Situación, Gráficos!
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Estadísticas de Análisis'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Por Jugador', icon: Icon(Icons.person)),
              Tab(text: 'Por Tipo de Situación', icon: Icon(Icons.category)),
              Tab(text: 'Gráficos', icon: Icon(Icons.bar_chart)), // Nueva pestaña
            ],
          ),
        ),
        body: Consumer<AppData>(
          builder: (context, appData, child) {
            final playerStats = appData.getPlayerStats();
            final situacionTypeStats = appData.getSituacionTypeStats();

            return TabBarView(
              children: [
                // Pestaña 1: Estadísticas por Jugador (Tabla)
                _buildPlayerStatsTable(context, playerStats, appData.jugadoresDisponibles),
                // Pestaña 2: Estadísticas por Tipo de Situación (Tabla)
                _buildSituationTypeStatsTable(context, situacionTypeStats),
                // Pestaña 3: Gráficos
                _buildChartsView(context, playerStats, situacionTypeStats, appData.jugadoresDisponibles),
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

    final List<Jugador> jugadoresConDatos = jugadores.where((jugador) {
      final playerStat = stats[jugador.id];
      return playerStat != null && (playerStat['favor']! > 0 || playerStat['contra']! > 0);
    }).toList();

    if (jugadoresConDatos.isEmpty) {
      return const Center(
        child: Text(
          'No hay situaciones registradas para los jugadores.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    jugadoresConDatos.sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));

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
          rows: jugadoresConDatos.map((jugador) {
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

    final List<MapEntry<String, Map<String, int>>> sortedStats = stats.entries.toList();
    sortedStats.sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

    final List<MapEntry<String, Map<String, int>>> statsConDatos = sortedStats.where((entry) {
      final typeStat = entry.value;
      return typeStat['favor']! > 0 || typeStat['contra']! > 0;
    }).toList();

    if (statsConDatos.isEmpty) {
      return const Center(
        child: Text(
          'No hay situaciones registradas por tipo.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

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
          rows: statsConDatos.map((entry) {
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

  // --- Nueva Vista para Gráficos ---

  Widget _buildChartsView(BuildContext context, Map<String, Map<String, int>> playerStats, Map<String, Map<String, int>> situacionTypeStats, List<Jugador> jugadores) {
    final List<Jugador> jugadoresConDatos = jugadores.where((jugador) {
      final playerStat = playerStats[jugador.id];
      return playerStat != null && (playerStat['favor']! > 0 || playerStat['contra']! > 0);
    }).toList();
    jugadoresConDatos.sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));

    final List<MapEntry<String, Map<String, int>>> situacionStatsConDatos = situacionTypeStats.entries.where((entry) {
      final typeStat = entry.value;
      return typeStat['favor']! > 0 || typeStat['contra']! > 0;
    }).toList();
    situacionStatsConDatos.sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

    // Calcular el total de llegadas a favor y en contra para el tipo de situación
    int totalFavorSituacion = 0;
    int totalContraSituacion = 0;
    for (var entry in situacionTypeStats.entries) {
      totalFavorSituacion += entry.value['favor'] ?? 0;
      totalContraSituacion += entry.value['contra'] ?? 0;
    }

    if (jugadoresConDatos.isEmpty && situacionStatsConDatos.isEmpty && (totalFavorSituacion == 0 && totalContraSituacion == 0)) {
      return const Center(
        child: Text(
          'No hay datos suficientes para generar gráficos.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (jugadoresConDatos.isNotEmpty) ...[
            const Text(
              'Llegadas por Jugador',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300, // Altura fija para el gráfico
              child: BarChart(
                BarChartData(
                  barGroups: jugadoresConDatos.map((jugador) {
                    final playerStat = playerStats[jugador.id]!;
                    final favor = playerStat['favor']!.toDouble();
                    final contra = playerStat['contra']!.toDouble();
                    final total = favor + contra;

                    return BarChartGroupData(
                      x: jugadoresConDatos.indexOf(jugador),
                      barRods: [
                        BarChartRodData(
                          toY: favor,
                          color: Colors.green, // Color para "A Favor"
                          width: 10,
                          borderRadius: BorderRadius.zero,
                        ),
                        BarChartRodData(
                          toY: contra,
                          color: Colors.red, // Color para "En Contra"
                          width: 10,
                          borderRadius: BorderRadius.zero,
                        ),
                      ],
                      showingTooltipIndicators: [0, 1], // Muestra tooltips para ambas barras
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              jugadoresConDatos[value.toInt()].nombre,
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                        interval: 1,
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                        },
                        interval: 1, // Intervalo de 1 en el eje Y
                        reservedSize: 28,
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String label;
                        if (rodIndex == 0) {
                          label = 'Favor';
                        } else {
                          label = 'Contra';
                        }
                        return BarTooltipItem(
                          '$label: ${rod.toY.toInt()}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (jugadoresConDatos.isNotEmpty && situacionStatsConDatos.isNotEmpty)
            const SizedBox(height: 40), // Espacio entre gráficos

          if (situacionStatsConDatos.isNotEmpty || (totalFavorSituacion > 0 || totalContraSituacion > 0)) ...[
            const Text(
              'Llegadas por Tipo de Situación',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Nuevo: Total de llegadas a favor y en contra
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                children: [
                  Text(
                    'Total a Favor: $totalFavorSituacion',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  Text(
                    'Total en Contra: $totalContraSituacion',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  const SizedBox(height: 10),
                  // Opcional: Un pequeño gráfico de barras para los totales
                  SizedBox(
                    height: 100, // Altura para el gráfico de totales
                    child: BarChart(
                      BarChartData(
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(toY: totalFavorSituacion.toDouble(), color: Colors.green, width: 25, borderRadius: BorderRadius.circular(5)),
                            ],
                            showingTooltipIndicators: [0],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(toY: totalContraSituacion.toDouble(), color: Colors.red, width: 25, borderRadius: BorderRadius.circular(5)),
                            ],
                            showingTooltipIndicators: [0],
                          ),
                        ],
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                String text;
                                switch (value.toInt()) {
                                  case 0:
                                    text = 'Favor';
                                    break;
                                  case 1:
                                    text = 'Contra';
                                    break;
                                  default:
                                    text = '';
                                    break;
                                }
                                return Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold));
                              },
                              reservedSize: 20,
                              interval: 1,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                              },
                              interval: 1,
                              reservedSize: 28,
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            // CORRECCIÓN AQUÍ: Cambiado 'tooltipBgColor' a 'getTooltipColor'
                            getTooltipColor: (group) => Colors.blueGrey,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              String label;
                              switch (group.x.toInt()) {
                                case 0:
                                  label = 'Favor';
                                  break;
                                case 1:
                                  label = 'Contra';
                                  break;
                                default:
                                  label = '';
                                  break;
                              }
                              return BarTooltipItem(
                                '$label: ${rod.toY.toInt()}',
                                const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Gráfico por tipo de situación (el que ya existía)
            SizedBox(
              height: 300, // Altura fija para el gráfico
              child: BarChart(
                BarChartData(
                  barGroups: situacionStatsConDatos.asMap().entries.map((entry) {
                    int index = entry.key;
                    String tipo = entry.value.key;
                    Map<String, int> stats = entry.value.value;
                    final favor = stats['favor']!.toDouble();
                    final contra = stats['contra']!.toDouble();

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: favor,
                          color: Colors.green, // Color para "A Favor"
                          width: 10,
                          borderRadius: BorderRadius.zero,
                        ),
                        BarChartRodData(
                          toY: contra,
                          color: Colors.red, // Color para "En Contra"
                          width: 10,
                          borderRadius: BorderRadius.zero,
                        ),
                      ],
                      showingTooltipIndicators: [0, 1],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              situacionStatsConDatos[value.toInt()].key,
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                        interval: 1,
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                        },
                        interval: 1,
                        reservedSize: 28,
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String label;
                        if (rodIndex == 0) {
                          label = 'Favor';
                        } else {
                          label = 'Contra';
                        }
                        return BarTooltipItem(
                          '$label: ${rod.toY.toInt()}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
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
        encoding: utf8, // Usar utf8 de dart:convert
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
