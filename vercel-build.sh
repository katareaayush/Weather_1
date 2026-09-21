#!/bin/bash
set -e

echo "==> Downloading Flutter SDK..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter-sdk
export PATH="$PATH:`pwd`/flutter-sdk/bin"

echo "==> Verifying Flutter installation..."
flutter --version

echo "==> Building Flutter Web..."
flutter build web --release

echo "==> Build complete!"
