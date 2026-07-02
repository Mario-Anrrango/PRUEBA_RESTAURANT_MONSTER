# 🦍 Bitácora de Migración — MySQL → MongoDB

> Documento vivo. Cada paso completado se marca con [x] y fecha.
> Objetivo: que cualquier compañero pueda replicar la migración siguiendo estos pasos.

## Estado actual
- [x] Fase 1: Documentación y contexto
- [x] Fase 2: Preparar MongoDB local (script `scripts/mongo/01-setup.js`)
- [x] Fase 3: Adaptar backend Java
- [x] Fase 4: Verificación y pruebas
- [x] Fase 5: Documentación final ✅
- [x] Fase 6: Mejoras y Validaciones Completas ✅

---

## Fase 1 — Documentación ✅
- [x] Creado `knowledge.md` raíz
- [x] Creado `backend/knowledge.md` (no aplica, proyecto sin backend separado)
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
- [x] Agregar `spring-security-crypto` 6.2.0 (BCrypt)

### 3.2 Cambiar conexión ✅
- [x] Eliminar `ConexionDB.java`
- [x] Crear `MongoDBConnection.java` con MongoClient singleton
- [x] Helpers: `filterById()`, `extractId()`, `extractString()`, `toLocalDateTime()`, `toLocalDate()`, `toLocalTime()`

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

### 3.5 Ajustar Servlets ✅
- [x] LoginServlet, AdminServlet, EmpleadoServlet, PedidoServlet, FacturaServlet, MenuServlet, RegistroClienteServlet, TomarPedidoServlet

---

## Fase 4 — Verificación y pruebas ✅
_Completada — scripts de test y corrección de errores_

### 4.1 Scripts de prueba
- [x] Crear `TestMongoDBConnection.java` — verifica conexión y colecciones
- [x] Crear `TestDAOs.java` — prueba todos los DAOs

### 4.2 Correcciones post-migración
- [x] Agregar `buscarPorUsername()` a UsuarioDAO
- [x] Corregir lectura de fechas BSON Date en todos los DAOs
- [x] Manejo dual Date/String en helpers `toLocalDateTime(doc, field)`
- [x] Agregar `getActivo()` a Plato.java (boolean → JSP compatible)
- [x] Corregir `PlatoDAO.listarPorCategoria()` — type mismatch numérico vs string
- [x] Corregir JSPs (`activo` como boolean, `id` como String, `precio` como BigDecimal)
- [x] Corregir `factura.jsp` — `%06d` con String, `%.2f` con BigDecimal
- [x] Cargar datos del cliente en `PedidoDAO.mapearPedido()`

---

## Fase 5 — Documentación final ✅
- [x] Actualizar `MIGRACION.md` con estado final
- [x] Crear `README.md` con guía completa para compañeros

---

## Fase 6 — Mejoras y Validaciones Completas ✅

### 6.1 Seguridad — BCrypt
- [x] `PasswordUtil.java` con hash() y verify() usando Spring Security Crypto
- [x] LoginServlet: verifica con BCrypt, migra contraseñas planas automáticamente
- [x] RegistroClienteServlet: hashea contraseñas antes de guardar
- [x] AdminServlet: hashea contraseñas al crear clientes/empleados
- [x] EmpleadoServlet: hashea contraseñas al crear clientes
- [x] Soporte para reset de contraseña por admin
- [x] Migración automática: contraseñas existentes se convierten a BCrypt al primer login

### 6.2 Persistencia de Imágenes
- [x] `ImageHandler.java` — guarda imágenes en `C:/restaurant_images/platos/`
- [x] Soporte multipart en AdminServlet (subir foto al crear/editar plato)
- [x] Validación de extensión (JPG, JPEG, PNG) y tamaño (max 5MB)
- [x] Eliminación automática de imágenes anteriores
- [x] Ruta relativa almacenada en MongoDB (`platos/xxx.jpg`)

