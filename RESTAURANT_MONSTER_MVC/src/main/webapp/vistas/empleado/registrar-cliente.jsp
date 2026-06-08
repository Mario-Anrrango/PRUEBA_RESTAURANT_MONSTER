<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.Usuario" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"EMPLEADO".equals(usuario.getPerfil())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Registrar Cliente – Empleado</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body>
<div class="encabezado">
    <h1>Restaurant Master Monster</h1>
    <img src="${pageContext.request.contextPath}/img/LOGO_EMPRESA/Monster.jpg" alt="Logo" class="logo-encabezado">
</div>
<nav class="navbar">
    <ul class="navbar-links">
        <li><a href="${pageContext.request.contextPath}/empleado">Inicio</a></li>
        <li><a href="${pageContext.request.contextPath}/empleado?accion=formCliente" class="activo">Registrar Cliente</a></li>
        <li><a href="${pageContext.request.contextPath}/empleado?accion=buscarCliente">Buscar Cliente</a></li>
        <li><a href="${pageContext.request.contextPath}/logout">Cerrar Sesión</a></li>
    </ul>
    <span class="navbar-user">Mesero: <%= usuario.getUsername() %></span>
</nav>

<div class="contenedor contenedor-medio" style="margin-top:25px;">
    <h2 class="titulo-seccion">Registrar Nuevo Cliente</h2>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alerta alerta-error">${error}</div>
    <% } %>
    <% if (request.getAttribute("exito") != null) { %>
        <div class="alerta alerta-exito">${exito}</div>
    <% } %>

    <form action="${pageContext.request.contextPath}/empleado" method="post"
          onsubmit="return validarFormulario(event)">
        <input type="hidden" name="accion" value="registrarCliente">
        <div class="form-row">
            <div class="form-grupo">
                <label>Nombres *</label>
                <input type="text" name="nombres" class="form-control" required placeholder="Ej: Ana Lucía"
                       onkeydown="bloquearTecladoNumerico(event)" oninput="permitirSoloLetras(this)">
            </div>
            <div class="form-grupo">
                <label>Apellidos *</label>
                <input type="text" name="apellidos" class="form-control" required placeholder="Ej: Rodríguez"
                       onkeydown="bloquearTecladoNumerico(event)" oninput="permitirSoloLetras(this)">
            </div>
        </div>
        <div class="form-row">
            <div class="form-grupo">
                <label>Cédula *</label>
                <input type="text" name="cedula" id="cedula" class="form-control" required maxlength="10"
                       pattern="[0-9]{10}" placeholder="0912345678"
                       onkeydown="bloquearTecladoAlfabetico(event)" oninput="permitirSoloNumeros(this, 10)">
            </div>
            <div class="form-grupo">
                <label>Teléfono</label>
                <input type="text" name="telefono" id="telefono" class="form-control"
                       placeholder="0991234567" maxlength="10"
                       onkeydown="bloquearTecladoAlfabetico(event)" oninput="permitirSoloNumeros(this, 10)">
            </div>
        </div>
        <div class="form-grupo">
            <label>Correo</label>
            <input type="email" name="correo" id="correo" class="form-control"
                   placeholder="correo@ejemplo.com" onkeydown="bloquearCaracteresCorreo(event)">
        </div>
        <div class="form-grupo">
            <label>Dirección</label>
            <input type="text" name="direccion" class="form-control" placeholder="Av. Principal 123">
        </div>
        <hr style="margin:20px 0;border-color:var(--borde);">
        <h3 style="font-family:'Playfair Display',serif;color:var(--marron);margin-bottom:15px;">Credenciales de acceso</h3>
        <div class="form-row">
            <div class="form-grupo">
                <label>Usuario *</label>
                <input type="text" name="username" class="form-control" required>
            </div>
            <div class="form-grupo">
                <label>Contraseña *</label>
                <input type="password" name="password" class="form-control" required minlength="4">
            </div>
        </div>
        <div style="display:flex;gap:15px;margin-top:15px;">
            <button type="submit" class="btn btn-primario">Registrar Cliente</button>
            <a href="${pageContext.request.contextPath}/empleado" class="btn btn-secundario">Cancelar</a>
        </div>
    </form>
</div>
<script src="${pageContext.request.contextPath}/js/validacionCliente.js"></script>
</body>
</html>
