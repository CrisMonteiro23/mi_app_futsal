#!/bin/sh
curl -sL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.32.8-stable.tar.xz | tar xJ
git config --global --add safe.directory "$(pwd)/flutter"
PATH="$(pwd)/flutter/bin:$PATH" flutter pub get
PATH="$(pwd)/flutter/bin:$PATH" flutter build web --release
# 6. Compilar la aplicación Flutter para la plataforma web en modo de lanzamiento.
#    --release: Optimiza la aplicación para producción, reduciendo el tamaño y mejorando el rendimiento.
flutter build web --release
