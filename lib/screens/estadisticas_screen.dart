import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_data.dart';
import '../models/jugador.dart';
import '../widgets/barras_comparativas.dart';

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final jugadores = appData.jugadores;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Estadísticas"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Por Jugador"),
              Tab(text: "Gráficos"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPlayerStatsTable(jugadores, appData),
            _buildCharts(appData),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerStatsTable(List<Jugador> jugadores, AppData appData) {
    final situaciones = appData.situacionesRegistradas;

    final Map<int, Map<String, int>> stats = {};
    for (var jugador in jugadores) {
      stats[jugador.id] = {'favor': 0, 'contra': 0};
    }

    for (var situacion in situaciones) {
      for (var jugadorId in situacion.jugadorIds) {
        if (stats.containsKey(jugadorId)) {
          if (situacion.esAFavor) {
            stats[jugadorId]!['favor'] = stats[jugadorId]!['favor']! + 1;
          } else {
            stats[jugadorId]!['contra'] = stats[jugadorId]!['contra']! + 1;
          }
        }
      }
    }

    final jugadoresConDatos = jugadores.where((jugador) {
      final playerStat = stats[jugador.id]!;
      return playerStat['favor']! > 0 || playerStat['contra']! > 0;
    }).toList();

    final totalesReales = appData.getTotalesReales();
    final int balanceReal = totalesReales['favor']! - totalesReales['contra']!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      scrollDirection: Axis.vertical,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.lightBlue.shade100),
        columns: const [
          DataColumn(label: Text('Jugador')),
          DataColumn(label: Text('A Favor')),
          DataColumn(label: Text('En Contra')),
          DataColumn(label: Text('Total')),
          DataColumn(label: Text('Balance')),
        ],
        rows: [
          ...jugadoresConDatos.map((jugador) {
            final playerStat = stats[jugador.id]!;
            final favor = playerStat['favor']!;
            final contra = playerStat['contra']!;
            final total = favor + contra;
            final balance = favor - contra;

            return DataRow(
              cells: [
                DataCell(Text(jugador.nombre)),
                DataCell(Text(favor.toString(), textAlign: TextAlign.center)),
                DataCell(Text(contra.toString(), textAlign: TextAlign.center)),
                DataCell(Text(
                  total.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
                DataCell(
                  Text(
                    balance.toString(),
                    style: TextStyle(
                      color: balance < 0 ? Colors.red : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
          // Fila de total real sin duplicados
          DataRow(
            color: MaterialStateProperty.all(Colors.yellow.shade100),
            cells: [
              const DataCell(Text('TOTAL REAL (sin duplicados)', style: TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(
                totalesReales['favor'].toString(),
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              )),
              DataCell(Text(
                totalesReales['contra'].toString(),
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              )),
              DataCell(Text(
                totalesReales['total'].toString(),
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              )),
              DataCell(Text(
                balanceReal.toString(),
                style: TextStyle(
                  color: balanceReal < 0 ? Colors.red : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCharts(AppData appData) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: BarrasComparativas(),
      ),
    );
  }
}
