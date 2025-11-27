import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'sync_service.dart';

/// Servicio para gestionar el estado de conectividad de la aplicación
class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final SyncService _syncService = SyncService();

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  bool _hasShownOfflineMessage = false;
  bool _isSyncing = false; // Prevenir sincronizaciones simultáneas
  bool _wasPreviouslyOffline = false;

  // Para pruebas: forzar modo offline/online
  bool _debugForceOffline = false;

  ConnectivityService() {
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('⚠️ Error checking connectivity: $e');
      _isOnline = true; // Asumir online si falla la verificación
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Si hay alguna conexión válida (WiFi, móvil, ethernet), está online
    final wasOnline = _isOnline;

    // Si está forzado offline (debug), mantener offline
    if (_debugForceOffline) {
      _isOnline = false;
    } else {
      _isOnline = results.any(
        (result) =>
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.ethernet,
      );
    }

    // Auto-sincronizar cuando se recupera la conexión
    if (_isOnline && _wasPreviouslyOffline && !_isSyncing) {
      print('🔄 Connection restored, auto-syncing...');
      _autoSync().then((_) {
        // Notificar después de que termine el sync
        if (wasOnline != _isOnline) {
          print(_isOnline ? '🟢 Conexión restaurada' : '🔴 Sin conexión');
          _hasShownOfflineMessage = false;
          notifyListeners();
        }
      });
    } else if (wasOnline != _isOnline) {
      print(_isOnline ? '🟢 Conexión restaurada' : '🔴 Sin conexión');
      _hasShownOfflineMessage = false;
      notifyListeners();
    }

    _wasPreviouslyOffline = !_isOnline;
  }

  /// Auto-sincronizar operaciones pendientes cuando se recupera conexión
  Future<void> _autoSync() async {
    if (_isSyncing) {
      print('⏸️ Sync already in progress, skipping...');
      return;
    }

    _isSyncing = true;
    try {
      final result = await _syncService.syncPendingOperations();
      print('✅ Auto-sync completed: ${result.message}');
    } catch (e) {
      print('❌ Auto-sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// [DEBUG] Forzar modo offline para pruebas
  void toggleDebugOfflineMode() {
    _debugForceOffline = !_debugForceOffline;

    print('🧪 DEBUG: Modo offline forzado = $_debugForceOffline');

    final newOnlineStatus = !_debugForceOffline;
    final previousOnlineStatus = _isOnline;

    _isOnline = newOnlineStatus;
    _hasShownOfflineMessage = false;
    _wasPreviouslyOffline = !newOnlineStatus;

    // Si estábamos offline y ahora vamos online, auto-sincronizar primero
    if (!previousOnlineStatus && newOnlineStatus && !_isSyncing) {
      print('🔄 Debug mode enabled online, triggering sync...');
      _autoSync().then((_) {
        // Notificar después del sync para que la UI recargue con datos actualizados
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  /// Marca que ya se mostró el mensaje offline (para evitar spam)
  void markOfflineMessageShown() {
    _hasShownOfflineMessage = true;
  }

  /// Verifica si debe mostrar el mensaje offline
  bool shouldShowOfflineMessage() {
    return !_isOnline && !_hasShownOfflineMessage;
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
