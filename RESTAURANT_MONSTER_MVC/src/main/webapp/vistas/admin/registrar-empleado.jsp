<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.*" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"ADMIN".equals(usuario.getPerfil())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    Empleado empleado = (Empleado) request.getAttribute("empleado");
    boolean esEdicion = (empleado != null && empleado.getId() != null && !empleado.getId().isEmpty());
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title><%= esEdicion ? "Editar" : "Registrar" %> Empleado – Admin</title>
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
        <li><a href="${pageContext.request.contextPath}/admin?accion=listarPlatos">Platos</a></li>
        <li><a href="${pageContext.request.contextPath}/admin?accion=listarClientes">Clientes</a></li>
        <li><a href="${pageContext.request.contextPath}/admin?accion=listarEmpleados" class="activo">Empleados</a></li>
        <li><a href="${pageContext.request.contextPath}/logout">Cerrar Sesión</a></li>
    </ul>
    <span class="navbar-user">Admin: <%= usuario.getUsername() %></span>
</nav>

<div class="contenedor contenedor-medio" style="margin-top:25px;">
    <h2 class="titulo-seccion"><%= esEdicion ? "Editar Empleado" : "Registrar Nuevo Empleado" %></h2>

    <% if (request.getAttribute("error") != null) { %><div class="alerta alerta-error">${error}</div><% } %>

    <form action="${pageContext.request.contextPath}/admin" method="post">
        <input type="hidden" name="accion" value="<%= esEdicion ? "actualizarEmpleado" : "registrarEmpleado" %>">
        <% if (esEdicion) { %><input type="hidden" name="id" value="<%= empleado.getId() %>"><% } %>

        <div class="form-row">
            <div class="form-grupo">
                <label>Nombres *</label>
                <input type="text" name="nombres" class="form-control" required
                       value="<%= esEdicion ? empleado.getNombres() : "" %>" placeholder="Ej: Luis Andrés"
                       minlength="4" maxlength="40">
                <small style="color:#888;font-size:0.8em;">Solo letras. Mínimo 4, máximo 40</small>
            </div>
            <div class="form-grupo">
                <label>Apellidos *</label>
                <input type="text" name="apellidos" class="form-control" required
                       value="<%= esEdicion ? empleado.getApellidos() : "" %>" placeholder="Ej: Torres Ruiz"
                       minlength="4" maxlength="40">
                <small style="color:#888;font-size:0.8em;">Solo letras. Mínimo 4, máximo 40</small>
            </div>
        </div>

        <div class="form-grupo">
            <label style="display:flex;align-items:center;gap:8px;">
                <input type="checkbox" id="esExtranjero" name="esExtranjero"
                    <%= esEdicion && empleado.isEsExtranjero() ? "checked" : "" %>
                    onchange="toggleExtranjero()">
                <span>Soy extranjero (no tengo cédula ecuatoriana)</span>
            </label>
        </div>

        <div class="form-row">
            <div class="form-grupo">
                <label>Cédula *</label>
                <input type="text" name="cedula" class="form-control" required maxlength="10"
                       id="cedulaInput"
                       value="<%= esEdicion && !empleado.isEsExtranjero() ? empleado.getCedula() : "" %>"
                       placeholder="1712345678"
                    <%= esEdicion ? "disabled readonly title='No se puede modificar la identificación'" : "" %>>
                <%= esEdicion ? "<small style='color:#888;font-size:0.8em;'>No modificable en edición</small>" : "" %>
            </div>
            <div class="form-grupo" id="extranjeroGroup" style="<%= esEdicion && empleado.isEsExtranjero() ? "" : "display:none" %>">
                <label>Identificación Extranjera</label>
                <input type="text" name="identificacionExtranjera" class="form-control"
                       id="extranjeroInput"
                       value="<%= esEdicion ? empleado.getIdentificacionExtranjera() : "" %>"
                       placeholder="Pasaporte o ID"
                       minlength="5" maxlength="20"
                    <%= esEdicion && empleado.isEsExtranjero() ? "required" : "disabled" %>>
            </div>
        </div>

        <div class="form-row">
            <div class="form-grupo">
                <label>Cargo *</label>
                <select name="cargo" class="form-control" required>
                    <option value="">-- Seleccionar --</option>
                    <option value="Mesero" <%= esEdicion && "Mesero".equals(empleado.getCargo()) ? "selected" : "" %>>Mesero</option>
                    <option value="Admin" <%= esEdicion && "Admin".equals(empleado.getCargo()) ? "selected" : "" %>>Admin</option>
                </select>
                <small style="color:#888;font-size:0.8em;">Solo cargos disponibles: Mesero, Admin</small>
            </div>
            <div class="form-grupo">
                <label>Teléfono</label>
                <input type="text" name="telefono" class="form-control" maxlength="10"
                       value="<%= esEdicion ? empleado.getTelefono() : "" %>" placeholder="0991234567">
            </div>
        </div>
        <div class="form-grupo">
            <label>Correo Electrónico</label>
            <input type="email" name="correo" class="form-control"
                   value="<%= esEdicion ? empleado.getCorreo() : "" %>" placeholder="empleado@ejemplo.com">
        </div>

        <% if (!esEdicion) { %>
        <p style="font-size:0.85em;color:#888;margin-bottom:10px;">
            ℹ️ La fecha de ingreso se registrará automáticamente.
        </p>
        <hr style="margin:20px 0;border-color:var(--borde);">
        <h3 style="font-family:'Playfair Display',serif;color:var(--marron);margin-bottom:15px;">Credenciales de acceso</h3>
        <div class="form-row">
            <div class="form-grupo">
                <label>Usuario *</label>
                <input type="text" name="username" class="form-control" required placeholder="mesero_luis"
                       minlength="4" maxlength="30">
                <small style="color:#888;font-size:0.8em;">Solo letras, números y _</small>
            </div>
            <div class="form-grupo">
                <label>Contraseña *</label>
                <input type="password" name="password" id="password" class="form-control" required minlength="8">
                <small style="color:#888;font-size:0.8em;">Mínimo 8 caracteres, 1 mayúscula y 1 carácter especial</small>
            </div>
            <div class="form-grupo">
                <label>Confirmar Contraseña *</label>
                <input type="password" id="confirmPassword" class="form-control" required minlength="8">
            </div>
        </div>
        <% } %>

        <div style="display:flex;gap:15px;margin-top:15px;">
            <button type="submit" class="btn btn-primario"><%= esEdicion ? "Actualizar Empleado" : "Registrar Empleado" %></button>
            <a href="${pageContext.request.contextPath}/admin?accion=listarEmpleados" class="btn btn-secundario">Cancelar</a>
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
        validarSoloNumeros(document.getElementById('cedulaInput'));
        validarEmail(document.querySelector('input[name="correo"]'));
        validarUsuario(document.querySelector('input[name="username"]'));
        var pwdEmpl = document.getElementById('password');
        if (pwdEmpl) validarContrasena(pwdEmpl);
        var confEmpl = document.getElementById('confirmPassword');
        if (confEmpl && pwdEmpl) validarConfirmacionContrasena(pwdEmpl, confEmpl);
    });
</script>
</body>
</html>
