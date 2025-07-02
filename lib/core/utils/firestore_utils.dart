import 'package:flutter/foundation.dart';

Future<T?> safeQuery<T>(Future<T> Function() query,
    {Function(dynamic)? onError}) async {
  try {
    return await query();
  } catch (e) {
    debugPrint('Firestore error: $e');
    if (onError != null) onError(e);
    return null;
  }
}
