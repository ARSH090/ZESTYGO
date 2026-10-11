import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase.initializeApp(...) belongs in core/bootstrap.dart once
  // `flutterfire configure` has generated firebase_options for each environment.
  runApp(const ProviderScope(child: ZestyGoApp()));
}
