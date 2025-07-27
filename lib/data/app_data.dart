// lib/data/app_data.dart
// Este archivo gestiona todos los datos de la aplicación (jugadores, situaciones registradas)
// y la lógica para añadir situaciones y calcular estadísticas.
// Usa ChangeNotifier para notificar a los widgets cuando los datos cambian.

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // Para generar IDs únicos
import 'package:mi_app_futsal/models/jugador.dart';
import 'package:mi_app_futsal/models/situacion.dart';

class AppData extends ChangeNotifier {
  final Uuid _uuid = const Uuid();

  // Lista de jugadores disponibles (predefinidos + añadidos manualmente)
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

  // Lista de todas las situaciones registradas
  final List<Situacion> _situacionesRegistradas = [];

  // Getters para acceder a los datos (solo lectura)
  List<Jugador> get jugadoresDisponibles => List.unmodifiable(_jugadoresDisponibles);
  List<Situacion> get situacionesRegistradas => List.unmodifiable(_situacionesRegistradas);

  // Añade un nuevo jugador a la lista de disponibles
  void addJugador(String nombre) {
    if (nombre.trim().isEmpty) return; // No añadir nombres vacíos
    if (_jugadoresDisponibles.any((j) => j.nombre.toLowerCase() == nombre.toLowerCase())) {
      // Opcional: Mostrar un mensaje al usuario de que el jugador ya existe
      return;
    }
    _jugadoresDisponibles.add(Jugador(id: _uuid.v4(), nombre: nombre.trim()));
    notifyListeners();
  }

  // Registra una nueva situación (llegada a favor/contra)
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

  // Elimina una situación por su ID (útil para corregir errores)
  void deleteSituacion(String id) {
    _situacionesRegistradas.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Métodos para calcular ESTADÍSTICAS
  // ---------------------------------------------------------------------------

  // Calcula las estadísticas de llegadas a favor y en contra por jugador
  // Retorna: Map<ID_Jugador, Map<Tipo_Estadistica, Cantidad>>
  // Ejemplo: { 'jugador1_id': { 'favor': 5, 'contra': 2 }, ... }
  Map<String, Map<String, int>> getPlayerStats() {
    final Map<String, Map<String, int>> stats = {};

    // Inicializar estadísticas para todos los jugadores disponibles
    for (var jugador in _jugadoresDisponibles) {
      stats[jugador.id] = {'favor': 0, 'contra': 0};
    }

    // Procesar cada situación registrada
    for (var situacion in _situacionesRegistradas) {
      for (var jugadorId in situacion.jugadoresEnCanchaIds) {
        if (!stats.containsKey(jugadorId)) {
          // Esto debería ser raro si todos los jugadores están en _jugadoresDisponibles
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

  // Calcula las estadísticas de situaciones a favor y en contra por tipo de llegada
  // Retorna: Map<Tipo_Llegada, Map<Tipo_Estadistica, Cantidad>>
  // Ejemplo: { 'Ataque Posicional': { 'favor': 10, 'contra': 5 }, ... }
  Map<String, Map<String, int>> getSituacionTypeStats() {
    final Map<String, Map<String, int>> stats = {};

    // Inicializar estadísticas para todos los tipos de llegada posibles
    for (var tipo in [
      'Ataque Posicional', 'INC Portero', 'Transicion Corta',
      'Transicion Larga', 'ABP', '5x4', '4x5', 'Dobles-Penales'
    ]) {
      stats[tipo] = {'favor': 0, 'contra': 0};
    }

    // Procesar cada situación registrada
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
