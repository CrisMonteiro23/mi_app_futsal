import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:excel/excel.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import '../models/situacion.dart';
import '../providers/app_data.dart';

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final tipoStats = appData.getSituacionTypeStats();
    final totalStats = appData.getTotalesReales();

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Totales', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Text('A favor: ${totalStats['favor']}'),
              Text('En contra: ${totalStats['contra']}'),
              Text('Total: ${totalStats['total']}'),
              const SizedBox(height: 20),
              Text('Situaciones por tipo', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              _buildSituacionTable(tipoStats),
              const SizedBox(height: 20),
              Text('Gráfico de situaciones', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              _buildBarChart(tipoStats),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Exportar a Excel'),
                onPressed: () => _exportarExcel(tipoStats),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSituacionTable(Map<String, Map<String, int>> stats) {
    return Table(
      border: TableBorder.all(),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1.5),
      },
      children: [
        const TableRow(children: [
          Padding(padding: EdgeInsets.all(8.0), child: Text('Tipo')),
          Padding(padding: EdgeInsets.all(8.0), child: Text('A favor')),
          Padding(padding: EdgeInsets.all(8.0), child: Text('En contra')),
        ]),
        for (var entry in stats.entries)
          TableRow(children: [
            Padding(padding: const EdgeInsets.all(8.0), child: Text(entry.key)),
            Padding(padding: const EdgeInsets.all(8.0), child: Text(entry.value['favor'].toString())),
            Padding(padding: const EdgeInsets.all(8.0), child: Text(entry.value['contra'].toString())),
          ])
      ],
    );
  }

  Widget _buildBarChart(Map<String, Map<String, int>> data) {
    final keys = data.keys.toList();
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: List.generate(keys.length, (i) {
            final tipo = keys[i];
            final total = (data[tipo]?['favor'] ?? 0) + (data[tipo]?['contra'] ?? 0);
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: total.toDouble(), color: Colors.blue, width: 18),
            ]);
          }),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(keys[value.toInt()], style: const TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }

  void _exportarExcel(Map<String, Map<String, int>> stats) {
    final excel = Excel.createExcel();
    final sheet = excel['Estadísticas'];
    sheet.appendRow(['Tipo', 'A favor', 'En contra']);

    for (var entry in stats.entries) {
      sheet.appendRow([
        entry.key,
        entry.value['favor'],
        entry.value['contra'],
      ]);
    }

    final bytes = excel.encode();
    final blob = html.Blob([Uint8List.fromList(bytes!)]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "estadisticas.xlsx")
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
