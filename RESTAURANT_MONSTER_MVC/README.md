# Restaurant Monster — Migración a MongoDB

## 📋 Descripción
Sistema de gestión para restaurante migrado de MySQL a MongoDB.

## 🏗️ Arquitectura
- **Backend**: Java 21 + Jakarta EE 10 (Servlets + JSP)
- **Base de Datos**: MongoDB 7+ (driver sync 5.5.1)
- **Servidor**: Payara Server 7.2026.3
- **Build**: Maven

## 📦 Requisitos
- Java 21
- MongoDB 7+ instalado localmente
- Payara Server 7.2026.3
- Maven
- MongoDB Compass (opcional, para ver datos)

## 🚀 Instalación y Despliegue

### 1. Instalar MongoDB
```bash
# Descargar de: https://www.mongodb.com/try/download/community
# Instalar y verificar:
mongosh --eval "db.runCommand({ping:1})"
```

### 2. Crear base de datos y datos semilla
```bash
mongosh restaurant_monster scripts/mongo/01-setup.js
```

### 3. Compilar proyecto
```bash
cd C:\Users\Admin\Documents\GitHub\PRUEBA_RESTAURANT_MONSTER\RESTAURANT_MONSTER_MVC
mvn clean compile
```

### 4. Desplegar en Payara
- Abrir NetBeans
- Click derecho en proyecto → Clean and Build
- Click derecho → Deploy

### 5. Acceder a la aplicación
- Admin: http://localhost:8081/RESTAURANT_MONSTER_MVC/admin
- Login: admin / admin123

## 👥 Usuarios por defecto

| Usuario | Contraseña | Perfil |
|---------|------------|--------|
| admin   | admin123   | ADMIN  |

## 🗄️ Colecciones en MongoDB

- **usuarios**: Login de todos los perfiles
- **clientes**: Datos de clientes (incluye identificación extranjera)
- **empleados**: Datos de empleados/meseros
- **categorias**: 5 categorías (ENTRADA, SOPA, PLATO FUERTE, POSTRE, BEBIDA)
- **platos**: Menú del restaurante
- **pedidos**: Pedidos con detalles embebidos

## 🧪 Pruebas rápidas

1. **Admin**: Gestionar platos, clientes, empleados
2. **Cliente**: Registrarse, ver menú, hacer pedido, ver reservas
3. **Empleado**: Buscar clientes, tomar pedidos

## 🔐 Seguridad

### Contraseñas
- Todas las contraseñas están encriptadas con BCrypt
- Las contraseñas existentes se migran automáticamente al primer login
- El admin puede resetear contraseñas de clientes/empleados

## 📁 Estructura de Archivos

### Imágenes
- Ubicación: `C:/restaurant_images/platos/`
- Las imágenes se guardan fuera del WAR para persistencia
- Solo se almacena la ruta relativa en MongoDB

## 🔧 Configuración

Archivo: `src/main/java/ec/edu/monster/restaurante/dao/MongoDBConnection.java`
```java
private static final String URI = "mongodb://localhost:27017";
private static final String DATABASE_NAME = "restaurant_monster";
```

## 🧪 Validaciones

### Cliente
- Cédula ecuatoriana válida (10 dígitos con verificación módulo 10)
- O identificación extranjera (5-20 chars alfanuméricos)
- Email válido
- Teléfono: 10 dígitos
- Contraseña segura (8+ chars, mayúscula, carácter especial)

### Empleado
- Mismas validaciones que cliente
- Cargo: Mesero o Admin
- Fecha de ingreso automática

### Plato
- Nombre: 4-50 chars (solo letras)
- Descripción: 10-300 chars
- Precio: 0.00 a 99.99
- Imagen: JPG, PNG (max 5MB)

## 📊 Paginación

Todas las listas tienen paginación:
- Clientes: 5-50 registros
- Empleados: 5-50 registros
- Reservas: 5-25 registros

## 🔄 Modificación de Pedidos

### Cliente
- Solo pedidos PENDIENTES
- Dentro de las 24 horas de creación
- Sección "Mis Reservas"

### Mesero
- Solo pedidos PENDIENTES
- Sin límite de tiempo
- Desde "Buscar Cliente" → "Detalles"

## 📝 Notas importantes

- Los IDs son String (ObjectId de MongoDB), no int
- Las fechas se guardan como Date en MongoDB
- Los precios son BigDecimal (Decimal128 en MongoDB)
- Los detalles de pedido están embebidos en la colección "pedidos"
- El campo "activo" es boolean (true/false)
- Las imágenes se guardan en `C:/restaurant_images/platos/`
- BCrypt para encriptación de contraseñas

## 📞 Soporte

Para dudas o problemas, revisar los logs de Payara en:
```
C:\Users\Admin\Payara_Server\glassfish\domains\domain1\logs\server.log
```
