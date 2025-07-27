import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa el paquete Provider
import 'package:mi_app_futsal/data/app_data.dart'; // Importa tu gestor de datos
import 'package:mi_app_futsal/screens/home_screen.dart'; // Importa la pantalla de inicio

void main() {
  // runApp es la función principal que inicia tu aplicación Flutter.
  // Aquí envolvemos nuestra aplicación con ChangeNotifierProvider.
  // Esto permite que todas las pantallas y widgets de la aplicación
  // accedan y reaccionen a los cambios en AppData.
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppData(), // Crea una instancia de AppData
      child: const MyApp(), // Tu aplicación principal
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp es el widget raíz de una aplicación Material Design.
    // Define el título, tema y la pantalla de inicio de la app.
    return MaterialApp(
      title: 'Gestor de Liga de Futsal', // Título de la aplicación
      debugShowCheckedModeBanner: false, // Oculta la etiqueta "DEBUG" en la esquina
      theme: ThemeData(
        primarySwatch: Colors.blue, // Color principal de la aplicación
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent, // Color de la barra superior
          foregroundColor: Colors.white, // Color del texto en la barra superior
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blueAccent, // Color del botón flotante
          foregroundColor: Colors.white, // Color del icono del botón flotante
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent, // Color de fondo de los botones elevados
            foregroundColor: Colors.white, // Color del texto de los botones elevados
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Bordes redondeados
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4, // Sombra de las tarjetas
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Bordes redondeados de las tarjetas
          ),
        ),
      ),
      home: const HomeScreen(), // La pantalla principal de tu aplicación
    );
  }
}
