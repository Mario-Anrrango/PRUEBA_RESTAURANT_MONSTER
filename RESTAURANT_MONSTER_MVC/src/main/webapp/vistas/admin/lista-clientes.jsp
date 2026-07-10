<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.*,java.util.*" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"ADMIN".equals(usuario.getPerfil())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    List<Cliente> clientes = (List<Cliente>) request.getAttribute("clientes");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Lista de Clientes – Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/validaciones.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/paginacion.css">
</head>
<body>
<div class="encabezado">
    <h1>Restaurant Master Monster</h1>
    <img src="${pageContext.request.contextPath}/img/LOGO_EMPRESA/Monster.jpg" alt="Logo" class="logo-encabezado">
</div>
<nav class="navbar">
    <ul class="navbar-links">
        <li><a href="${pageContext.request.contextPath}/admin">Inicio</a></li>
        <li><a href="${pageContext.request.contextPath}/admin?accion=listarPlatos">Platos</a></li>
        <li><a href="${pageContext.request.contextPath}/admin?accion=listarClientes" class="activo">Clientes</a></li>
        <li><a href="${pageContext.request.contextPath}/admin?accion=listarEmpleados">Empleados</a></li>
        <li><a href="${pageContext.request.contextPath}/logout">Cerrar Sesión</a></li>
    </ul>
    <span class="navbar-user">Admin: <%= usuario.getUsername() %></span>
</nav>

