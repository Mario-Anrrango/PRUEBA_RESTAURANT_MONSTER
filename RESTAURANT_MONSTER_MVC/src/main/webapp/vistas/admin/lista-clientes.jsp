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
    </div>

    <% if (request.getParameter("ok") != null) { %>
        <div class="alerta alerta-exito">Cliente registrado correctamente.</div>
    <% } %>

    <table class="tabla">
        <thead>
            <tr>
                <th>#</th><th>Nombres</th><th>Apellidos</th><th>Cédula</th>
                <th>Teléfono</th><th>Correo</th><th>Dirección</th>
            </tr>
        </thead>
        <tbody>
        <% if (clientes != null) { for (Cliente c : clientes) { %>
            <tr>
                <td><%= c.getId() %></td>
                <td><%= c.getNombres() %></td>
                <td><%= c.getApellidos() %></td>
                <td><%= c.getCedula() %></td>
                <td><%= c.getTelefono() != null ? c.getTelefono() : "-" %></td>
                <td><%= c.getCorreo() != null ? c.getCorreo() : "-" %></td>
                <td><%= c.getDireccion() != null ? c.getDireccion() : "-" %></td>
            </tr>
        <% } } %>
        </tbody>
    </table>
</div>
</body>
</html>
