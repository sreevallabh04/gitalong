import 'package:flutter/foundation.dart';

Future<T?> safeQuery<T>(Future<T> Function() query,
    {Function()? onError,}) async {
  try {
    return await query();
  } on Exception catch (e) {
    debugPrint('Firestore error: $e');
    if (onError != null) onError(e);
    return null;
  }
}