### 6.3 Identificación Extranjera
- [x] Nuevos campos en Cliente.java: `identificacionExtranjera`, `esExtranjero`
- [x] Nuevos campos en Empleado.java: `identificacionExtranjera`, `esExtranjero`
- [x] ClienteDAO: guarda/lee ambos campos, busca por identificación extranjera
- [x] EmpleadoDAO: guarda/lee ambos campos, busca por identificación extranjera
- [x] Checkbox "Soy extranjero" en todos los formularios de registro
- [x] Búsqueda dual en EmpleadoServlet: detecta cédula (10 dígitos) vs identificación extranjera

### 6.4 Validaciones en Tiempo Real
- [x] `validaciones.js` — 16 funciones de validación
- [x] `validaciones.css` — estilos para mensajes de error
- [x] Solo letras, solo números, decimal, email, cédula ecuatoriana, contraseña
- [x] Validación de cédula con algoritmo de módulo 10
- [x] Mensajes de error debajo de cada input
- [x] Contador de caracteres en textarea
- [x] Incluido en TODOS los JSPs con formularios

### 6.5 CRUD Completo — Clientes
- [x] Editar cliente (sin modificar cédula/usuario)
- [x] Resetear contraseña desde lista de clientes
- [x] Modal reset-password con validaciones
- [x] Búsqueda por cédula o identificación
- [x] Paginación: 5, 10, 25, 50 registros

### 6.6 CRUD Completo — Empleados
- [x] Editar empleado (sin modificar cédula/usuario)
- [x] Cargos limitados a: Mesero, Admin
- [x] Fecha de ingreso automática (LocalDate.now())
- [x] Resetear contraseña desde lista de empleados
- [x] Búsqueda por cédula o identificación

### 6.7 Gestión de Platos — Mejoras
- [x] Botón dinámico Activar/Desactivar según estado
- [x] Upload de imagen con File input y preview
- [x] Vista previa en tiempo real (nombre, precio, categoría, descripción)
- [x] Contador de caracteres en descripción
- [x] Validaciones JS (solo letras, decimal, longitudes)

### 6.8 Panel de Cliente — Mis Reservas
- [x] Nueva página `reservas.jsp` con historial de pedidos
- [x] Filtros por fecha (rango) y estado
- [x] Botón "Modificar" si pedido PENDIENTE < 24h
- [x] Botón "Cancelar Pedido"
- [x] Página `ver-reserva.jsp` con detalle completo
- [x] Enlace "Mis Reservas" en navbar del cliente

### 6.9 Panel de Mesero — Mejoras
- [x] Búsqueda dual: detecta automáticamente cédula vs identificación extranjera
- [x] Botón "Editar Datos" en cliente encontrado
- [x] Botón "Editar Pedido" en historial (si PENDIENTE)
- [x] Validaciones JS en formulario de registro de cliente

### 6.10 Validación de Precios en Pedidos
- [x] `PedidoDAO.insertar()` guarda precio_unitario del momento
- [x] `factura.jsp` muestra precios guardados (no del plato actual)

### 6.11 Archivos Creados
- `src/main/java/ec/edu/monster/restaurante/util/ImageHandler.java`
- `src/main/java/ec/edu/monster/restaurante/util/PasswordUtil.java`
- `src/main/java/ec/edu/monster/restaurante/controlador/ReservasServlet.java`
- `src/main/webapp/js/validaciones.js`
- `src/main/webapp/css/validaciones.css`
- `src/main/webapp/vistas/cliente/reservas.jsp`
- `src/main/webapp/vistas/cliente/ver-reserva.jsp`
- `src/main/webapp/vistas/admin/modal-reset-password.jsp`

