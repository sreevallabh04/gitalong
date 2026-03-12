import 'dart:async';
import 'package:flutter/foundation.dart';

/// A [ChangeNotifier] that can be used as a [GoRouter.refreshListenable].
/// It listens to a stream and notifies listeners on each event.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
