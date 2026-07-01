# 🦍 Bitácora de Migración — MySQL → MongoDB

> Documento vivo. Cada paso completado se marca con [x] y fecha.
> Objetivo: que cualquier compañero pueda replicar la migración siguiendo estos pasos.

## Estado actual
- [x] Fase 1: Documentación y contexto
- [x] Fase 2: Preparar MongoDB local (script `scripts/mongo/01-setup.js`)
- [x] Fase 3: Adaptar backend Java
- [ ] Fase 4: Migrar datos
- [ ] Fase 5: Verificación

---

## Fase 1 — Documentación ✅
- [x] Creado `knowledge.md` raíz
- [x] Creado `backend/knowledge.md`
- [x] Creado `MIGRACION.md` (este archivo)

---

## Fase 2 — Preparar MongoDB local ✅
_Completada — script `scripts/mongo/01-setup.js`_

### 2.1 Instalación / conexión
- [x] Verificar MongoDB instalado localmente
- [x] Verificar conexión con `mongosh` o MongoDB Compass
- [x] Crear base de datos `restaurant_monster` (se crea automáticamente al insertar el primer documento)

### 2.2 Crear colecciones e índices
- [x] Crear colecciones: `usuarios`, `clientes`, `empleados`, `categorias`, `platos`, `pedidos`
- [x] Crear índice único en `usuarios.username`
- [x] Crear índice único en `clientes.cedula`
- [x] Crear índice único en `empleados.cedula`
- [x] Índices adicionales en perfil, id_categoria, activo, id_cliente, id_empleado, estado, fecha

### 2.3 Datos semilla
- [x] Insertar 5 categorías (ENTRADA, SOPA, PLATO FUERTE, POSTRE, BEBIDA)
- [x] Insertar 16 platos (con categoría referenciada por id_categoria)
- [x] Crear usuario admin (username: admin, password: admin123, perfil: ADMIN)

---

## Fase 3 — Adaptar backend Java ✅
_Completada — migración completa de JDBC a MongoDB Driver Sync_

### 3.1 Cambiar dependencias (pom.xml) ✅
- [x] Eliminar `mysql-connector-j`
- [x] Agregar `mongodb-driver-sync` 5.1.1

### 3.2 Cambiar conexión ✅
- [x] Eliminar `ConexionDB.java`
- [x] Crear `MongoDBConnection.java` con MongoClient singleton
- [x] Helpers: `filterById()`, `extractId()`, `extractString()`, `toLocalDateTime()`, `toLocalDate()`

### 3.3 Migrar POJOs ✅
- [x] Cambiar tipos de ID de `int` a `String` (ObjectId hex)
- [x] Ajustar tipos de fecha (LocalDate, LocalTime, LocalDateTime)
- [x] Ajustar tipos decimales (BigDecimal)
- [x] `int activo` → `boolean activo`

### 3.4 Migrar DAOs ✅
- [x] UsuarioDAO: JDBC → MongoDB
- [x] ClienteDAO: JDBC → MongoDB
- [x] EmpleadoDAO: JDBC → MongoDB
- [x] CategoriaDAO: JDBC → MongoDB
- [x] PlatoDAO: JDBC → MongoDB
- [x] PedidoDAO: JDBC → MongoDB (detalles embebidos)
- [x] DetallePedidoDAO: eliminado (se embebe en PedidoDAO)
- [x] Fechas almacenadas como String ISO para evitar dependencia de codec JSR-310
- [x] Helper `filterById()` maneja ObjectId y tipos mixtos

### 3.5 Ajustar Servlets ✅
- [x] LoginServlet: String IDs (sin cambios funcionales)
- [x] AdminServlet: BigDecimal, String IDs, LocalDate, boolean
- [x] EmpleadoServlet: String IDs, insertar() retorna String
- [x] PedidoServlet: BigDecimal aritmética, LocalDate/LocalTime, detalles embebidos
- [x] FacturaServlet: String IDs
- [x] MenuServlet: Map<String, List<Plato>>
- [x] RegistroClienteServlet: String IDs
- [x] TomarPedidoServlet: BigDecimal, String IDs, detalles embebidos

---

## Fase 4 — Migrar datos reales
_Pendiente_

### 4.1 Script de migración
- [ ] Crear script Java standalone o clase `DataMigrator` que lea de MySQL y escriba en MongoDB
- [ ] Migrar usuarios
- [ ] Migrar clientes
- [ ] Migrar empleados
- [ ] Migrar categorías
- [ ] Migrar platos
- [ ] Migrar pedidos (con detalles embebidos)

### 4.2 Verificar migración
- [ ] Contar documentos en cada colección vs registros en MySQL
- [ ] Verificar integridad referencial (usuarios → clientes, etc.)

---

## Fase 5 — Verificación
_Pendiente_

- [ ] Compilar proyecto completo: `mvn clean compile`
- [ ] Desplegar en Tomcat
- [ ] Probar login (admin/admin123)
- [ ] Probar registro de cliente
- [ ] Probar creación de pedido (empleado)
- [ ] Probar facturación
- [ ] Probar menú público
- [ ] Probar gestión de platos (admin)
- [ ] Probar listado de clientes/empleados (admin)

---

## Notas importantes

### Diferencias clave MySQL → MongoDB en este proyecto

| Aspecto | MySQL (actual) | MongoDB (futuro) |
|---|---|---|
| IDs | `int` AUTO_INCREMENT | `ObjectId` (String 24 hex) |
| Conexión | `ConexionDB.java` (JDBC) | `MongoDBConnection.java` (driver sync) |
| Queries | SQL en DAOs | `find()`, `insertOne()`, etc. |
| Pedidos + detalles | 2 tablas (JOIN) | 1 colección (detalles[] embebido) |
| Categoría en platos | FK a categorias | Referencia por id o embebido |
| Fechas | `String` en POJOs | String ISO o `Date` BSON |
| Precios | `double` | `double` (o `Decimal128`) |

### Stack tecnológico actual
- Java 21 + Jakarta EE 10 + Servlets/JSP/JSTL
- Apache Tomcat 10+
- MySQL 8 con JDBC (mysql-connector-j 8.3.0)
- Maven
- **No usa Spring Boot ni JPA/Hibernate**
