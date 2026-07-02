<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.*,java.util.*" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"ADMIN".equals(usuario.getPerfil())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    List<Plato> platos = (List<Plato>) request.getAttribute("platos");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Platos – Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/validaciones.css">
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

    <c:if test="${not empty sessionScope.mensaje}">
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            Swal.fire({
                icon: '${sessionScope.tipoMensaje}',
                title: '${sessionScope.mensaje}',
                timer: 3000,
                showConfirmButton: false
            });
        });
    </script>
    <c:remove var="mensaje" scope="session"/>
    <c:remove var="tipoMensaje" scope="session"/>
</c:if>

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
            if (platos != null) {
                for (Plato p : platos) {
        %>
            <tr>
                <td><%= p.getId() %></td>
                <td>
                    <img src="${pageContext.request.contextPath}/<%= p.getFoto() %>"
                         width="70" height="50" style="object-fit:cover;"
                         onerror="this.src='${pageContext.request.contextPath}/img/LOGO_EMPRESA/Monster.jpg'">
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
            }
        %>
        </tbody>
    </table>
</div>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>var contextPath = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/js/confirmaciones.js"></script>
<script src="${pageContext.request.contextPath}/js/validaciones.js"></script>
</body>
</html>
