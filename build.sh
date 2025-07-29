#!/bin/sh

# 1. Descargar y extraer el SDK de Flutter para Linux (versión 3.32.8)
#    -sL: Silencioso y sigue redirecciones.
#    | tar xJ: Descomprime el archivo .tar.xz directamente desde la salida de curl.
curl -sL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.32.8-stable.tar.xz | tar xJ

# 2. Añadir el directorio bin de Flutter al PATH del entorno.
#    Esto asegura que los comandos 'flutter' sean reconocidos en los pasos siguientes.
export PATH="$(pwd)/flutter/bin:$PATH"

# 3. Configurar Git para añadir el directorio de Flutter como seguro.
#    Esto resuelve el error "fatal: detected dubious ownership" que Git lanza
#    cuando los archivos se extraen con permisos que considera inseguros en entornos automatizados.
git config --global --add safe.directory "$(pwd)/flutter"

# 4. Asegurar que los binarios de Flutter tengan permisos de ejecución.
#    Esto previene problemas de permisos al intentar ejecutar los comandos de Flutter.
chmod -R +x "$(pwd)/flutter/bin"

# 5. Obtener las dependencias de Dart/Flutter definidas en pubspec.yaml.
#    Este comando descarga todos los paquetes necesarios para tu proyecto.
flutter pub get

# 6. Compilar la aplicación Flutter para la plataforma web en modo de lanzamiento.
#    --release: Optimiza la aplicación para producción, reduciendo el tamaño y mejorando el rendimiento.
flutter build web --release
