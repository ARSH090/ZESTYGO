#!/usr/bin/env bash
# One-time workspace setup. Run from anywhere. Commit the resulting pubspec changes and lockfiles.
set -euo pipefail
cd "$(dirname "$0")/.."

command -v flutter >/dev/null || { echo "flutter not found on PATH"; exit 1; }
command -v node >/dev/null || { echo "node not found on PATH"; exit 1; }
command -v melos >/dev/null || dart pub global activate melos

add_pkg() { # dir, packages...
  local dir=$1; shift
  (cd "$dir" && flutter pub add "$@")
}

# 'flutter pub add' resolves versions that are compatible with your Flutter SDK.
COMMON="flutter_riverpod go_router firebase_core firebase_auth cloud_firestore cloud_functions firebase_app_check firebase_analytics"
MOBILE="firebase_crashlytics firebase_performance firebase_messaging"

add_pkg apps/customer_app    $COMMON $MOBILE firebase_storage google_maps_flutter razorpay_flutter cached_network_image
add_pkg apps/delivery_app    $COMMON $MOBILE firebase_storage google_maps_flutter geolocator url_launcher
add_pkg apps/restaurant_portal $COMMON firebase_storage cached_network_image
add_pkg apps/admin_portal    $COMMON firebase_storage google_maps_flutter cached_network_image

add_pkg packages/authentication  flutter_riverpod firebase_auth cloud_firestore
add_pkg packages/networking      cloud_functions
add_pkg packages/common_services firebase_analytics connectivity_plus
add_pkg packages/location_services geolocator

(cd functions && npm install)
melos bootstrap
echo "Setup complete. Next: flutterfire configure per app and environment (see docs/DEPLOYMENT.md)."