### 6.12 Archivos Modificados
- `src/main/java/ec/edu/monster/restaurante/modelo/Cliente.java`
- `src/main/java/ec/edu/monster/restaurante/modelo/Empleado.java`
- `src/main/java/ec/edu/monster/restaurante/dao/ClienteDAO.java`
- `src/main/java/ec/edu/monster/restaurante/dao/EmpleadoDAO.java`
- `src/main/java/ec/edu/monster/restaurante/dao/UsuarioDAO.java`
- `src/main/java/ec/edu/monster/restaurante/dao/PedidoDAO.java`
- `src/main/java/ec/edu/monster/restaurante/dao/PlatoDAO.java`
- `src/main/java/ec/edu/monster/restaurante/controlador/AdminServlet.java`
- `src/main/java/ec/edu/monster/restaurante/controlador/LoginServlet.java`
- `src/main/java/ec/edu/monster/restaurante/controlador/EmpleadoServlet.java`
- `src/main/java/ec/edu/monster/restaurante/controlador/RegistroClienteServlet.java`
- `src/main/webapp/vistas/admin/gestion-platos.jsp`
- `src/main/webapp/vistas/admin/lista-clientes.jsp`
- `src/main/webapp/vistas/admin/lista-empleados.jsp`
- `src/main/webapp/vistas/admin/form-plato.jsp`
- `src/main/webapp/vistas/admin/registrar-cliente.jsp`
- `src/main/webapp/vistas/admin/registrar-empleado.jsp`
- `src/main/webapp/vistas/empleado/buscar-cliente.jsp`
- `src/main/webapp/vistas/empleado/registrar-cliente.jsp`
- `src/main/webapp/vistas/empleado/tomar-pedido.jsp`
- `src/main/webapp/vistas/cliente/menu.jsp`
- `src/main/webapp/vistas/registro-cliente.jsp`
- `.gitignore`

### 6.13 Fase 6.3 — Auditoría y Reorganización de Archivos Estáticos ✅

#### Archivos CSS Creados
- `css/print.css` — Estilos de impresión (@media print) extraídos de factura.jsp y ver-reserva.jsp
- `css/paginacion.css` — Estilos de paginación para listas admin

#### Archivos JS Creados
- `js/confirmaciones.js` — 12 funciones SweetAlert (activar/desactivar/edit/reset/pago/cancelar) para toda la app
- `js/extranjero.js` — Función toggleExtranjero() compartida por 5 formularios de registro
- `js/menu.js` — Funciones de selección de platos y cantidades (toggleCantidad, cambiarCantidad, actualizarBarra) usadas en menu.jsp y tomar-pedido.jsp
- `js/modal.js` — Funciones del modal reset-password (abrir/cerrar/validar)
- `js/form-plato.js` — Preview de imagen, preview en vivo y contador de caracteres

#### Cambios Realizados
- Extraído TODO CSS inline de gestion-platos, lista-clientes, lista-empleados, form-plato, menu.jsp, tomar-pedido.jsp, factura.jsp, ver-reserva.jsp
- Extraído TODO JS inline de 15 JSPs a archivos externos
- Agregado `contextPath` como variable global en JSPs antes de cargar confirmaciones.js
- Agregado `body { padding-bottom: 90px; }` y estilos `.plato-card.seleccionado` a estilos.css
- Vinculados archivos externos en todos los JSPs correspondientes
- Mantenido inline solo SweetAlert message display (usa EL expressions) y lógica específica de página (validación de fechas en reservas.jsp)

### 6.14 Fase 6.4 — Correcciones Críticas Prioritarias ✅

### 6.15 Fase 6.5 — Mejoras en Formulario de Registro de Cliente ✅

#### Problemas Corregidos

**1. Tamaño de campo Cédula** — Corregido: ahora ocupa el mismo ancho que identificación extranjera (50% del form-row)

**2. Comportamiento checkbox "Soy Extranjero"** —
- `extranjero.js`: toggleExtranjero() ahora agrega clase CSS `field-disabled` (gris/opaco) y `label-disabled` al label
- Limpia errores (limpiarError) al alternar
- Usa clases CSS en lugar de solo atributos `disabled`

**3. Validaciones on blur con AJAX** — 8 nuevas funciones en validaciones.js:
- `validarCedulaOnBlur()`: valida 10 dígitos, módulo 10 + AJAX existencia en BD
- `validarIdentificacionOnBlur()`: valida 5-20 chars + AJAX existencia
- `validarNombresOnBlur()`: mínimo 4 chars, solo letras
- `validarApellidosOnBlur()`: mínimo 4 chars, solo letras
- `validarTelefonoOnBlur()`: exactamente 10 dígitos
- `validarUsuarioOnBlur()`: mínimo 4 chars, sin espacios + AJAX existencia
- `validarCorreoOnBlur()`: formato email + AJAX existencia
- `validarDireccionOnBlur()`: mínimo 10 chars

