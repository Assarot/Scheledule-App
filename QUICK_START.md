# 🚀 Inicio Rápido - Autenticación

## 1️⃣ Configurar URL del Backend

Edita `lib/utils/api_config.dart`:

```dart
static const String baseUrl = 'http://10.0.2.2:8080'; // Para emulador Android
```

Opciones:

- **Emulador Android**: `http://10.0.2.2:8080`
- **Dispositivo físico**: `http://192.168.1.X:8080` (IP de tu máquina)
- **iOS Simulator**: `http://localhost:8080`

## 2️⃣ Instalar Dependencias

```bash
flutter pub get
```

## 3️⃣ Ejecutar

```bash
flutter run
```

## 📋 Funcionalidades Implementadas

✅ Login con backend real
✅ Almacenamiento seguro de tokens
✅ Refresh automático de tokens
✅ Interceptor HTTP (como Angular)
✅ Guards para proteger rutas
✅ Manejo de roles (ADMIN, etc.)
✅ Página de perfil con logout
✅ Manejo de errores y estados de carga

## 🎯 Uso Básico

### Login

Ya está integrado en `LoginPage`. Solo ingresa credenciales y automáticamente:

- Conecta con el backend
- Guarda tokens de forma segura
- Redirige al menú principal

### Ver Información del Usuario

Navega a la pestaña "Perfil" para ver:

- Datos del usuario
- Roles asignados
- Opción de cerrar sesión

### Proteger una Página

```dart
import '../../utils/auth_guard.dart';

// En tu página
AuthGuard(
  child: MyProtectedPage(),
)

// Solo para admins
AdminGuard(
  child: MyAdminPage(),
)
```

### Hacer Peticiones HTTP Autenticadas

Ver archivo: `lib/utils/example_api_service.dart`

## 📱 Permisos Android

Ya configurados en `AndroidManifest.xml`:

- ✅ Permiso de Internet
- ✅ Tráfico HTTP permitido (para desarrollo)

## 🔐 Seguridad

- Access Token: Guardado en FlutterSecureStorage (encriptado)
- Refresh Token: Guardado en FlutterSecureStorage (encriptado)
- Usuario: SharedPreferences (acceso rápido)
- Tokens se agregan automáticamente a todas las peticiones HTTP

## 📖 Documentación Completa

Ver `AUTHENTICATION_README.md` para más detalles.

## ❓ Problemas Comunes

**No conecta al backend:**

1. Verifica que el backend esté corriendo
2. Verifica la URL en `api_config.dart`
3. Para Android emulador, usa `10.0.2.2` en lugar de `localhost`

**Error de credenciales:**

- Verifica que el usuario exista en tu backend
- Verifica el formato de email/contraseña

**Token no se refresca:**

- Verifica que el endpoint `/auth/refresh` funcione en tu backend
- Verifica que el refresh token esté guardándose correctamente
