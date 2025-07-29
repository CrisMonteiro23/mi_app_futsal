#!/bin/sh
# Descargar Flutter beta 3.35.0-0.1.pre (incluye Dart 3.9.0)
curl -sL https://storage.googleapis.com/flutter_infra_release/releases/beta/linux/flutter_linux_3.35.0-0.1.pre-beta.tar.xz | tar xJ
git config --global --add safe.directory "$(pwd)/flutter"
PATH="$(pwd)/flutter/bin:$PATH" flutter pub get
PATH="$(pwd)/flutter/bin:$PATH" flutter build web --release
