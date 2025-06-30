import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

// App lifecycle state provider
final appLifecycleProvider =
    StateNotifierProvider<AppLifecycleNotifier, AppLifecycleState>(
      (ref) => AppLifecycleNotifier(),
    );

class AppLifecycleNotifier extends StateNotifier<AppLifecycleState>
    with WidgetsBindingObserver {
  AppLifecycleNotifier() : super(AppLifecycleState.resumed) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    this.state = state;

    switch (state) {
      case AppLifecycleState.resumed:
        if (kDebugMode) print('📱 App resumed');
        break;
      case AppLifecycleState.paused:
        if (kDebugMode) print('📱 App paused');
        break;
      case AppLifecycleState.detached:
        if (kDebugMode) print('📱 App detached');
        break;
      case AppLifecycleState.inactive:
        if (kDebugMode) print('📱 App inactive');
        break;
      case AppLifecycleState.hidden:
        if (kDebugMode) print('📱 App hidden');
        break;
    }
  }
}
