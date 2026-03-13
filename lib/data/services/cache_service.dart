import 'package:injectable/injectable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

/// Cache service for storing frequently accessed data
@lazySingleton
class CacheService {
  late Box<dynamic> _cacheBox;
  bool _initialized = false;
  
  /// Initialize cache service
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      _cacheBox = await Hive.openBox(AppConstants.cacheBox);
      _initialized = true;
      AppLogger.i('Cache service initialized');
    } catch (e, stackTrace) {
      AppLogger.e('Error initializing cache service', e, stackTrace);
      rethrow;
    }
  }
  
  /// Store data in cache with TTL
  Future<void> put(
    String key,
    dynamic value, {
    Duration? ttl,
  }) async {
    await _ensureInitialized();
    
    try {
      final cacheEntry = {
        'value': value,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'ttl': ttl?.inMilliseconds,
      };
      
      await _cacheBox.put(key, cacheEntry);
      AppLogger.d('Cached data for key: $key');
    } catch (e) {
      AppLogger.e('Error caching data for key: $key', e);
    }
  }
  
  /// Get data from cache (returns null if expired or not found)
  Future<T?> get<T>(String key) async {
    await _ensureInitialized();
    
    try {
      final cacheEntry = _cacheBox.get(key) as Map?;
      
      if (cacheEntry == null) {
        AppLogger.d('Cache miss for key: $key');
        return null;
      }
      
      final timestamp = cacheEntry['timestamp'] as int;
      final ttl = cacheEntry['ttl'] as int?;
      
      // Check if expired
      if (ttl != null) {
        final age = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (age > ttl) {
          AppLogger.d('Cache expired for key: $key');
          await delete(key);
          return null;
        }
      }
      
      AppLogger.d('Cache hit for key: $key');
      return cacheEntry['value'] as T?;
    } catch (e) {
      AppLogger.e('Error reading cache for key: $key', e);
      return null;
    }
  }
  
  /// Delete data from cache
  Future<void> delete(String key) async {
    await _ensureInitialized();
    
    try {
      await _cacheBox.delete(key);
      AppLogger.d('Deleted cache for key: $key');
    } catch (e) {
      AppLogger.e('Error deleting cache for key: $key', e);
    }
  }
  
  /// Clear entire cache
  Future<void> clearAll() async {
    await _ensureInitialized();
    
    try {
      await _cacheBox.clear();
      AppLogger.i('Cleared all cache');
    } catch (e) {
      AppLogger.e('Error clearing cache', e);
    }
  }
  
  /// Check if key exists and is not expired
  Future<bool> has(String key) async {
    await _ensureInitialized();
    
    final value = await get(key);
    return value != null;
  }
  
  /// Get cache statistics
  Future<CacheStats> getStats() async {
    await _ensureInitialized();
    
    int totalEntries = _cacheBox.length;
    int expiredEntries = 0;
    int totalSize = 0;
    
    for (final key in _cacheBox.keys) {
      final entry = _cacheBox.get(key) as Map?;
      if (entry != null) {
        final timestamp = entry['timestamp'] as int;
        final ttl = entry['ttl'] as int?;
        
        if (ttl != null) {
          final age = DateTime.now().millisecondsSinceEpoch - timestamp;
          if (age > ttl) {
            expiredEntries++;
          }
        }
        
        totalSize += entry.toString().length;
      }
    }
    
    return CacheStats(
      totalEntries: totalEntries,
      expiredEntries: expiredEntries,
      activeEntries: totalEntries - expiredEntries,
      totalSizeBytes: totalSize,
    );
  }
  
  /// Ensure cache is initialized
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }
}

/// Cache statistics model
class CacheStats {
  final int totalEntries;
  final int expiredEntries;
  final int activeEntries;
  final int totalSizeBytes;
  
  CacheStats({
    required this.totalEntries,
    required this.expiredEntries,
    required this.activeEntries,
    required this.totalSizeBytes,
  });
  
  double get hitRate => activeEntries / (totalEntries > 0 ? totalEntries : 1);
  
  String get totalSizeFormatted {
    if (totalSizeBytes < 1024) return '$totalSizeBytes B';
    if (totalSizeBytes < 1024 * 1024) {
      return '${(totalSizeBytes / 1024).toStringAsFixed(2)} KB';
    }
    return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
  
  @override
  String toString() {
    return 'CacheStats(total: $totalEntries, active: $activeEntries, '
        'expired: $expiredEntries, size: $totalSizeFormatted, hitRate: ${(hitRate * 100).toStringAsFixed(1)}%)';
  }
}



