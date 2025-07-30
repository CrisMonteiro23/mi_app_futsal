import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

import 'package:mi_app_futsal/data/app_data.dart';

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  Future<void> _exportToExcel(BuildContext context, Map<String, Map<String, int>> stats, Map<String, int> totales) async {
    final excel = Excel.createExcel();
    final sheet = excel['Resumen'];

    // Header fila
    sheet.appendRow(['Tipo Situación', 'A Favor', 'En Contra']);

    // Agregar cada tipo de situación y sus valores
    stats.forEach((tipo, valores) {
      sheet.appendRow([tipo, valores['favor'] ?? 0, valores['contra'] ?? 0]);
    });

    // Totales
    sheet.appendRow([]);
    sheet.appendRow(['Totales', totales['favor'] ?? 0, totales['contra'] ?? 0]);

    // Guardar archivo en almacenamiento temporal
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/estadisticas_futsal.xlsx';
    final fileBytes = excel.encode();

    if (fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al generar el archivo Excel')),
      );
      return;
    }

    final file = File(path);
    await file.writeAsBytes(fileBytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Archivo guardado en $path')),
    );

    // Compartir archivo
    await Share.shareFiles([path], text: 'Estadísticas de Futsal');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),
      body: Consumer<AppData>(
        builder: (context, appData, child) {
          final stats = appData.getSituacionTypeStats();
          final totales = appData.getTotalesReales();

          final tipos = stats.keys.toList();
          final favorValues = tipos.map((t) => stats[t]!['favor']!.toDouble()).toList();
          final contraValues = tipos.map((t) => stats[t]!['contra']!.toDouble()).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Conteo de situaciones por tipo', style: Theme.of(context).textTheme.headline6),

                const SizedBox(height: 12),

                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      barGroups: List.generate(tipos.length, (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(toY: favorValues[index], color: Colors.green),
                            BarChartRodData(toY: contraValues[index], color: Colors.red),
                          ],
                          barsSpace: 6,
                        );
                      }),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= tipos.length) return const SizedBox.shrink();
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(tipos[index], style: const TextStyle(fontSize: 10)),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, interval: 1),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(enabled: true),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Tipo Situación')),
                        DataColumn(label: Text('A Favor')),
                        DataColumn(label: Text('En Contra')),
                      ],
                      rows: [
                        ...tipos.map((tipo) {
                          final favor = stats[tipo]?['favor'] ?? 0;
                          final contra = stats[tipo]?['contra'] ?? 0;
                          return DataRow(cells: [
                            DataCell(Text(tipo)),
                            DataCell(Text(favor.toString())),
                            DataCell(Text(contra.toString())),
                          ]);
                        }),
                        DataRow(
                          cells: [
                            const DataCell(Text('Totales', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(totales['favor'].toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(totales['contra'].toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: () => _exportToExcel(context, stats, totales),
                  icon: const Icon(Icons.file_download),
                  label: const Text('Exportar a Excel'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
