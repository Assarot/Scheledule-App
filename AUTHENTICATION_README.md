# Schedule App - Autenticación con Backend

## 📋 Configuración del Backend

### 1. URL del Backend

Edita el archivo `lib/utils/api_config.dart` y configura la URL según tu entorno:

```dart
// Para emulador Android
static const String baseUrl = 'http://10.0.2.2:8080';

// Para dispositivo físico (usa la IP de tu máquina)
static const String baseUrl = 'http://192.168.1.X:8080';

// Para iOS Simulator
static const String baseUrl = 'http://localhost:8080';

// Para producción
static const String baseUrl = 'https://tu-backend.com';
```

### 2. Instalación de Dependencias

Ejecuta el siguiente comando en la terminal:

```bash
flutter pub get
```

## 🏗️ Arquitectura

El proyecto sigue Clean Architecture con la siguiente estructura:

```
lib/
├── data/
│   ├── datasources/
│   │   ├── auth_local_datasource.dart    # Manejo de storage local
│   │   └── auth_remote_datasource.dart   # Peticiones HTTP al backend
│   ├── models/
│   │   ├── login_request.dart
│   │   ├── login_response.dart
│   │   ├── refresh_token_response.dart
│   │   └── user_model.dart
│   └── repository_impl/
│       └── auth_repository_impl.dart     # Implementación del repositorio
├── domain/
│   ├── entity/
│   │   └── user.dart                     # Entidad User
│   ├── repository/
│   │   └── auth_repository.dart          # Interface del repositorio
│   └── usescases/
│       ├── login_usecase.dart
│       ├── logout_usecase.dart
│       └── refresh_token_usecase.dart
├── presentation/
│   ├── pages/
│   │   ├── login_page.dart               # UI de Login
│   │   └── ...
│   └── widgets/
└── utils/
    ├── api_config.dart                   # Configuración de URLs
    ├── auth_guard.dart                   # Protección de rutas
    ├── auth_service.dart                 # Servicio de autenticación
    └── authenticated_http_client.dart    # HTTP Client con interceptor
```

## 🔐 Funcionalidades Implementadas

### 1. Autenticación

- ✅ Login con email y contraseña
- ✅ Opción "Recuérdame" (usa endpoint diferente)
- ✅ Almacenamiento seguro de tokens (FlutterSecureStorage)
- ✅ Manejo de sesión de usuario

### 2. Interceptor HTTP

Similar al interceptor de Angular, el `AuthenticatedHttpClient`:

- ✅ Agrega automáticamente el token de acceso a las peticiones
- ✅ Excluye rutas públicas (login, register, refresh)
- ✅ Refresca el token automáticamente en errores 401/403
- ✅ Cierra sesión si el refresh token falla

### 3. Guards de Protección

- ✅ `AuthGuard`: Protege rutas que requieren autenticación
- ✅ `AdminGuard`: Protege rutas que requieren rol de ADMIN
- ✅ Validación de roles del usuario

### 4. Manejo de Estado

- ✅ Provider para gestión de estado de autenticación
- ✅ Estados: isAuthenticated, isLoading, currentUser
- ✅ Notificaciones reactivas de cambios

## 📱 Uso Básico

### Login

```dart
final authService = context.read<AuthService>();
final result = await authService.login(email, password, rememberMe);

if (result['success'] == true) {
  // Login exitoso
  Navigator.pushReplacement(...);
} else {
  // Mostrar error
  print(result['error']);
}
```

### Proteger una Ruta

```dart
// Ruta que requiere autenticación
AuthGuard(
  child: MyProtectedPage(),
)

// Ruta que requiere rol de ADMIN
AdminGuard(
  child: MyAdminPage(),
)

// Ruta con roles personalizados
AuthGuard(
  requiredRoles: ['ADMIN', 'MODERATOR'],
  child: MyPage(),
)
```

### Logout

```dart
final authService = context.read<AuthService>();
await authService.logout();
Navigator.pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => LoginPage()),
  (route) => false,
);
```

### Verificar Autenticación

```dart
final authService = context.watch<AuthService>();

if (authService.isAuthenticated) {
  // Usuario autenticado
  print('Usuario: ${authService.currentUser?.name}');
}

// Verificar rol
if (authService.hasRole('ADMIN')) {
  // Usuario es admin
}
```

## 🔧 Configuración Adicional

### Android - Permisos de Internet

Ya configurado en `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### Android - Network Security (para HTTP local)

Si usas HTTP en desarrollo, crea `android/app/src/main/res/xml/network_security_config.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
</network-security-config>
```

Y agrega en el `AndroidManifest.xml`:

```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
```

## 🚀 Ejecutar la App

```bash
# Desarrollo (con hot reload)
flutter run

# Release
flutter build apk  # Android
flutter build ios  # iOS
```

## 🐛 Troubleshooting

### Error de conexión

1. Verifica que el backend esté corriendo
2. Verifica la URL en `api_config.dart`
3. Para emulador Android, usa `10.0.2.2` en lugar de `localhost`
4. Para dispositivo físico, usa la IP de tu máquina

### Tokens no persisten

- Verifica que las dependencias estén instaladas correctamente
- En iOS, verifica los permisos de Keychain

### Refresh token no funciona

- Verifica que el endpoint de refresh en el backend esté funcionando
- Verifica el formato de la respuesta del backend

## 📚 Dependencias Principales

```yaml
dependencies:
  http: ^1.2.2 # Cliente HTTP
  shared_preferences: ^2.3.3 # Storage simple
  flutter_secure_storage: ^9.2.2 # Storage seguro para tokens
  provider: ^6.1.2 # Gestión de estado
```

## 🔄 Flujo de Autenticación

```
1. Usuario ingresa credenciales
2. LoginPage llama a AuthService.login()
3. AuthService llama al repositorio
4. Repository llama al RemoteDataSource
5. RemoteDataSource hace petición HTTP al backend
6. Backend responde con tokens + datos de usuario
7. LocalDataSource guarda tokens (secure) y usuario (shared_prefs)
8. AuthService actualiza estado (isAuthenticated = true)
9. UI se actualiza automáticamente (Provider)
10. Usuario es redirigido al menú principal
```

## 🔐 Seguridad

- ✅ Access token en FlutterSecureStorage (encriptado)
- ✅ Refresh token en FlutterSecureStorage (encriptado)
- ✅ Datos de usuario en SharedPreferences (acceso rápido)
- ✅ Tokens nunca se exponen en logs
- ✅ Refresh automático de tokens
- ✅ Cierre de sesión en errores de autenticación

## 📝 Notas

- El Access Token se guarda en memoria segura y se adjunta automáticamente a todas las peticiones HTTP (excepto rutas públicas)
- El Refresh Token se usa automáticamente cuando el Access Token expira
- La opción "Recuérdame" usa un endpoint diferente que puede devolver tokens con mayor duración (según configuración del backend)
- Los Guards se pueden usar en cualquier página para protegerla por autenticación o roles
