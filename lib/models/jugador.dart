// lib/models/jugador.dart
// Este archivo define la estructura de datos para un Jugador.

class Jugador {
  String id; // Identificador único del jugador
  String nombre; // Nombre del jugador
  String apellido; // Apellido del jugador
  String equipoId; // ID del equipo al que pertenece el jugador
  String equipoNombre; // Nombre del equipo (para fácil visualización)
  String posicion; // Posición del jugador (ej: Portero, Cierre, Ala, Pívot)
  int numeroCamiseta; // Número de camiseta
  int goles; // Goles marcados
  int asistencias; // Asistencias realizadas
  int tarjetasAmarillas; // Cantidad de tarjetas amarillas
  int tarjetasRojas; // Cantidad de tarjetas rojas
  bool lesionado; // Indica si el jugador está lesionado

  // Constructor de la clase Jugador.
  // Todos los campos son obligatorios, excepto las estadísticas que tienen valores predeterminados.
  Jugador({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.equipoId,
    required this.equipoNombre,
    required this.posicion,
    required this.numeroCamiseta,
    this.goles = 0,
    this.asistencias = 0,
    this.tarjetasAmarillas = 0,
    this.tarjetasRojas = 0,
    this.lesionado = false, // Por defecto, no lesionado
  });

  // Método para convertir un objeto Jugador a un formato JSON (Map).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'equipoId': equipoId,
      'equipoNombre': equipoNombre,
      'posicion': posicion,
      'numeroCamiseta': numeroCamiseta,
      'goles': goles,
      'asistencias': asistencias,
      'tarjetasAmarillas': tarjetasAmarillas,
      'tarjetasRojas': tarjetasRojas,
      'lesionado': lesionado,
    };
  }

  // Método de fábrica para crear un objeto Jugador desde un formato JSON (Map).
  factory Jugador.fromJson(Map<String, dynamic> json) {
    return Jugador(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      equipoId: json['equipoId'],
      equipoNombre: json['equipoNombre'],
      posicion: json['posicion'],
      numeroCamiseta: json['numeroCamiseta'] ?? 0,
      goles: json['goles'] ?? 0,
      asistencias: json['asistencias'] ?? 0,
      tarjetasAmarillas: json['tarjetasAmarillas'] ?? 0,
      tarjetasRojas: json['tarjetasRojas'] ?? 0,
      lesionado: json['lesionado'] ?? false,
    );
  }
}
