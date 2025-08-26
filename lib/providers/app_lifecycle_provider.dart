import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/logger.dart';

// App lifecycle state provider
final appLifecycleProvider = Provider<AppLifecycleListener>((ref) {
  return AppLifecycleListener(
    onShow: () => AppLogger.logger.ui('📱 App resumed'),
    onHide: () => AppLogger.logger.ui('📱 App paused'),
    onDetach: () => AppLogger.logger.ui('📱 App detached'),
    onInactive: () => AppLogger.logger.ui('📱 App inactive'),
    onPause: () => AppLogger.logger.ui('📱 App hidden'),
  );
});

final appLifecycleStateProvider = StateProvider<AppLifecycleState>((ref) {
  return AppLifecycleState.resumed;
});

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

  void updateState(AppLifecycleState newState) {
    if (state != newState) {
      AppLogger.logger
          .ui('📱 App lifecycle changed: ${state.name} → ${newState.name}');
      state = newState;
    }
  }
}

