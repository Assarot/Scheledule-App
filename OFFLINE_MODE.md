# Sistema Offline/Online - Schedule App

## ✅ Implementación Completada

### 📦 Dependencias Agregadas

```yaml
connectivity_plus: ^6.1.0 # Detección de conectividad
hive: ^2.2.3 # Base de datos local NoSQL
hive_flutter: ^1.1.0 # Extensiones de Hive para Flutter
path_provider: ^2.1.5 # Rutas del sistema
```

### 🔧 Componentes Creados

#### 1. **ConnectivityService** (`lib/utils/connectivity_service.dart`)

- Monitorea el estado de conexión en tiempo real
- Notifica cambios a toda la app mediante Provider
- Detecta WiFi, datos móviles y ethernet

#### 2. **CacheService** (`lib/utils/cache_service.dart`)

- Cache local de perfiles de usuario con Hive
- Sistema de cola para operaciones pendientes de sincronización
- Métodos para guardar/cargar perfiles offline

#### 3. **ConnectivityBanner** (`lib/presentation/widgets/connectivity_banner.dart`)

- Banner naranja que aparece cuando no hay conexión
- Informa al usuario que está en modo offline
- Se oculta automáticamente cuando hay conexión

### 🔄 Flujo de Funcionamiento

#### **Login (Requiere conexión obligatoriamente)**

```
Usuario intenta login
    ↓
¿Hay conexión?
    ├─ SÍ → Procede con autenticación normal
    └─ NO → Muestra mensaje "Requiere conexión"
```

#### **Carga de Perfil (Híbrido Online/Offline)**

```
Usuario abre perfil
    ↓
¿Tiene userProfileId en JWT?
    ├─ SÍ → Usa ese ID
    └─ NO → Intenta GET a /api/auth/users/{id} (si hay conexión)
    ↓
¿Hay conexión?
    ├─ SÍ → Carga desde servidor → Guarda en cache
    └─ NO → Carga desde cache (si existe)
    ↓
¿Falló servidor pero hay cache?
    └─ SÍ → Usa cache como fallback
```

### 🔐 Seguridad

**✅ Lo que SÍ se guarda localmente:**

- Perfiles de usuario (datos públicos: nombre, email, teléfono)
- Tokens JWT (ya estaban en `flutter_secure_storage` - encriptado)
- Operaciones pendientes de sincronización

**❌ Lo que NO se guarda:**

- Contraseñas
- Credenciales de usuario
- Datos sensibles de autenticación

### 📱 Experiencia de Usuario

#### **Con Conexión**

- Funcionamiento normal
- Datos actualizados del servidor
- Cache se actualiza automáticamente

#### **Sin Conexión**

- Banner naranja visible en la parte superior
- Perfil cargado desde cache
- Login deshabilitado (muestra mensaje)
- Cambios se encolarán para sincronización futura

### 🚀 Próximos Pasos (Opcional)

Si deseas expandir la funcionalidad offline:

1. **Cache de más datos**

   - Ambientes
   - Recursos
   - Cursos

2. **Cola de sincronización**

   - Guardar cambios locales cuando no hay conexión
   - Sincronizar automáticamente cuando vuelva la conexión

3. **Indicadores visuales**
   - Ícono de sincronización pendiente
   - Timestamp de última sincronización

### 📝 Uso

La app ahora funciona automáticamente en modo híbrido:

```dart
// El ConnectivityService está disponible globalmente
final connectivity = context.read<ConnectivityService>();

if (connectivity.isOnline) {
  // Hacer llamada al servidor
} else {
  // Usar datos en cache
}
```

### ⚠️ Limitaciones

1. **Login siempre requiere conexión** (por seguridad)
2. **Cache tiene vida limitada** (se invalida eventualmente)
3. **Cambios offline no se persisten** al backend hasta que haya conexión
