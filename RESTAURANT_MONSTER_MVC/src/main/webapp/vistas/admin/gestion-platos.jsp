<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.*,java.util.*" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"ADMIN".equals(usuario.getPerfil())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    List<Plato> platos = (List<Plato>) request.getAttribute("platos");
    List<Categoria> categorias = (List<Categoria>) request.getAttribute("categorias");
    Integer pagina = (Integer) request.getAttribute("pagina");
    Integer totalPaginas = (Integer) request.getAttribute("totalPaginas");
    Integer totalRegistros = (Integer) request.getAttribute("totalRegistros");
    Integer registrosPorPagina = (Integer) request.getAttribute("registrosPorPagina");
    String categoriaFiltro = (String) request.getAttribute("categoriaFiltro");
    
    if (pagina == null) pagina = 1;
    if (totalPaginas == null) totalPaginas = 1;
    if (totalRegistros == null) totalRegistros = 0;
    if (registrosPorPagina == null) registrosPorPagina = 5;
    if (categoriaFiltro == null) categoriaFiltro = "TODOS";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Platos – Admin</title>
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
        <li><a href="${pageContext.request.contextPath}/admin?accion=listarPlatos" class="activo">Platos</a></li>
        <li><a href="${pageContext.request.contextPath}/admin?accion=listarClientes">Clientes</a></li>
        <li><a href="${pageContext.request.contextPath}/admin?accion=listarEmpleados">Empleados</a></li>
        <li><a href="${pageContext.request.contextPath}/logout">Cerrar Sesión</a></li>
    </ul>
    <span class="navbar-user">Admin: <%= usuario.getUsername() %></span>
</nav>

