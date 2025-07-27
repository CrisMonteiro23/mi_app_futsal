// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:mi_app_futsal/screens/equipos_screen.dart';
import 'package:mi_app_futsal/screens/jugadores_screen.dart';
import 'package:mi_app_futsal/screens/partidos_screen.dart';
import 'package:mi_app_futsal/screens/estadisticas_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de Liga de Futsal'),
        centerTitle: true, // Centra el título en la barra
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centra los elementos verticalmente
            crossAxisAlignment: CrossAxisAlignment.stretch, // Estira los botones horizontalmente
            children: <Widget>[
              // Título de bienvenida
              const Padding(
                padding: EdgeInsets.only(bottom: 40.0),
                child: Text(
                  '¡Bienvenido!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              // Botón para ir a la pantalla de Equipos
              _buildMenuItem(
                context,
                'Gestionar Equipos',
                Icons.group,
                const EquiposScreen(),
              ),
              const SizedBox(height: 20), // Espacio entre botones
              // Botón para ir a la pantalla de Jugadores
              _buildMenuItem(
                context,
                'Gestionar Jugadores',
                Icons.person,
                const JugadoresScreen(),
              ),
              const SizedBox(height: 20),
              // Botón para ir a la pantalla de Partidos
              _buildMenuItem(
                context,
                'Gestionar Partidos',
                Icons.sports_soccer,
                const PartidosScreen(),
              ),
              const SizedBox(height: 20),
              // Botón para ir a la pantalla de Estadísticas
              _buildMenuItem(
                context,
                'Ver Estadísticas',
                Icons.leaderboard,
                const EstadisticasScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para crear botones de menú con un estilo consistente
  Widget _buildMenuItem(BuildContext context, String title, IconData icon, Widget screen) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 30), // Icono del botón
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Text(
          title,
          style: const TextStyle(fontSize: 20), // Tamaño del texto
        ),
      ),
      onPressed: () {
        // Navega a la pantalla especificada cuando se presiona el botón
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Bordes más redondeados para los botones de menú
        ),
        elevation: 8, // Sombra más pronunciada
      ),
    );
  }
}
