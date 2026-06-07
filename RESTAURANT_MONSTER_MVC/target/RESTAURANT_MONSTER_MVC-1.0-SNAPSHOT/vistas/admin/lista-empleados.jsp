<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.*,java.util.*" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"ADMIN".equals(usuario.getPerfil())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    List<Empleado> empleados = (List<Empleado>) request.getAttribute("empleados");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Lista de Empleados – Admin</title>
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
        <li><a href="${pageContext.request.contextPath}/admin?accion=listarClientes">Clientes</a></li>
        <li><a href="${pageContext.request.contextPath}/admin?accion=listarEmpleados" class="activo">Empleados</a></li>
        <li><a href="${pageContext.request.contextPath}/logout">Cerrar Sesión</a></li>
    </ul>
    <span class="navbar-user">Admin: <%= usuario.getUsername() %></span>
</nav>

<div class="contenedor" style="margin-top:25px;">
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:15px;">
        <h2 class="titulo-seccion" style="margin-bottom:0;">Personal del Restaurante</h2>
        <a href="${pageContext.request.contextPath}/admin?accion=formEmpleado" class="btn btn-primario">+ Nuevo Empleado</a>
    </div>

    <% if (request.getParameter("ok") != null) { %>
        <div class="alerta alerta-exito">Empleado registrado correctamente.</div>
    <% } %>

    <table class="tabla">
        <thead>
            <tr>
                <th>#</th><th>Nombres</th><th>Apellidos</th><th>Cédula</th>
                <th>Cargo</th><th>Teléfono</th><th>Correo</th><th>Fecha Ingreso</th>
            </tr>
        </thead>
        <tbody>
        <% if (empleados != null) { for (Empleado e : empleados) { %>
            <tr>
                <td><%= e.getId() %></td>
                <td><%= e.getNombres() %></td>
                <td><%= e.getApellidos() %></td>
                <td><%= e.getCedula() %></td>
                <td><span style="background:var(--dorado);color:white;padding:3px 10px;border-radius:12px;font-size:0.85em;"><%= e.getCargo() %></span></td>
                <td><%= e.getTelefono() != null ? e.getTelefono() : "-" %></td>
                <td><%= e.getCorreo() != null ? e.getCorreo() : "-" %></td>
                <td><%= e.getFechaIngreso() != null ? e.getFechaIngreso() : "-" %></td>
            </tr>
        <% } } %>
        </tbody>
    </table>
</div>
</body>
</html>