<div class="contenedor" style="margin-top:25px;">
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:15px;">
        <h2 class="titulo-seccion" style="margin-bottom:0;">Gestión de Platos</h2>
        <a href="${pageContext.request.contextPath}/admin?accion=nuevoPlato" class="btn btn-primario">+ Nuevo Plato</a>
    </div>

    <!-- Mensajes SweetAlert (validaci\u00f3n JS para evitar modal blanco) -->
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

    <!-- FILTRO POR CATEGORÍA -->
    <div class="filtros-container">
        <form method="get" action="${pageContext.request.contextPath}/admin" class="filtros-form">
            <input type="hidden" name="accion" value="listarPlatos">
            <div class="filtro-group">
                <label>Filtrar por categoría:</label>
                <select name="categoria" onchange="this.form.submit()">
                    <option value="TODOS" <%= "TODOS".equals(categoriaFiltro) ? "selected" : "" %>>Todas las categorías</option>
                    <% if (categorias != null) {
                        for (Categoria cat : categorias) { %>
                            <option value="<%= cat.getId() %>" <%= cat.getId().equals(categoriaFiltro) ? "selected" : "" %>>
                                <%= cat.getNombre() %>
                            </option>
                    <% } } %>
                </select>
            </div>
            <% if (!"TODOS".equals(categoriaFiltro)) { %>
                <a href="${pageContext.request.contextPath}/admin?accion=listarPlatos" class="btn-limpiar">
                    ✕ Limpiar filtro
                </a>
            <% } %>
        </form>
    </div>

    <table class="tabla">
        <thead>
            <tr>
                <th>#</th>
                <th>Foto</th>
                <th>Nombre</th>
                <th>Categoría</th>
                <th>Precio</th>
                <th>Estado</th>
                <th>Acciones</th>
            </tr>
        </thead>
        <tbody>
        <%
            if (platos != null && !platos.isEmpty()) {
                for (Plato p : platos) {
                    String fotoUrl = (p.getFoto() != null && !p.getFoto().isEmpty()) 
                        ? request.getContextPath() + "/images/" + p.getFoto() 
                        : "";
        %>
            <tr>
                <td><%= p.getId() %></td>
                <td>
                    <img src="<%= fotoUrl %>"
                         width="70" height="50" style="object-fit:cover;"
                         onerror="this.src='${pageContext.request.contextPath}/img/placeholder-plato.svg';this.onerror=''"
                         alt="Foto de <%= p.getNombre() %>">
                </td>
                <td><strong><%= p.getNombre() %></strong></td>
                <td><%= p.getNombreCategoria() != null ? p.getNombreCategoria() : "" %></td>
                <td>$<%= p.getPrecio() != null ? p.getPrecio().setScale(2, java.math.RoundingMode.HALF_UP) : "0.00" %></td>
                <td>
                    <% if (p.isActivo()) { %>
                        <span style="color:#27ae60;font-weight:600;">Activo</span>
                    <% } else { %>
                        <span style="color:#c0392b;font-weight:600;">Inactivo</span>
                    <% } %>
                </td>
                <td>
                    <a href="${pageContext.request.contextPath}/admin?accion=editarPlato&id=<%= p.getId() %>"
                       class="btn btn-sm btn-exito"
                       onclick="return confirmarEditarPlato('<%= p.getNombre() %>')">Editar</a>
                    <% if (p.isActivo()) { %>
                        <a href="#"
                           class="btn btn-sm btn-peligro"
                           onclick="confirmarDesactivarPlato('<%= p.getId() %>', '<%= p.getNombre().replace("'", "\\'") %>'); return false;">Desactivar</a>
                    <% } else { %>
                        <a href="#"
                           class="btn btn-sm btn-primario"
                           onclick="confirmarActivarPlato('<%= p.getId() %>', '<%= p.getNombre().replace("'", "\\'") %>'); return false;">Activar</a>
                    <% } %>
                </td>
            </tr>
        <%
                }
            } else {
        %>
            <tr>
                <td colspan="7" style="text-align:center;padding:30px;color:#888;">
                    No se encontraron platos
                </td>
            </tr>
        <% } %>
        </tbody>
    </table>

    <!-- PAGINACIÓN -->
    <!-- Selector "Mostrar" SIEMPRE visible -->
    <div class="paginacion" style="display:flex;justify-content:space-between;align-items:center;padding:20px;background-color:#fff;border-radius:8px;margin-top:20px;">
        <div style="display:flex;gap:20px;align-items:center;">
            <label style="color:#888;font-size:0.9em;">
                Mostrar:
                <select onchange="cambiarRegistros(this.value)" style="padding:5px 10px;border:1px solid #d4a577;border-radius:4px;cursor:pointer;">
                    <option value="5" <%= registrosPorPagina == 5 ? "selected" : "" %>>5</option>
                    <option value="10" <%= registrosPorPagina == 10 ? "selected" : "" %>>10</option>
                    <option value="25" <%= registrosPorPagina == 25 ? "selected" : "" %>>25</option>
                    <option value="50" <%= registrosPorPagina == 50 ? "selected" : "" %>>50</option>
                </select>
            </label>
            <span style="color:#888;font-size:0.9em;">Total: <%= totalRegistros %> platos</span>
        </div>
        <!-- PaginaciÃ³n visible si hay al menos 1 registro -->
        <% if (totalRegistros > 0) { %>
        <div style="display:flex;gap:5px;align-items:center;">
            <a href="?accion=listarPlatos&pagina=1&registros=<%= registrosPorPagina %>&categoria=<%= categoriaFiltro %>"
               class="btn btn-sm <%= pagina == 1 ? "btn-secundario" : "btn-primario" %>"
               style="<%= pagina == 1 ? "opacity:0.5;pointer-events:none;" : "" %>">≪ Inicio</a>
            <a href="?accion=listarPlatos&pagina=<%= pagina - 1 %>&registros=<%= registrosPorPagina %>&categoria=<%= categoriaFiltro %>"
               class="btn btn-sm <%= pagina == 1 ? "btn-secundario" : "btn-primario" %>"
               style="<%= pagina == 1 ? "opacity:0.5;pointer-events:none;" : "" %>">‹ Anterior</a>
            <span style="font-weight:bold;color:#8b4513;padding:5px 10px;">Pág <%= pagina %> de <%= totalPaginas %></span>
            <a href="?accion=listarPlatos&pagina=<%= pagina + 1 %>&registros=<%= registrosPorPagina %>&categoria=<%= categoriaFiltro %>"
               class="btn btn-sm <%= pagina == totalPaginas ? "btn-secundario" : "btn-primario" %>"
               style="<%= pagina == totalPaginas ? "opacity:0.5;pointer-events:none;" : "" %>">Siguiente ›</a>
            <a href="?accion=listarPlatos&pagina=<%= totalPaginas %>&registros=<%= registrosPorPagina %>&categoria=<%= categoriaFiltro %>"
               class="btn btn-sm <%= pagina == totalPaginas ? "btn-secundario" : "btn-primario" %>"
               style="<%= pagina == totalPaginas ? "opacity:0.5;pointer-events:none;" : "" %>">Fin ≫</a>
        </div>
        <% } %>
    </div>
</div>

<script>
function cambiarRegistros(cantidad) {
    const url = new URL(window.location.href);
    url.searchParams.set('registros', cantidad);
    url.searchParams.set('pagina', '1');
    window.location.href = url.toString();
}
</script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>var contextPath = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/js/confirmaciones.js"></script>
<script src="${pageContext.request.contextPath}/js/validaciones.js"></script>
</body>
</html>