**4. Dirección cambiada a textarea** — input text → textarea con:
- `style="min-height:90px;resize:vertical;"` (~3-4 líneas)
- Contador de caracteres vía `actualizarContador()`
- onblur valida mínimo 10 caracteres

**5. Botón "Ver" contraseña** — Agregado:
- `password-wrapper` (position: relative)
- Botón `password-toggle` con ícono 👁️ dentro del wrapper
- `togglePasswordVisibility(id)`: alterna password/text y cambia ícono 👁️ ↔ 🙈

**6. Validación de formulario completa** — `validarFormularioRegistro()`:
- Deshabilita botón "Registrarme" durante envío
- Valida TODOS los campos antes de enviar
- Si hay errores, muestra SweetAlert con lista
- Previene envío duplicado

**7. AJAX endpoints en Servlet** — `RegistroClienteServlet.doGet()`:
- `?accion=validarCedula&cedula=XXX` → JSON {valid, message}
- `?accion=validarIdentificacion&id=XXX` → JSON {valid, message}
- `?accion=validarUsuario&usuario=XXX` → JSON {valid, message}
- `?accion=validarCorreo&correo=XXX` → JSON {valid, message}

#### Archivos Modificados
- `registro-cliente.jsp` — formulario completo reescrito
- `RegistroClienteServlet.java` — doGet con AJAX endpoints + validadores
- `validaciones.js` — 8 nuevas funciones de validación on blur + AJAX + pre-submit
- `extranjero.js` — visual disabled state con clases CSS
- `validaciones.css` — field-disabled, label-disabled, password-wrapper/toggle, valid-message, checkbox-extranjero
- `MIGRACION.md` — esta sección

---
- Creado `PlatoDAO.listarActivosAgrupados()` que obtiene todos los platos activos y los agrupa por categoría, evitando problemas de type mismatch con id_categoria
- `MenuServlet` ahora usa `listarActivosAgrupados()` en lugar de `listarPorCategoria()` por categoría

#### PROBLEMA 2 — Modificar pedido no carga items existentes
- `MenuServlet.doGet()` ahora maneja `?modificar=id`: carga el pedido, valida PENDIENTE y < 24h, guarda detalles en request
- `menu.jsp`: pre-carga checkboxes marcados y cantidades correctas al modificar
- `PedidoServlet.doPost()`: detecta `pedidoModificando` en sesión y ACTUALIZA el pedido existente (no crea nuevo)
- `PedidoDAO.actualizarTodo()`: nuevo método que actualiza detalles completos, subtotal, IVA, servicio, total
- Script inline en menu.jsp inicializa `seleccionados` con items pre-marcados para que barra inferior funcione

#### PROBLEMA 3 — Botones Activar/Desactivar muestran ambos
- `AdminServlet.listarClientes()` y `listarEmpleados()` ahora pasan `Map<String, Boolean> estadosActivos` al JSP
- `lista-clientes.jsp` y `lista-empleados.jsp`: `<% if (isActivo) %>` muestra solo el botón correspondiente

#### PROBLEMA 4 — Modal blanco en Empleados
- Revisado: modal-reset-password.jsp con `display:none` correcto, window.onclick solo cierra modal

#### PROBLEMA 5 — Resetear Contraseña con modal personalizado
- Botones en lista-clientes.jsp y lista-empleados.jsp ahora llaman `abrirModalReset()` en vez de `confirmarResetPassword()`
- Modal HTML personalizado (modal-reset-password.jsp) con campos Nueva Contraseña + Confirmar, validaciones JS

#### PROBLEMA 6 — Cédula deshabilitada en edición
- `registrar-cliente.jsp` y `registrar-empleado.jsp`: campo cédula tiene `disabled readonly` cuando `esEdicion=true`
- Mensaje "No se puede modificar la identificación"

