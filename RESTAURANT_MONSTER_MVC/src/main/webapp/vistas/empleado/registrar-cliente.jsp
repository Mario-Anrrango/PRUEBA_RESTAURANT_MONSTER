<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.*" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"EMPLEADO".equals(usuario.getPerfil())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    Cliente cliente = (Cliente) request.getAttribute("cliente");
    boolean esEdicion = (cliente != null && cliente.getId() != null && !cliente.getId().isEmpty());
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title><%= esEdicion ? "Editar" : "Registrar" %> Cliente – Empleado</title>
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
        <li><a href="${pageContext.request.contextPath}/empleado">Inicio</a></li>
        <li><a href="${pageContext.request.contextPath}/empleado?accion=formCliente" class="activo">Registrar Cliente</a></li>
        <li><a href="${pageContext.request.contextPath}/empleado?accion=buscarCliente">Buscar Cliente</a></li>
        <li><a href="${pageContext.request.contextPath}/logout">Cerrar Sesión</a></li>
    </ul>
    <span class="navbar-user">Mesero: <%= usuario.getUsername() %></span>
</nav>

<div class="contenedor contenedor-medio" style="margin-top:25px;">
    <h2 class="titulo-seccion"><%= esEdicion ? "Editar Cliente" : "Registrar Nuevo Cliente" %></h2>

    <% if (request.getAttribute("error") != null) { %><div class="alerta alerta-error">${error}</div><% } %>
    <% if (request.getAttribute("exito") != null) { %><div class="alerta alerta-exito">${exito}</div><% } %>

    <form action="${pageContext.request.contextPath}/empleado" method="post">
        <input type="hidden" name="accion" value="<%= esEdicion ? "actualizarCliente" : "registrarCliente" %>">
        <% if (esEdicion) { %><input type="hidden" name="id" value="<%= cliente.getId() %>"><% } %>

        <div class="form-row">
            <div class="form-grupo">
                <label>Nombres *</label>
                <input type="text" name="nombres" class="form-control" required
                       value="<%= esEdicion ? cliente.getNombres() : "" %>" placeholder="Ej: Ana Lucía"
                       minlength="4" maxlength="40">
            </div>
            <div class="form-grupo">
                <label>Apellidos *</label>
                <input type="text" name="apellidos" class="form-control" required
                       value="<%= esEdicion ? cliente.getApellidos() : "" %>" placeholder="Ej: Rodríguez"
                       minlength="4" maxlength="40">
            </div>
        </div>

        <div class="form-grupo">
            <label style="display:flex;align-items:center;gap:8px;">
                <input type="checkbox" id="esExtranjero" name="esExtranjero"
                    <%= esEdicion && cliente.isEsExtranjero() ? "checked" : "" %>
                    onchange="toggleExtranjero()">
                <span>Soy extranjero</span>
            </label>
        </div>

        <div class="form-row">
            <div class="form-grupo">
                <label>Cédula *</label>
                <input type="text" name="cedula" class="form-control" required maxlength="10"
                       id="cedulaInput"
                       value="<%= esEdicion && !cliente.isEsExtranjero() ? cliente.getCedula() : "" %>"
                       placeholder="0912345678"
                    <%= esEdicion && cliente.isEsExtranjero() ? "disabled" : "" %>>
            </div>
            <div class="form-grupo" id="extranjeroGroup" style="<%= esEdicion && cliente.isEsExtranjero() ? "" : "display:none" %>">
                <label>Identificación Extranjera</label>
                <input type="text" name="identificacionExtranjera" class="form-control"
                       id="extranjeroInput"
                       value="<%= esEdicion ? cliente.getIdentificacionExtranjera() : "" %>"
                       placeholder="Pasaporte o ID"
                       minlength="5" maxlength="20"
                    <%= esEdicion && cliente.isEsExtranjero() ? "required" : "disabled" %>>
            </div>
        </div>

        <div class="form-row">
            <div class="form-grupo">
                <label>Teléfono</label>
                <input type="text" name="telefono" class="form-control" maxlength="10"
                       value="<%= esEdicion ? cliente.getTelefono() : "" %>" placeholder="0991234567">
            </div>
            <div class="form-grupo">
                <label>Correo</label>
                <input type="email" name="correo" class="form-control"
                       value="<%= esEdicion ? cliente.getCorreo() : "" %>" placeholder="correo@ejemplo.com">
            </div>
        </div>
        <div class="form-grupo">
            <label>Dirección</label>
            <input type="text" name="direccion" class="form-control"
                   value="<%= esEdicion ? cliente.getDireccion() : "" %>" placeholder="Av. Principal 123"
                   minlength="10" maxlength="200">
        </div>

        <% if (!esEdicion) { %>
        <hr style="margin:20px 0;border-color:var(--borde);">
        <h3 style="font-family:'Playfair Display',serif;color:var(--marron);margin-bottom:15px;">Credenciales de acceso</h3>
        <div class="form-row">
            <div class="form-grupo">
                <label>Usuario *</label>
                <input type="text" name="username" class="form-control" required minlength="4" maxlength="30">
            </div>
            <div class="form-grupo">
                <label>Contraseña *</label>
                <input type="password" name="password" class="form-control" required minlength="8">
            </div>
        </div>
        <% } %>
        <div style="display:flex;gap:15px;margin-top:15px;">
            <button type="submit" class="btn btn-primario"><%= esEdicion ? "Actualizar Cliente" : "Registrar Cliente" %></button>
            <a href="${pageContext.request.contextPath}/empleado" class="btn btn-secundario">Cancelar</a>
        </div>
    </form>
</div>

<script src="${pageContext.request.contextPath}/js/validaciones.js"></script>
<script src="${pageContext.request.contextPath}/js/extranjero.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        validarSoloLetras(document.querySelector('input[name="nombres"]'));
        validarSoloLetras(document.querySelector('input[name="apellidos"]'));
        validarSoloNumeros(document.querySelector('input[name="telefono"]'));
        validarEmail(document.querySelector('input[name="correo"]'));
        validarUsuario(document.querySelector('input[name="username"]'));
    });
</script>
</body>
</html>
