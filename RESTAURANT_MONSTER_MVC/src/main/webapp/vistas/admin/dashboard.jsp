<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.Usuario" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"ADMIN".equals(usuario.getPerfil())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel Administrador – Restaurant Master Monster</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body>
<div class="encabezado">
    <h1>Restaurant Master Monster</h1>
    <img src="${pageContext.request.contextPath}/img/LOGO_EMPRESA/Monster.jpg" alt="Logo" class="logo-encabezado">
</div>
<nav class="navbar">
    <ul class="navbar-links">
        <li><a href="${pageContext.request.contextPath}/admin" class="activo">Inicio</a></li>
        <li><a href="${pageContext.request.contextPath}/admin?accion=listarPlatos">Platos</a></li>
        <li><a href="${pageContext.request.contextPath}/admin?accion=listarClientes">Clientes</a></li>
        <li><a href="${pageContext.request.contextPath}/admin?accion=listarEmpleados">Empleados</a></li>
        <li><a href="${pageContext.request.contextPath}/logout">Cerrar Sesión</a></li>
    </ul>
    <span class="navbar-user">Admin: <%= usuario.getUsername() %></span>
</nav>

<div class="contenedor" style="margin-top:30px;">
    <h2 class="titulo-seccion">Panel de Administración</h2>
    <p style="margin-bottom:25px;color:#666;">Bienvenido, administrador. Gestiona todos los aspectos del restaurante desde aquí.</p>

    <div class="dashboard-grid">
        <a href="${pageContext.request.contextPath}/admin?accion=listarPlatos" class="dash-card">
            <div class="dash-card-icon">🍽️</div>
            <h3>Gestionar Platos</h3>
            <p>Agregar, editar o eliminar platos del menú</p>
        </a>
        <a href="${pageContext.request.contextPath}/admin?accion=nuevoPlato" class="dash-card">
            <div class="dash-card-icon">➕</div>
            <h3>Nuevo Plato</h3>
            <p>Agregar un nuevo plato al menú</p>
        </a>
        <a href="${pageContext.request.contextPath}/admin?accion=listarClientes" class="dash-card">
            <div class="dash-card-icon">👥</div>
            <h3>Clientes</h3>
            <p>Ver y registrar clientes del restaurante</p>
        </a>
        <a href="${pageContext.request.contextPath}/admin?accion=formCliente" class="dash-card">
            <div class="dash-card-icon">👤</div>
            <h3>Nuevo Cliente</h3>
            <p>Registrar un nuevo cliente</p>
        </a>
        <a href="${pageContext.request.contextPath}/admin?accion=listarEmpleados" class="dash-card">
            <div class="dash-card-icon">👨‍🍳</div>
            <h3>Empleados</h3>
            <p>Ver y gestionar el personal</p>
        </a>
        <a href="${pageContext.request.contextPath}/admin?accion=formEmpleado" class="dash-card">
            <div class="dash-card-icon">➕</div>
            <h3>Nuevo Empleado</h3>
            <p>Registrar un nuevo mesero o empleado</p>
        </a>
    </div>
</div>
</body>
</html>