#### PROBLEMA 7 — Perfil de Empleado no se actualiza
- `AdminServlet.actualizarEmpleado()` ahora sincroniza `usuario.perfil` cuando cambia el cargo
- Cargo "Admin" → perfil "ADMIN", cargo "Mesero" → perfil "EMPLEADO"
- `UsuarioDAO.actualizarPerfil()`: nuevo método para actualizar el perfil en MongoDB

#### PROBLEMA 8 — Botón Limpiar Filtro en búsquedas
- `lista-clientes.jsp` y `lista-empleados.jsp`: botón "✕ Limpiar" visible solo cuando hay búsqueda activa
- Al hacer clic, redirige sin filtros

#### Archivos Modificados
- `PlatoDAO.java` — listarActivosAgrupados(), refactor listarPorCategoria()
- `MenuServlet.java` — ?modificar= handling, usa listarActivosAgrupados()
- `PedidoServlet.java` — detecta modificación vs creación
- `PedidoDAO.java` — actualizarTodo()
- `UsuarioDAO.java` — actualizarPerfil()
- `AdminServlet.java` — estadosActivos map, sync perfil empleado
- `lista-clientes.jsp` — botón único Activar/Desactivar, abrirModalReset, Limpiar filtro
- `lista-empleados.jsp` — botón único Activar/Desactivar, abrirModalReset, Limpiar filtro
- `menu.jsp` — pre-check items modificación + init seleccionados
- `registrar-cliente.jsp` — cédula disabled en edición
- `registrar-empleado.jsp` — cédula disabled en edición

---

## 📖 GUÍA DE PRUEBAS COMPLETAS

### 5.1 — Pruebas como ADMINISTRADOR

**Login:**
- URL: http://localhost:8081/RESTAURANT_MONSTER_MVC/admin
- Usuario: admin
- Contraseña: admin123

**Gestión de Platos:**
1. Ver listado de platos (debe mostrar categorías)
2. Crear nuevo plato con imagen
3. Editar plato existente
4. Desactivar/Activar plato
5. Verificar preview en tiempo real

**Gestión de Clientes:**
1. Ver listado de clientes
2. Registrar nuevo cliente (nacional y extranjero)
3. Editar datos del cliente
4. Resetear contraseña

**Gestión de Empleados:**
1. Ver listado de empleados
2. Registrar nuevo empleado (Mesero/Admin)
3. Editar datos del empleado
4. Resetear contraseña

### 5.2 — Pruebas como CLIENTE

**Registro:**
1. Acceder a registro de cliente
2. Crear cuenta nueva (nacional y extranjero)
3. Iniciar sesión

**Menú y Pedido:**
1. Ver menú de platos (debe mostrar platos activos)
2. Agregar platos al pedido
3. Ajustar cantidades
4. Enviar pedido
5. Ver factura (debe mostrar datos del cliente)
6. Ver "Mis Reservas" con historial

**Modificación de Pedido:**
1. Ir a "Mis Reservas"
2. Si pedido PENDIENTE < 24h: Modificar
3. Cancelar pedido

### 5.3 — Pruebas como EMPLEADO (MESERO)

**Login:**
- Crear usuario con perfil EMPLEADO
- Iniciar sesión con credenciales de empleado

**Panel de Empleado:**
1. Registrar cliente (con validaciones JS)
2. Buscar cliente por cédula o identificación extranjera
3. Tomar pedido
4. Modificar pedido existente (si PENDIENTE)
5. Ver historial de pedidos del cliente

### 5.4 — Pruebas de Validaciones

1. Cédula ecuatoriana: ingresar 10 dígitos inválidos → error
2. Email inválido: ingresar "correo@" → error
3. Contraseña débil: menos de 8 chars → error
4. Identificación extranjera: toggle checkbox → campos se habilitan/deshabilitan
5. Precio: ingresar letras → se filtran automáticamente
6. Nombres: ingresar números → se filtran automáticamente

### 5.5 — Flujo Completo

1. Admin crea platos activos (con imagen)
2. Cliente se registra (nacional o extranjero)
3. Cliente hace pedido desde menú
4. Empleado busca al cliente
5. Empleado ve el pedido en historial
6. Admin ve la factura
7. Admin resetea contraseña si es necesario
8. Cliente modifica/cancela pedido desde "Mis Reservas"
