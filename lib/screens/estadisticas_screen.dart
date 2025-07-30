import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mi_app_futsal/providers/app_data.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'dart:html' as html;

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final tipoStats = appData.getSituacionTypeStats();
    final resumen = appData.getTotalesReales();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Exportar a Excel',
            onPressed: () => _exportToCsv(appData),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildBarChart(tipoStats),
            const SizedBox(height: 20),
            _buildResumenTable(tipoStats),
            const SizedBox(height: 20),
            Text('Total a favor: ${resumen['favor']}  |  Total en contra: ${resumen['contra']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, Map<String, int>> stats) {
    final tipos = stats.keys.toList();
    final favor = tipos.map((t) => stats[t]!['favor']!.toDouble()).toList();
    final contra = tipos.map((t) => stats[t]!['contra']!.toDouble()).toList();

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (favor + contra).fold<double>(0, (prev, e) => e > prev ? e : prev) + 2,
          barGroups: List.generate(tipos.length, (i) {
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: favor[i], color: Colors.green),
              BarChartRodData(toY: contra[i], color: Colors.red),
            ]);
          }),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    tipos[value.toInt()].length > 6
                        ? tipos[value.toInt()].substring(0, 6) + '...'
                        : tipos[value.toInt()],
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResumenTable(Map<String, Map<String, int>> stats) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Tipo')), 
        DataColumn(label: Text('A Favor')), 
        DataColumn(label: Text('En Contra')),
      ],
      rows: stats.entries.map((entry) {
        return DataRow(cells: [
          DataCell(Text(entry.key)),
          DataCell(Text(entry.value['favor'].toString())),
          DataCell(Text(entry.value['contra'].toString())),
        ]);
      }).toList(),
    );
  }

  void _exportToCsv(AppData appData) {
    final List<List<String>> csvData = [
      ['ID', 'Timestamp', 'Tipo Llegada', 'Es a Favor', 'Jugadores'],
      ...appData.situacionesRegistradas.map((s) => [
        s.id,
        DateFormat('yyyy-MM-dd HH:mm').format(s.timestamp),
        s.tipoLlegada,
        s.esAFavor ? 'Sí' : 'No',
        s.jugadoresEnCanchaNombres.join(', '),
      ])
    ];

    final csv = const ListToCsvConverter().convert(csvData);
    final blob = html.Blob([csv], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "estadisticas.csv")
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
