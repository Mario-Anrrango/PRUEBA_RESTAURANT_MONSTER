<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.*" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"EMPLEADO".equals(usuario.getPerfil())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    Empleado empleado = (Empleado) session.getAttribute("empleado");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Panel Empleado – Restaurant Master Monster</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body>
<div class="encabezado">
    <h1>Restaurant Master Monster</h1>
    <img src="${pageContext.request.contextPath}/img/LOGO_EMPRESA/Monster.jpg" alt="Logo" class="logo-encabezado">
</div>
<nav class="navbar">
    <ul class="navbar-links">
        <li><a href="${pageContext.request.contextPath}/empleado" class="activo">Inicio</a></li>
        <li><a href="${pageContext.request.contextPath}/empleado?accion=formCliente">Registrar Cliente</a></li>
        <li><a href="${pageContext.request.contextPath}/empleado?accion=buscarCliente">Buscar Cliente</a></li>
        <li><a href="${pageContext.request.contextPath}/logout">Cerrar Sesión</a></li>
    </ul>
    <span class="navbar-user">
        <%= empleado != null ? empleado.getNombreCompleto() : usuario.getUsername() %> – Mesero
    </span>
</nav>

<div class="contenedor" style="margin-top:30px;">
    <h2 class="titulo-seccion">Panel del Empleado</h2>
    <p style="margin-bottom:25px;color:#666;">
        Bienvenido,
        <strong><%= empleado != null ? empleado.getNombreCompleto() : usuario.getUsername() %></strong>.
        Desde aquí puedes registrar nuevos clientes y gestionar pedidos.
    </p>

    <div class="dashboard-grid">
        <a href="${pageContext.request.contextPath}/empleado?accion=formCliente" class="dash-card">
            <div class="dash-card-icon">👤</div>
            <h3>Registrar Cliente</h3>
            <p>Registrar un cliente nuevo en el sistema</p>
        </a>
        <a href="${pageContext.request.contextPath}/empleado?accion=buscarCliente" class="dash-card">
            <div class="dash-card-icon">🔍</div>
            <h3>Buscar Cliente</h3>
            <p>Buscar por cédula para ver historial o tomar pedido</p>
        </a>
    </div>
</div>
</body>
</html>
