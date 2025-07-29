#!/bin/sh
curl -sL https://storage.googleapis.com/flutter_infra_release/releases/master/linux/flutter_linux_master.tar.xz | tar xJ
git config --global --add safe.directory "$(pwd)/flutter"
PATH="$(pwd)/flutter/bin:$PATH" flutter pub get
PATH="$(pwd)/flutter/bin:$PATH" flutter build web --release
