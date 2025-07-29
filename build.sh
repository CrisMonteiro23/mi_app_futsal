#!/bin/sh
curl -sL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.32.8-stable.tar.xz | tar xJ
git config --global --add safe.directory "$(pwd)/flutter"
PATH="$(pwd)/flutter/bin:$PATH" flutter pub get
PATH="$(pwd)/flutter/bin:$PATH" flutter build web --release
