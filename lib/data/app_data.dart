// lib/data/app_data.dart
// Este archivo gestiona todos los datos de la aplicación (equipos, jugadores, partidos)
// y la lógica para añadir, editar, eliminar y actualizar estadísticas.
// Usa ChangeNotifier para notificar a los widgets cuando los datos cambian.

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // Importa el paquete Uuid para generar IDs únicos
import 'package:mi_app_futsal/models/equipo.dart';
import 'package:mi_app_futsal/models/jugador.dart';
import 'package:mi_app_futsal/models/partido.dart';

class AppData extends ChangeNotifier {
  // Instancia de Uuid para generar IDs
  final Uuid _uuid = const Uuid();

  // Listas que almacenarán los datos de la aplicación
  final List<Equipo> _equipos = [];
  final List<Jugador> _jugadores = [];
  final List<Partido> _partidos = [];

  // Getters para acceder a las listas de datos (solo lectura)
  List<Equipo> get equipos => List.unmodifiable(_equipos);
  List<Jugador> get jugadores => List.unmodifiable(_jugadores);
  List<Partido> get partidos => List.unmodifiable(_partidos);

  // ---------------------------------------------------------------------------
  // Métodos para gestionar EQUIPOS
  // ---------------------------------------------------------------------------

  // Añade un nuevo equipo a la lista
  void addEquipo(String nombre, String entrenador, String colores) {
    final newEquipo = Equipo(
      id: _uuid.v4(), // Genera un ID único
      nombre: nombre,
      entrenador: entrenador,
      colores: colores,
    );
    _equipos.add(newEquipo);
    _equipos.sort((a, b) => b.puntos.compareTo(a.puntos)); // Ordena por puntos
    notifyListeners(); // Notifica a los widgets que los datos han cambiado
  }

  // Edita un equipo existente
  void editEquipo(String id, String newNombre, String newEntrenador, String newColores) {
    final index = _equipos.indexWhere((e) => e.id == id);
    if (index != -1) {
      _equipos[index].nombre = newNombre;
      _equipos[index].entrenador = newEntrenador;
      _equipos[index].colores = newColores;
      notifyListeners();
    }
  }

  // Elimina un equipo por su ID
  void deleteEquipo(String id) {
    _equipos.removeWhere((e) => e.id == id);
    // También elimina jugadores asociados a este equipo
    _jugadores.removeWhere((j) => j.equipoId == id);
    // Y partidos donde este equipo sea local o visitante
    _partidos.removeWhere((p) => p.equipoLocalId == id || p.equipoVisitanteId == id);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Métodos para gestionar JUGADORES
  // ---------------------------------------------------------------------------

  // Añade un nuevo jugador a la lista
  void addJugador(String nombre, String apellido, String equipoId, String equipoNombre, String posicion, int numeroCamiseta, bool lesionado) {
    final newJugador = Jugador(
      id: _uuid.v4(), // Genera un ID único
      nombre: nombre,
      apellido: apellido,
      equipoId: equipoId,
      equipoNombre: equipoNombre,
      posicion: posicion,
      numeroCamiseta: numeroCamiseta,
      lesionado: lesionado,
    );
    _jugadores.add(newJugador);
    notifyListeners();
  }

  // Edita un jugador existente
  void editJugador(String id, String newNombre, String newApellido, String newEquipoId, String newEquipoNombre, String newPosicion, int newNumeroCamiseta, bool newLesionado) {
    final index = _jugadores.indexWhere((j) => j.id == id);
    if (index != -1) {
      _jugadores[index].nombre = newNombre;
      _jugadores[index].apellido = newApellido;
      _jugadores[index].equipoId = newEquipoId;
      _jugadores[index].equipoNombre = newEquipoNombre;
      _jugadores[index].posicion = newPosicion;
      _jugadores[index].numeroCamiseta = newNumeroCamiseta;
      _jugadores[index].lesionado = newLesionado;
      notifyListeners();
    }
  }

  // Elimina un jugador por su ID
  void deleteJugador(String id) {
    _jugadores.removeWhere((j) => j.id == id);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Métodos para gestionar PARTIDOS
  // ---------------------------------------------------------------------------

  // Añade un nuevo partido a la lista
  void addPartido(DateTime fecha, String hora, Equipo equipoLocal, Equipo equipoVisitante, String cancha, String arbitro) {
    final newPartido = Partido(
      id: _uuid.v4(), // Genera un ID único
      fecha: fecha,
      hora: hora,
      equipoLocalId: equipoLocal.id,
      equipoLocalNombre: equipoLocal.nombre,
      equipoVisitanteId: equipoVisitante.id,
      equipoVisitanteNombre: equipoVisitante.nombre,
      cancha: cancha,
      arbitro: arbitro,
      estado: 'Programado', // Estado inicial
    );
    _partidos.add(newPartido);
    notifyListeners();
  }

  // Registra el resultado de un partido y actualiza estadísticas
  void registrarResultadoPartido(String partidoId, int golesLocal, int golesVisitante) {
    final partidoIndex = _partidos.indexWhere((p) => p.id == partidoId);
    if (partidoIndex != -1) {
      final partido = _partidos[partidoIndex];
      partido.golesLocal = golesLocal;
      partido.golesVisitante = golesVisitante;
      partido.estado = 'Jugado'; // Cambia el estado a "Jugado"

      // Actualizar estadísticas de los equipos
      _actualizarEstadisticasEquipo(partido.equipoLocalId, golesLocal, golesVisitante);
      _actualizarEstadisticasEquipo(partido.equipoVisitanteId, golesVisitante, golesLocal);

      notifyListeners();
    }
  }

  // Método privado para actualizar las estadísticas de un solo equipo
  void _actualizarEstadisticasEquipo(String equipoId, int golesAFavor, int golesEnContra) {
    final equipo = _equipos.firstWhere((e) => e.id == equipoId);
    if (equipo != null) {
      equipo.pj += 1; // Partidos Jugados
      equipo.gf += golesAFavor; // Goles a Favor
      equipo.gc += golesEnContra; // Goles en Contra
      equipo.dg = equipo.gf - equipo.gc; // Diferencia de Goles

      if (golesAFavor > golesEnContra) {
        equipo.pg += 1; // Partidos Ganados
        equipo.puntos += 3; // 3 puntos por victoria
      } else if (golesAFavor == golesEnContra) {
        equipo.pe += 1; // Partidos Empatados
        equipo.puntos += 1; // 1 punto por empate
      } else {
        equipo.pp += 1; // Partidos Perdidos
      }
      _equipos.sort((a, b) => b.puntos.compareTo(a.puntos)); // Reordena la tabla
    }
  }

  // Elimina un partido por su ID
  void deletePartido(String id) {
    _partidos.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Métodos para actualizar estadísticas de JUGADORES (llamados desde el registro de partido)
  // ---------------------------------------------------------------------------

  void updateJugadorStats(String jugadorId, {int? goles, int? asistencias, int? amarillas, int? rojas}) {
    final index = _jugadores.indexWhere((j) => j.id == jugadorId);
    if (index != -1) {
      if (goles != null) _jugadores[index].goles += goles;
      if (asistencias != null) _jugadores[index].asistencias += asistencias;
      if (amarillas != null) _jugadores[index].tarjetasAmarillas += amarillas;
      if (rojas != null) _jugadores[index].tarjetasRojas += rojas;
      notifyListeners();
    }
  }
}
