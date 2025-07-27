// lib/models/jugador.dart
// Este archivo define la estructura de datos para un Jugador.

class Jugador {
  String id; // Identificador único del jugador
  String nombre; // Nombre completo del jugador (ej: "Victor")

  // Constructor de la clase Jugador.
  Jugador({
    required this.id,
    required this.nombre,
  });

  // Método para convertir un objeto Jugador a un formato JSON (Map).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }

  // Método de fábrica para crear un objeto Jugador desde un formato JSON (Map).
  factory Jugador.fromJson(Map<String, dynamic> json) {
    return Jugador(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}
