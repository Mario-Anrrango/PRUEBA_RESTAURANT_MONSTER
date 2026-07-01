# Backend — Restaurant Monster

## Stack actual
- Java 21
- Jakarta EE 10 (Servlets + JSP)
- JDBC directo (sin JPA/Hibernate)
- MySQL 8
- Maven
- Tomcat 10+

## Estructura real encontrada
```
ec.edu.monster.restaurante
├── controlador/           → 9 Servlets
│   ├── AdminServlet.java
│   ├── EmpleadoServlet.java
│   ├── FacturaServlet.java
│   ├── LoginServlet.java
│   ├── LogoutServlet.java
│   ├── MenuServlet.java
│   ├── PedidoServlet.java
│   ├── RegistroClienteServlet.java
│   └── TomarPedidoServlet.java
│
├── dao/                  → 7 DAOs (JDBC directo)
│   ├── CategoriaDAO.java
│   ├── ClienteDAO.java
│   ├── ConexionDB.java       # Conexión MySQL (JDBC)
│   ├── EmpleadoDAO.java
│   ├── PedidoDAO.java
│   ├── PlatoDAO.java
│   └── UsuarioDAO.java
│
└── modelo/               → 7 POJOs (Serializable)
    ├── Categoria.java
    ├── Cliente.java
    ├── DetallePedido.java
    ├── Empleado.java
    ├── Pedido.java
    ├── Plato.java
    └── Usuario.java
```

## Migración JDBC → MongoDB Driver Sync

### Dependencias a cambiar (pom.xml)
- Eliminar: `mysql-connector-j`
- Agregar: `mongodb-driver-sync` (última versión estable)

### Conexión
- Eliminar: `ConexionDB.java`
- Crear: `MongoDBConnection.java` con `MongoClient` singleton

### DAOs
- Cambiar todos los DAOs JDBC por DAOs MongoDB
- Usar `MongoCollection<Document>` en lugar de `PreparedStatement`
- Usar `Filters`, `Updates`, `Projections` de `com.mongodb.client.model`
- Mapear `Document` ↔ POJO manualmente o con codec

### Conversión de tipos
| MySQL | MongoDB |
|---|---|
| INT AUTO_INCREMENT | ObjectId (campo `_id`) |
| VARCHAR | String |
| TEXT | String |
| DECIMAL | Decimal128 o String (para precios) |
| DATE | LocalDate (convertir a String ISO o Date) |
| TIME | LocalTime (convertir a String) |
| TIMESTAMP | LocalDateTime o Date |
| TINYINT(1) | Boolean |
| ENUM | String |

### ⚠️ Pitfalls
- NO usar JPA annotations (@Entity, @Table, etc.)
- Los IDs ahora son ObjectId, convertir a String en POJOs
- BigDecimal/Decimal128 requiere codec personalizado o usar String
- Fechas: decidir formato (ISO String o Date nativo)
- Transacciones: MongoDB las soporta pero son diferentes a MySQL
