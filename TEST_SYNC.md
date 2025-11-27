# 🔄 Prueba de Sincronización Offline → Online

## Sistema Implementado

La app ahora cuenta con un sistema completo de sincronización que permite:

- ✅ Crear ambientes en modo offline
- ✅ Editar ambientes en modo offline
- ✅ Eliminar ambientes en modo offline
- ✅ Sincronización automática al recuperar conexión
- ✅ Cola de operaciones pendientes persistente

## Componentes Agregados

### 1. SyncService (`lib/utils/sync_service.dart`)

- Procesa cola de operaciones pendientes
- Maneja CREATE, UPDATE, DELETE
- Retorna resultados de sincronización

### 2. Modificaciones en EnvironmentsListPage

- Listener de conectividad
- Auto-sync cuando vuelve conexión
- Muestra mensaje con resultado de sync

### 3. Modificaciones en EnvironmentFormPage

- Detecta modo offline antes de guardar
- Guarda operaciones en cola `pending_sync`
- Mensaje diferenciado para offline

### 4. Modificaciones en EnvironmentDetailPage

- Detecta modo offline antes de eliminar
- Agrega delete a cola de sincronización
- Mantiene UX consistente

## 📋 Pasos para Probar

### Escenario 1: Crear en Offline

1. Abre la app con conexión online
2. Navega a "Ambientes"
3. **Activa modo offline** usando el FAB azul en el menú principal
4. Toca el botón "+" para crear ambiente
5. Completa el formulario:
   - Nombre: "Laboratorio Offline Test"
   - Capacidad: 30
   - Selecciona pabellón, piso, estado, tipo
6. Guarda
7. **Verifica mensaje**: "💾 Guardado localmente. Se sincronizará cuando haya conexión"
8. **Desactiva modo offline** (FAB azul)
9. Espera ~2 segundos
10. **Verifica mensaje**: "✅ Sincronización completada: 1 operación(es)"
11. Refresca la lista
12. **Verifica**: El nuevo ambiente aparece con ID del backend

### Escenario 2: Editar en Offline

1. Con modo online, abre un ambiente existente
2. Toca el botón de editar (lápiz)
3. **Activa modo offline**
4. Modifica el nombre: "Editado Offline"
5. Guarda
6. **Verifica mensaje orange**: "Guardado localmente..."
7. **Desactiva modo offline**
8. Espera sincronización automática
9. **Verifica**: Los cambios se reflejan en backend

### Escenario 3: Eliminar en Offline

1. Con modo online, navega a un ambiente
2. **Activa modo offline**
3. Toca el botón de eliminar (papelera)
4. Confirma eliminación
5. **Verifica mensaje orange**: "Eliminación pendiente..."
6. Vuelve a la lista (debe desaparecer de UI)
7. **Desactiva modo offline**
8. Espera sincronización
9. **Verifica**: El ambiente se eliminó del backend

### Escenario 4: Múltiples Operaciones

1. **Activa modo offline**
2. Crea 2 ambientes nuevos
3. Edita 1 ambiente existente
4. Elimina 1 ambiente
5. **Verifica**: Total 4 operaciones pendientes
6. **Desactiva modo offline**
7. Espera ~5 segundos
8. **Verifica mensaje**: "Sincronización completada: 4 operación(es)"
9. Refresca lista
10. **Verifica**: Todos los cambios aplicados

## 🔍 Verificación en Backend

Puedes verificar en el backend que los cambios se aplicaron:

```bash
# Ver todos los ambientes
curl http://192.168.0.45:8080/environments/v1/api/academic-space

# Ver ambiente específico
curl http://192.168.0.45:8080/environments/v1/api/academic-space/{id}
```

## 🎯 Indicadores de Éxito

- ✅ Mensajes con emoji diferenciados (💾 offline, ✅ online)
- ✅ Color orange para operaciones offline
- ✅ Auto-sincronización desde cualquier vista
- ✅ No se duplican operaciones
- ✅ No errores en consola durante sync
- ✅ IDs del backend aparecen después de sync
- ✅ Lista se actualiza automáticamente
- ✅ Operaciones pendientes se limpian tras sync
- ✅ Sincronización solo ocurre una vez por reconexión

## 🐛 Debug

Si hay problemas, revisa:

1. Console logs: `print('🔄 Connection restored, syncing...')`
2. Hive box: `pending_sync` debe estar vacío después de sync
3. Backend logs en `192.168.0.45:8080`
4. Token de acceso válido

## 📊 Flujo Técnico

```
[Usuario crea/edita offline]
        ↓
[Guardar en pending_sync box]
        ↓
[Mostrar mensaje orange]
        ↓
[Usuario activa online]
        ↓
[ConnectivityListener detecta cambio]
        ↓
[SyncService.syncPendingOperations()]
        ↓
[Ejecutar cada operación vs backend]
        ↓
[Limpiar pending_sync box]
        ↓
[Recargar lista desde backend]
        ↓
[Mostrar mensaje green con resultado]
```

## 🎨 Mensajes de Usuario

| Acción       | Modo    | Mensaje                                       | Color   |
| ------------ | ------- | --------------------------------------------- | ------- |
| Create       | Offline | 💾 Guardado localmente. Se sincronizará...    | Orange  |
| Create       | Online  | ✅ Ambiente creado exitosamente               | Default |
| Update       | Offline | 💾 Guardado localmente. Se sincronizará...    | Orange  |
| Update       | Online  | ✅ Ambiente actualizado exitosamente          | Default |
| Delete       | Offline | 💾 Eliminación pendiente. Se sincronizará...  | Orange  |
| Delete       | Online  | ✅ Ambiente eliminado exitosamente            | Default |
| Sync Success | Auto    | ✅ Sincronización completada: X operación(es) | Green   |
| Sync Partial | Auto    | ⚠️ Sincronizadas X de Y operaciones           | Orange  |
