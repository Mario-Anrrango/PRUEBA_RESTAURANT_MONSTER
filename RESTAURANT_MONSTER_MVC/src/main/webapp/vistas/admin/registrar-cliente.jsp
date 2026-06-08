<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.*" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"ADMIN".equals(usuario.getPerfil())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    Cliente clienteEdit   = (Cliente)  request.getAttribute("cliente");
    Usuario usuarioEdit   = (Usuario)  request.getAttribute("usuarioEditar");
    boolean esEdicion     = clienteEdit != null;
    String  valNombres    = esEdicion ? clienteEdit.getNombres()   : "";
    String  valApellidos  = esEdicion ? clienteEdit.getApellidos() : "";
    String  valCedula     = esEdicion ? clienteEdit.getCedula()    : "";
    String  valTelefono   = esEdicion && clienteEdit.getTelefono()  != null ? clienteEdit.getTelefono()  : "";
    String  valCorreo     = esEdicion && clienteEdit.getCorreo()    != null ? clienteEdit.getCorreo()    : "";
    String  valDireccion  = esEdicion && clienteEdit.getDireccion() != null ? clienteEdit.getDireccion() : "";
    String  valUsername   = esEdicion && usuarioEdit != null ? usuarioEdit.getUsername() : "";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title><%= esEdicion ? "Editar Cliente" : "Registrar Cliente" %> – Admin</title>
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

<div class="contenedor contenedor-medio" style="margin-top:25px;">
    <h2 class="titulo-seccion"><%= esEdicion ? "Editar Cliente" : "Registrar Nuevo Cliente" %></h2>

    <% if (request.getAttribute("error") != null) { %>
    <div class="alerta alerta-error">${error}</div>
    <% } %>

    <form action="${pageContext.request.contextPath}/admin" method="post" id="formCliente"
          onsubmit="return validarFormulario(event)">
        <input type="hidden" name="accion" value="<%= esEdicion ? "actualizarCliente" : "registrarCliente" %>">
        <% if (esEdicion) { %>
        <input type="hidden" name="id"        value="<%= clienteEdit.getId() %>">
        <input type="hidden" name="idUsuario" value="<%= clienteEdit.getIdUsuario() %>">
        <% } %>

        <div class="form-row">
            <div class="form-grupo">
                <label>Nombres *</label>
                <input type="text" name="nombres" class="form-control" required
                       placeholder="Ej: Juan Carlos" value="<%= valNombres %>"
                       oninput="permitirSoloLetras(this)">
            </div>
            <div class="form-grupo">
                <label>Apellidos *</label>
                <input type="text" name="apellidos" class="form-control" required
                       placeholder="Ej: Pérez Mora" value="<%= valApellidos %>"
                       oninput="permitirSoloLetras(this)">
            </div>
        </div>

        <div class="form-row">
            <div class="form-grupo">
                <label>Cédula Ecuatoriana *</label>
                <% if (esEdicion) { %>
                <%-- Visible solo lectura + hidden con id para que el validador JS lo lea --%>
                <input type="text" class="form-control" value="<%= valCedula %>" disabled
                       style="background:#f0f0f0;cursor:not-allowed;">
                <input type="hidden" id="cedula" name="cedula" value="<%= valCedula %>">
                <% } else { %>
                <input type="text" name="cedula" id="cedula" class="form-control" required
                       maxlength="10" pattern="[0-9]{10}" title="10 dígitos" placeholder="0912345678">
                <% } %>
            </div>
            <div class="form-grupo">
                <label>Teléfono</label>
                <input type="text" name="telefono" id="telefono" class="form-control"
                       placeholder="0991234567" value="<%= valTelefono %>">
            </div>
        </div>

        <div class="form-grupo">
            <label>Correo Electrónico</label>
            <input type="email" name="correo" id="correo" class="form-control"
                   placeholder="correo@ejemplo.com" value="<%= valCorreo %>">
        </div>

        <div class="form-grupo">
            <label>Dirección</label>
            <input type="text" name="direccion" class="form-control"
                   placeholder="Calle, número, ciudad" value="<%= valDireccion %>">
        </div>

        <hr style="margin:20px 0;border-color:var(--borde);">
        <h3 style="font-family:'Playfair Display',serif;color:var(--marron);margin-bottom:15px;">
            Credenciales de acceso
        </h3>

        <div class="form-row">
            <div class="form-grupo">
                <label>Usuario *</label>
                <input type="text" name="username" class="form-control" required
                       placeholder="usuario_cliente" value="<%= valUsername %>">
            </div>
            <div class="form-grupo">
                <label>Contraseña <%= esEdicion ? "" : "*" %></label>
                <input type="password" name="password" class="form-control"
                       <%= esEdicion ? "" : "required minlength=\"4\"" %>
                       placeholder="<%= esEdicion ? "Dejar vacío para no cambiar" : "" %>">
            </div>
        </div>

        <div style="display:flex;gap:15px;margin-top:15px;">
            <button type="submit" class="btn btn-primario">
                <%= esEdicion ? "Guardar Cambios" : "Registrar Cliente" %>
            </button>
            <a href="${pageContext.request.contextPath}/admin?accion=listarClientes"
               class="btn btn-secundario">Cancelar</a>
        </div>
    </form>
</div>

<script src="${pageContext.request.contextPath}/js/validacionCliente.js"></script>
</body>
</html>