<div class="contenedor" style="margin-top:25px;">
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:15px;">
        <h2 class="titulo-seccion" style="margin-bottom:0;">Clientes Registrados</h2>
        <a href="${pageContext.request.contextPath}/admin?accion=formCliente" class="btn btn-primario">+ Nuevo Cliente</a>
    </div>    <!-- Mensajes SweetAlert (validación JS para evitar modal blanco) -->
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        var mensaje = '${sessionScope.mensaje}';
        var tipoMensaje = '${sessionScope.tipoMensaje}';
        if (mensaje && mensaje.trim() !== '' && mensaje !== 'null') {
            var icono = 'info';
            if (tipoMensaje === 'success') icono = 'success';
            else if (tipoMensaje === 'error') icono = 'error';
            else if (tipoMensaje === 'warning') icono = 'warning';
            Swal.fire({
                icon: icono,
                title: tipoMensaje === 'success' ? '\u00c9xito' :
                       tipoMensaje === 'error' ? 'Error' :
                       tipoMensaje === 'warning' ? 'Advertencia' : 'Informaci\u00f3n',
                text: mensaje,
                timer: 3000,
                showConfirmButton: false
            });
        }
    });
    </script>
    <c:remove var="mensaje" scope="session"/>
    <c:remove var="tipoMensaje" scope="session"/>

    <!-- Búsqueda -->
    <form method="get" action="${pageContext.request.contextPath}/admin" class="busqueda-form" style="margin-bottom:15px;">
        <input type="hidden" name="accion" value="listarClientes">
        <div class="form-grupo">
            <input type="text" name="busqueda" class="form-control" placeholder="Buscar por cédula o identificación..."
                   value="<%= request.getParameter("busqueda") != null ? request.getParameter("busqueda") : "" %>"
                   oninput="this.value = this.value.replace(/[^a-zA-Z0-9]/g, '').trim()">
        </div>
        <button type="submit" class="btn btn-primario" style="height:44px;">Buscar</button>
        <% if (request.getParameter("busqueda") != null && !request.getParameter("busqueda").isEmpty()) { %>
            <a href="${pageContext.request.contextPath}/admin?accion=listarClientes" class="btn btn-secundario" style="height:44px;display:flex;align-items:center;">✕ Limpiar</a>
        <% } %>
    </form>

    <% if (request.getParameter("ok") != null) { %>
        <div class="alerta alerta-exito">Operación realizada correctamente.</div>
    <% } %>

    <table class="tabla">
        <thead>
            <tr>
                <th>Nombres</th><th>Apellidos</th><th>Cédula / Identificación</th>
                <th>Teléfono</th><th>Correo</th><th>Usuario</th><th>Acciones</th>
            </tr>
        </thead>
        <tbody>
        <%
            Map<String, String> nombresUsuario = (Map<String, String>) request.getAttribute("nombresUsuario");
            if (clientes != null) { for (Cliente c : clientes) { %>
            <tr>
                <td><%= c.getNombres() %></td>
                <td><%= c.getApellidos() %></td>
                <td>
                    <% if (c.isEsExtranjero() || (c.getIdentificacionExtranjera() != null && !c.getIdentificacionExtranjera().isEmpty())) { %>
                        <span class="badge-extranjero" title="Identificación Extranjera">
                            &#x1F516; <%= c.getIdentificacionExtranjera() %>
                        </span>
                    <% } else { %>
                        <span class="badge-ecuatoriano" title="Cédula Ecuatoriana">
                            &#x1F194; <%= c.getCedula() %>
                        </span>
                    <% } %>
                </td>
                <td><%= c.getTelefono() != null ? c.getTelefono() : "-" %></td>
                <td><%= c.getCorreo() != null ? c.getCorreo() : "-" %></td>
                <td>
                    <%
                        String usernameCli = nombresUsuario != null ? nombresUsuario.get(c.getId()) : null;
                        if (usernameCli != null) {
                    %>
                        <span class="badge-usuario">@<%= usernameCli %></span>
                    <% } else { %>
                        <span class="text-muted">Sin usuario</span>
                    <% } %>
                </td>
                <td>
                    <a href="#" class="btn btn-sm btn-exito" onclick="confirmarEditarCliente('<%= c.getId() %>'); return false;">Editar</a>
                    <% if (c.getIdUsuario() != null) { %>
                    <button onclick="abrirModalReset('<%= c.getIdUsuario() %>', 'CLIENTE')"
                            class="btn btn-sm btn-secundario">Resetear Contraseña</button>
                    <% } %>
                    <%-- Mostrar solo un botón según estado --%>
                    <%
                        Map<String, Boolean> estadosActivosMap = (Map<String, Boolean>) request.getAttribute("estadosActivos");
                        boolean isActivo = estadosActivosMap != null && estadosActivosMap.containsKey(c.getId()) 
                            ? estadosActivosMap.get(c.getId()) : true;
                    %>
                    <% if (isActivo) { %>
                        <button onclick="confirmarDesactivarCliente('<%= c.getId() %>', '<%= c.getNombres().replace("'", "\\'") %>')"
                                class="btn btn-sm btn-peligro">Desactivar</button>
                    <% } else { %>
                        <button onclick="confirmarActivarCliente('<%= c.getId() %>', '<%= c.getNombres().replace("'", "\\'") %>')"
                                class="btn btn-sm btn-primario">Activar</button>
                    <% } %>
                </td>
            </tr>
        <% } } else { %>
            <tr><td colspan="7" style="text-align:center;padding:30px;color:#888;">No hay clientes registrados.</td></tr>
        <% } %>
        </tbody>
    </table>

    <!-- Controles de paginación -->
    <%
        Integer totalPaginas = (Integer) request.getAttribute("totalPaginas");
        Integer paginaActual = (Integer) request.getAttribute("pagina");
        Long totalRegistros = (Long) request.getAttribute("totalRegistros");
        Integer registrosPorPagina = (Integer) request.getAttribute("registrosPorPagina");
        String busqueda = request.getParameter("busqueda");
        String paramBusqueda = (busqueda != null && !busqueda.isEmpty()) ? "&busqueda=" + busqueda : "";
        if (totalPaginas == null) totalPaginas = 0;
        if (paginaActual == null) paginaActual = 1;
        if (registrosPorPagina == null) registrosPorPagina = 5;
    %>
    <!-- Selector "Mostrar" SIEMPRE visible -->
    <div class="paginacion" style="display:flex;justify-content:space-between;align-items:center;margin-top:15px;flex-wrap:wrap;gap:10px;">
        <div>
            <label style="color:#888;font-size:0.9em;">Mostrar:
                <select onchange="window.location.href='${pageContext.request.contextPath}/admin?accion=listarClientes&registros='+this.value+'&pagina=1<%= paramBusqueda %>'" style="border:1px solid #d4b68a;border-radius:5px;padding:3px;margin-left:5px;">
                    <option value="5" <%= registrosPorPagina == 5 ? "selected" : "" %>>5</option>
                    <option value="10" <%= registrosPorPagina == 10 ? "selected" : "" %>>10</option>
                    <option value="25" <%= registrosPorPagina == 25 ? "selected" : "" %>>25</option>
                    <option value="50" <%= registrosPorPagina == 50 ? "selected" : "" %>>50</option>
                </select>
            </label>
            <span style="color:#888;font-size:0.9em;margin-left:10px;">Total: <%= totalRegistros %> registros</span>
        </div>
        <!-- PaginaciÃ³n visible si hay al menos 1 registro -->
        <% if (totalRegistros != null && totalRegistros > 0) { %>
        <div style="display:flex;gap:5px;align-items:center;">
            <a href="?accion=listarClientes&pagina=1&registros=<%= registrosPorPagina %><%= paramBusqueda %>"
               class="btn btn-sm <%= paginaActual == 1 ? "btn-secundario disabled" : "btn-secundario" %>"
               <%= paginaActual == 1 ? "style='pointer-events:none;opacity:0.5;'" : "" %>>««</a>
            <a href="?accion=listarClientes&pagina=<%= paginaActual - 1 %>&registros=<%= registrosPorPagina %><%= paramBusqueda %>"
               class="btn btn-sm <%= paginaActual <= 1 ? "btn-secundario disabled" : "btn-secundario" %>"
               <%= paginaActual <= 1 ? "style='pointer-events:none;opacity:0.5;'" : "" %>>«</a>
            <span style="padding:5px 10px;color:#666;">PÃ¡g <%= paginaActual %> de <%= totalPaginas %></span>
            <a href="?accion=listarClientes&pagina=<%= paginaActual + 1 %>&registros=<%= registrosPorPagina %><%= paramBusqueda %>"
               class="btn btn-sm <%= paginaActual >= totalPaginas ? "btn-secundario disabled" : "btn-secundario" %>"
               <%= paginaActual >= totalPaginas ? "style='pointer-events:none;opacity:0.5;'" : "" %>>»</a>
            <a href="?accion=listarClientes&pagina=<%= totalPaginas %>&registros=<%= registrosPorPagina %><%= paramBusqueda %>"
               class="btn btn-sm <%= paginaActual >= totalPaginas ? "btn-secundario disabled" : "btn-secundario" %>"
               <%= paginaActual >= totalPaginas ? "style='pointer-events:none;opacity:0.5;'" : "" %>>»»</a>
        </div>
        <% } %>
    </div>
</div>

<jsp:include page="/vistas/admin/modal-reset-password.jsp" />
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>var contextPath = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/js/confirmaciones.js"></script>
<script src="${pageContext.request.contextPath}/js/validaciones.js"></script>

<!-- Limpiar mensaje de sesión después de mostrarlo (prevenir persistencia entre páginas) -->
<script>
document.addEventListener('DOMContentLoaded', function() {
    var mensaje = '${sessionScope.mensaje}';
    if (mensaje && mensaje.trim() !== '' && mensaje !== 'null') {
        // SweetAlert ya se mostró arriba (timer 3s). Esperar 4s y limpiar sesión.
        setTimeout(function() {
            fetch(contextPath + '/admin?accion=limpiarMensaje');
        }, 4000);
    }
});
</script>
</body>
</html>
