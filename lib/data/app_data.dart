// lib/data/app_data.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // Para generar IDs únicos
import 'package:mi_app_futsal/models/jugador.dart';
import 'package:mi_app_futsal/models/situacion.dart';

class AppData extends ChangeNotifier {
  final Uuid _uuid = const Uuid();

  final List<Jugador> _jugadoresDisponibles = [
    Jugador(id: const Uuid().v4(), nombre: 'Victor'),
    Jugador(id: const Uuid().v4(), nombre: 'Fabio'),
    Jugador(id: const Uuid().v4(), nombre: 'Pablo'),
    Jugador(id: const Uuid().v4(), nombre: 'Nacho'),
    Jugador(id: const Uuid().v4(), nombre: 'Hugo'),
    Jugador(id: const Uuid().v4(), nombre: 'Carlos'),
    Jugador(id: const Uuid().v4(), nombre: 'Zequi'),
    Jugador(id: const Uuid().v4(), nombre: 'Arnaldo'),
    Jugador(id: const Uuid().v4(), nombre: 'Aranda'),
    Jugador(id: const Uuid().v4(), nombre: 'Enzo'),
    Jugador(id: const Uuid().v4(), nombre: 'Murilo'),
    Jugador(id: const Uuid().v4(), nombre: 'Titi'),
    Jugador(id: const Uuid().v4(), nombre: 'Pescio'),
    Jugador(id: const Uuid().v4(), nombre: 'Nicolas'),
  ];

  final List<Situacion> _situacionesRegistradas = [];

  List<Jugador> get jugadoresDisponibles => List.unmodifiable(_jugadoresDisponibles);
  List<Situacion> get situacionesRegistradas => List.unmodifiable(_situacionesRegistradas);

  void addJugador(String nombre) {
    if (nombre.trim().isEmpty) return;
    if (_jugadoresDisponibles.any((j) => j.nombre.toLowerCase() == nombre.toLowerCase())) return;

    _jugadoresDisponibles.add(Jugador(id: _uuid.v4(), nombre: nombre.trim()));
    notifyListeners();
  }

  void addSituacion(bool esAFavor, String tipoLlegada, List<Jugador> jugadoresEnCancha) {
    final situacion = Situacion(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      esAFavor: esAFavor,
      tipoLlegada: tipoLlegada,
      jugadoresEnCanchaIds: jugadoresEnCancha.map((j) => j.id).toList(),
      jugadoresEnCanchaNombres: jugadoresEnCancha.map((j) => j.nombre).toList(),
    );
    _situacionesRegistradas.add(situacion);
    notifyListeners();
  }

  void deleteSituacion(String id) {
    _situacionesRegistradas.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  // ✅ CORREGIDA: Estadísticas por jugador (sin duplicar llegadas para el total global)
  Map<String, Map<String, int>> getPlayerStats() {
    final Map<String, Map<String, int>> stats = {};

    for (var jugador in _jugadoresDisponibles) {
      stats[jugador.id] = {'favor': 0, 'contra': 0};
    }

    for (var situacion in _situacionesRegistradas) {
      for (var jugadorId in situacion.jugadoresEnCanchaIds) {
        if (!stats.containsKey(jugadorId)) {
          stats[jugadorId] = {'favor': 0, 'contra': 0};
        }

        if (situacion.esAFavor) {
          stats[jugadorId]!['favor'] = stats[jugadorId]!['favor']! + 1;
        } else {
          stats[jugadorId]!['contra'] = stats[jugadorId]!['contra']! + 1;
        }
      }
    }

    return stats;
  }

  // Estadísticas por tipo de situación (sin cambios)
  Map<String, Map<String, int>> getSituacionTypeStats() {
    final Map<String, Map<String, int>> stats = {};

    for (var tipo in [
      'Ataque Posicional', 'INC Portero', 'Transicion Corta',
      'Transicion Larga', 'ABP', '5x4', '4x5', 'Dobles-Penales'
    ]) {
      stats[tipo] = {'favor': 0, 'contra': 0};
    }

    for (var situacion in _situacionesRegistradas) {
      if (!stats.containsKey(situacion.tipoLlegada)) {
        stats[situacion.tipoLlegada] = {'favor': 0, 'contra': 0};
      }
      if (situacion.esAFavor) {
        stats[situacion.tipoLlegada]!['favor'] = stats[situacion.tipoLlegada]!['favor']! + 1;
      } else {
        stats[situacion.tipoLlegada]!['contra'] = stats[situacion.tipoLlegada]!['contra']! + 1;
      }
    }

    return stats;
  }
}
