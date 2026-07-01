# Restaurant Monster — Knowledge Base

## 🎯 Project Overview
Sistema de gestión para restaurante "Monster" con 3 perfiles: ADMIN, EMPLEADO (mesero), CLIENTE.
Actualmente en **Java + Jakarta EE 10 + Servlets/JSP + MySQL (JDBC)**.
**Estamos migrando a MongoDB** manteniendo toda la lógica de negocio.

## 🏗️ Architecture
- **Backend**: Java 21 + Jakarta EE 10 (Servlets + JSP)
- **BD anterior**: MySQL 8 (JDBC directo, sin JPA)
- **BD nueva**: MongoDB 7+ (MongoDB Driver Sync)
- **Servidor**: Tomcat 10+
- **Build**: Maven, empaquetado WAR
- **Charset**: UTF-8

## 📁 Project Structure
```
RESTAURANT_MONSTER_MVC/
├── pom.xml                          # Maven, Java 21, WAR
├── restaurant_monster.sql           # Script DDL + datos semilla MySQL
├── src/
│   └── main/
│       ├── java/
│       │   └── ec/edu/monster/restaurante/
│       │       ├── controlador/          # Servlets (9 archivos)
│       │       │   ├── AdminServlet.java
│       │       │   ├── EmpleadoServlet.java
│       │       │   ├── FacturaServlet.java
│       │       │   ├── LoginServlet.java
│       │       │   ├── LogoutServlet.java
│       │       │   ├── MenuServlet.java
│       │       │   ├── PedidoServlet.java
│       │       │   ├── RegistroClienteServlet.java
│       │       │   └── TomarPedidoServlet.java
│       │       ├── dao/                  # DAOs JDBC (7 archivos)
│       │       │   ├── CategoriaDAO.java
│       │       │   ├── ClienteDAO.java
│       │       │   ├── ConexionDB.java
│       │       │   ├── EmpleadoDAO.java
│       │       │   ├── PedidoDAO.java
│       │       │   ├── PlatoDAO.java
│       │       │   └── UsuarioDAO.java
│       │       └── modelo/              # POJOs (7 archivos)
│       │           ├── Categoria.java
│       │           ├── Cliente.java
│       │           ├── DetallePedido.java
│       │           ├── Empleado.java
│       │           ├── Pedido.java
│       │           ├── Plato.java
│       │           └── Usuario.java
│       └── webapp/
│           ├── css/
│           │   └── estilos.css
│           ├── index.jsp
│           ├── WEB-INF/
│           │   └── web.xml
│           └── vistas/
│               ├── admin/
│               │   ├── dashboard.jsp
│               │   ├── form-plato.jsp
│               │   ├── gestion-platos.jsp
│               │   ├── lista-clientes.jsp
│               │   ├── lista-empleados.jsp
│               │   ├── registrar-cliente.jsp
│               │   └── registrar-empleado.jsp
│               ├── cliente/
│               │   ├── factura.jsp
│               │   └── menu.jsp
│               ├── empleado/
│               │   ├── buscar-cliente.jsp
│               │   ├── dashboard.jsp
│               │   ├── registrar-cliente.jsp
│               │   └── tomar-pedido.jsp
│               ├── error.jsp
│               ├── login.jsp
│               └── registro-cliente.jsp
```

## 🔄 Migración MySQL → MongoDB (mapeo)

| Tabla MySQL | Colección MongoDB | Notas |
|---|---|---|
| usuarios | usuarios | Login, perfiles ENUM → String |
| clientes | clientes | Referencia a usuarios por id |
| empleados | empleados | Referencia a usuarios por id |
| categorias | categorias | Pocas, casi estáticas |
| platos | platos | Categoría puede ir embebida {id, nombre} |
| pedidos + detalle_pedido | pedidos | detalles[] embebido como array |

## 📌 Coding Standards
- Nombres de colecciones en **plural minúscula** (usuarios, platos, pedidos)
- Campos en **camelCase** (estándar Java/JSON)
- IDs: usar `String` con representación hexadecimal de ObjectId (actualmente `int`)
- Fechas: `String` con formato ISO (`yyyy-MM-dd`, `HH:mm:ss`) o migrar a `LocalDate`/`LocalTime`
- Decimales: actualmente `double`, migrar a `BigDecimal` para precios
- Estados: usar `String` (actualmente son String: PENDIENTE, PAGADO, CANCELADO)

## 🛠️ Build & Run
```bash
# Compilar el proyecto
mvn clean compile

# Empaquetar WAR
mvn clean package

# El WAR se genera en target/RESTAURANT_MONSTER_MVC-1.0-SNAPSHOT.war
# Desplegar en Apache Tomcat 10+ (para Jakarta EE)
```

## ✅ Verifying Changes
Después de cada cambio relevante:
- Compilar el proyecto sin errores: `mvn clean compile`
- Verificar que no haya errores en los imports
- Levantar la app en Tomcat y probar funcionalidades principales

## 📚 Referencias
- SQL original: `restaurant_monster.sql`
- Datos semilla: usuario admin/admin123, 5 categorías, ~18 platos
- Puerto MySQL: 3306, usuario: root, password: rootroot
