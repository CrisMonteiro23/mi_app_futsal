import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_app_futsal/data/app_data.dart';
import 'package:mi_app_futsal/models/jugador.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Estadísticas de Análisis'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Por Jugador', icon: Icon(Icons.person)),
              Tab(text: 'Por Tipo de Situación', icon: Icon(Icons.category)),
              Tab(text: 'Gráficos', icon: Icon(Icons.bar_chart)),
            ],
          ),
        ),
        body: Consumer<AppData>(
          builder: (context, appData, child) {
            final playerStats = appData.getPlayerStats();
            final situacionTypeStats = appData.getSituacionTypeStats();

            return TabBarView(
              children: [
                _buildPlayerStatsTable(context, playerStats, appData.jugadoresDisponibles),
                _buildSituationTypeStatsTable(context, situacionTypeStats),
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

    int totalFavorJugadores = 0;
    int totalContraJugadores = 0;
    for (var jugador in jugadoresConDatos) {
      final playerStat = stats[jugador.id]!;
      totalFavorJugadores += playerStat['favor']!;
      totalContraJugadores += playerStat['contra']!;
    }
    final int totalGeneralJugadores = totalFavorJugadores + totalContraJugadores;
    final totalesReales = Provider.of<AppData>(context, listen: false).getTotalesReales();

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
            DataColumn(label: Text('A Favor', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('En Contra', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: [
            ...jugadoresConDatos.map((jugador) {
              final playerStat = stats[jugador.id] ?? {'favor': 0, 'contra': 0};
              final favor = playerStat['favor']!;
              final contra = playerStat['contra']!;
              final total = favor + contra;
              return DataRow(
                cells: [
                  DataCell(Text(jugador.nombre)),
                  DataCell(Text(favor.toString())),
                  DataCell(Text(contra.toString())),
                  DataCell(Text(total.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                ],
              );
            }).toList(),
            DataRow(
              color: MaterialStateProperty.all(Colors.blue.shade50),
              cells: [
                const DataCell(Text('TOTAL GENERAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                DataCell(Text(totalFavorJugadores.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green))),
                DataCell(Text(totalContraJugadores.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red))),
                DataCell(Text(totalGeneralJugadores.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent))),
              ],
            ),
            DataRow(
              color: MaterialStateProperty.all(Colors.yellow.shade100),
              cells: [
                const DataCell(Text('TOTAL REAL (sin duplicados)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                DataCell(Text(totalesReales['favor'].toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(totalesReales['contra'].toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(totalesReales['total'].toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ],
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
            DataColumn(label: Text('A Favor', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('En Contra', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
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
                DataCell(Text(favor.toString())),
                DataCell(Text(contra.toString())),
                DataCell(Text(total.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

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

    if (jugadoresConDatos.isEmpty && situacionStatsConDatos.isEmpty) {
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
              height: 300,
              child: BarChart(
                BarChartData(
                  barGroups: jugadoresConDatos.map((jugador) {
                    final playerStat = playerStats[jugador.id]!;
                    final favor = playerStat['favor']!.toDouble();
                    final contra = playerStat['contra']!.toDouble();

                    return BarChartGroupData(
                      x: jugadoresConDatos.indexOf(jugador),
                      barRods: [
                        BarChartRodData(
                          toY: favor,
                          color: Colors.green,
                          width: 10,
                        ),
                        BarChartRodData(
                          toY: contra,
                          color: Colors.red,
                          width: 10,
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
                        final label = rodIndex == 0 ? 'Favor' : 'Contra';
                        return BarTooltipItem('$label: ${rod.toY.toInt()}', const TextStyle(color: Colors.white));
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (situacionStatsConDatos.isNotEmpty) ...[
            const SizedBox(height: 40),
            const Text(
              'Llegadas por Tipo de Situación',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
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
                        BarChartRodData(toY: favor, color: Colors.green, width: 10),
                        BarChartRodData(toY: contra, color: Colors.red, width: 10),
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
                        final label = rodIndex == 0 ? 'Favor' : 'Contra';
                        return BarTooltipItem('$label: ${rod.toY.toInt()}', const TextStyle(color: Colors.white));
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

  void _exportDataToCsv(BuildContext context, AppData appData) async {
    final List<List<dynamic>> rawData = [];

    rawData.add([
      'ID Situacion',
      'Fecha y Hora',
      'Es A Favor',
      'Tipo de Llegada',
      'Jugadores en Cancha (Nombres)',
      'Jugadores en Cancha (IDs)',
    ]);

    for (var situacion in appData.situacionesRegistradas) {
      rawData.add([
        situacion.id,
        situacion.timestamp.toIso8601String(),
        situacion.esAFavor ? 'Sí' : 'No',
        situacion.tipoLlegada,
        situacion.jugadoresEnCanchaNombres.join(', '),
        situacion.jugadoresEnCanchaIds.join(', '),
      ]);
    }

    final String csv = const ListToCsvConverter().convert(rawData);

    await Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Datos crudos copiados al portapapeles. Pégalos en Excel.'),
        duration: Duration(seconds: 3),
      ),
    );

    if (Theme.of(context).platform != TargetPlatform.android && Theme.of(context).platform != TargetPlatform.iOS) {
      final Uri dataUri = Uri.dataFromString(
        csv,
        mimeType: 'text/csv',
        encoding: utf8,
      );
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
  }
}
