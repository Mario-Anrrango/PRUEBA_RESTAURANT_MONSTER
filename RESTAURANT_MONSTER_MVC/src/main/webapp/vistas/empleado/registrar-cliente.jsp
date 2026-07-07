<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.*" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"EMPLEADO".equals(usuario.getPerfil())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    Cliente cliente = (Cliente) request.getAttribute("cliente");
    boolean esEdicion = (cliente != null && cliente.getId() != null && !cliente.getId().isEmpty());
    boolean esExtranjeroEdicion = esEdicion && cliente.isEsExtranjero();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title><%= esEdicion ? "Editar" : "Registrar" %> Cliente – Empleado</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/validaciones.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
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

    <form action="${pageContext.request.contextPath}/empleado" method="post" id="formCliente">
        <input type="hidden" name="accion" value="<%= esEdicion ? "actualizarCliente" : "registrarCliente" %>">
        <% if (esEdicion) { %>
            <input type="hidden" name="id" value="<%= cliente.getId() %>">
            <!-- Hidden inputs para campos disabled que no se envían -->
            <input type="hidden" name="esExtranjero" value="<%= esExtranjeroEdicion ? "on" : "" %>">
        <% } %>

        <!-- FILA 1: Nombres y Apellidos -->
        <div class="form-row">
            <div class="form-grupo">
                <label>Nombres *</label>
                <input type="text" id="nombres" name="nombres" class="form-control" required
                       value="<%= esEdicion ? cliente.getNombres() : "" %>" placeholder="Ej: Ana Lucía"
                       minlength="4" maxlength="40"
                       onblur="validarNombresOnBlur()"
                       oninput="this.value = this.value.replace(/[^a-zA-ZáéíóúÁÉÍÓÚñÑ\s]/g, '')">
                <div id="nombres-message" class="validation-message"></div>
                <small style="color:#888;font-size:0.8em;">Solo letras. Mínimo 4, máximo 40 caracteres</small>
            </div>
            <div class="form-grupo">
                <label>Apellidos *</label>
                <input type="text" id="apellidos" name="apellidos" class="form-control" required
                       value="<%= esEdicion ? cliente.getApellidos() : "" %>" placeholder="Ej: Rodríguez"
                       minlength="4" maxlength="40"
                       onblur="validarApellidosOnBlur()"
                       oninput="this.value = this.value.replace(/[^a-zA-ZáéíóúÁÉÍÓÚñÑ\s]/g, '')">
                <div id="apellidos-message" class="validation-message"></div>
                <small style="color:#888;font-size:0.8em;">Solo letras. Mínimo 4, máximo 40 caracteres</small>
            </div>
        </div>

        <!-- CHECKBOX EXTRANJERO (siempre disabled en edición) -->
        <div class="form-grupo checkbox-extranjero">
            <input type="checkbox" id="esExtranjero" name="esExtranjero"
                <%= esExtranjeroEdicion ? "checked" : "" %>
                <%= esEdicion ? "disabled" : "" %>
                onchange="toggleExtranjero()">
            <label for="esExtranjero">SOY EXTRANJERO (NO TENGO CÉDULA ECUATORIANA)</label>
            <% if (esEdicion) { %><small class="text-muted" style="display:block;color:#888;font-size:0.8em;margin-top:4px;">No se puede modificar el tipo de identificación</small><% } %>
        </div>

        <!-- FILA 2: Cédula / Identificación Extranjera (50% cada uno) -->
        <div class="form-row">
            <div class="form-grupo flex-half" id="grupo-cedula"
                 style="<%= esExtranjeroEdicion ? "display:none;" : "" %>">
                <label>Cédula *</label>
                <input type="text" id="cedula" name="cedula" class="form-control" required maxlength="10"
                       value="<%= esEdicion && !esExtranjeroEdicion ? cliente.getCedula() : "" %>"
                       placeholder="0912345678"
                    <%= esEdicion && !esExtranjeroEdicion ? "readonly class='form-control form-control-readonly'" : "" %>
                    <%= esExtranjeroEdicion ? "disabled" : "" %>
                       onblur="validarCedulaOnBlur()"
                       oninput="this.value = this.value.replace(/[^0-9]/g, '')">
                <div id="cedula-message" class="validation-message"></div>
                <small style="color:#888;font-size:0.8em;">10 dígitos numéricos</small>
            </div>
            <div class="form-grupo flex-half" id="grupo-identificacion"
                 style="<%= esExtranjeroEdicion ? "" : "display:none;" %>">
                <label>Identificación Extranjera *</label>
                <input type="text" id="identificacionExtranjera" name="identificacionExtranjera" class="form-control"
                       value="<%= esEdicion ? cliente.getIdentificacionExtranjera() : "" %>"
                       placeholder="Pasaporte o ID extranjero"
                       minlength="5" maxlength="20"
                    <%= esEdicion && esExtranjeroEdicion ? "readonly class='form-control form-control-readonly'" : "" %>
                    <%= !esExtranjeroEdicion ? "disabled" : "" %>
                       onblur="validarIdentificacionOnBlur()"
                       oninput="this.value = this.value.replace(/[^a-zA-Z0-9]/g, '').trim()">
                <div id="identificacion-message" class="validation-message"></div>
                <small style="color:#888;font-size:0.8em;">5-20 caracteres alfanuméricos</small>
            </div>
        </div>

        <% if (esEdicion) { %>
            <!-- Hidden con cédula actual para que servlet la reciba aunque esté readonly -->
            <% if (!esExtranjeroEdicion && cliente.getCedula() != null) { %>
                <input type="hidden" name="cedula" value="<%= cliente.getCedula() %>">
            <% } %>
            <% if (esExtranjeroEdicion && cliente.getIdentificacionExtranjera() != null) { %>
                <input type="hidden" name="identificacionExtranjera" value="<%= cliente.getIdentificacionExtranjera() %>">
            <% } %>
        <% } %>

        <!-- FILA 3: Teléfono y Correo -->
        <div class="form-row">
            <div class="form-grupo">
                <label>Teléfono *</label>
                <input type="text" id="telefono" name="telefono" class="form-control" required
                       value="<%= esEdicion ? cliente.getTelefono() : "" %>" placeholder="0991234567"
                       minlength="10" maxlength="10"
                       onblur="validarTelefonoOnBlur()"
                       oninput="this.value = this.value.replace(/[^0-9]/g, '')">
                <div id="telefono-message" class="validation-message"></div>
                <small style="color:#888;font-size:0.8em;">Exactamente 10 dígitos</small>
            </div>
            <div class="form-grupo">
                <label>Correo Electrónico *</label>
                <input type="email" id="correo" name="correo" class="form-control" required
                       value="<%= esEdicion ? cliente.getCorreo() : "" %>" placeholder="correo@ejemplo.com"
                       onblur="validarCorreoOnBlur()">
                <div id="correo-message" class="validation-message"></div>
                <small style="color:#888;font-size:0.8em;">Mínimo 4 caracteres antes del @</small>
            </div>
        </div>

        <!-- DIRECCIÓN -->
        <div class="form-grupo">
            <label>Dirección *</label>
            <textarea id="direccion" name="direccion" class="form-control" required
                      minlength="10" maxlength="300"
                      onblur="validarDireccionOnBlur()"
                      oninput="actualizarContador(this, 300)"><%= esEdicion ? cliente.getDireccion() : "" %></textarea>
            <div id="direccion-message" class="validation-message"></div>
            <small style="color:#888;font-size:0.8em;">Mínimo 10 caracteres</small>
        </div>

        <% if (!esEdicion) { %>
        <hr style="margin:20px 0;border-color:var(--borde);">
        <h3 style="font-family:'Playfair Display',serif;color:var(--marron);margin-bottom:15px;">Credenciales de acceso</h3>

        <!-- FILA 4: Usuario (ancho completo) -->
        <div class="form-grupo">
            <label>Nombre de Usuario *</label>
            <input type="text" id="username" name="username" class="form-control" required
                   minlength="4" maxlength="30" placeholder="usuario_ejemplo"
                   onblur="validarUsuarioOnBlur()"
                   oninput="this.value = this.value.replace(/\s/g, '')">
            <div id="username-message" class="validation-message"></div>
            <small style="color:#888;font-size:0.8em;">Sin espacios. Mínimo 4 caracteres</small>
        </div>

        <!-- FILA 5: Contraseña y Confirmar (2 columnas) -->
        <div class="form-row">
            <div class="form-grupo">
                <label>Contraseña *</label>
                <div class="password-wrapper">
                    <input type="password" id="contrasena" name="password" class="form-control" required
                           minlength="8"
                           onblur="validarContrasenaOnBlur()">
                    <button type="button" class="password-toggle" data-target="contrasena"
                            onclick="togglePasswordVisibility('contrasena')">👁️</button>
                </div>
                <div id="contrasena-message" class="validation-message"></div>
                <small style="color:#888;font-size:0.8em;">Mínimo 8 caracteres, 1 mayúscula, 1 carácter especial</small>
            </div>
            <div class="form-grupo">
                <label>Confirmar Contraseña *</label>
                <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" required
                       minlength="8"
                       onblur="validarConfirmacionOnBlur()">
                <div id="confirmPassword-message" class="validation-message"></div>
            </div>
        </div>
        <% } %>

        <!-- BOTONES -->
        <div style="display:flex;gap:15px;margin-top:25px;">
            <button type="submit" class="btn btn-primario" id="btnSubmit">
                <%= esEdicion ? "Actualizar Cliente" : "Registrar Cliente" %>
            </button>
            <a href="${pageContext.request.contextPath}/empleado<%= esEdicion && cliente != null ? "?accion=buscarId&id=" + cliente.getId() : "" %>"
               class="btn btn-secundario">Cancelar</a>
        </div>
    </form>
</div>

<script>
    var contextPath = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/js/validaciones.js"></script>
<script src="${pageContext.request.contextPath}/js/extranjero.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Sincronizar estado del checkbox extranjero al cargar (edición)
        <% if (esEdicion) { %>
            toggleExtranjero();
        <% } %>
    });

    // SweetAlert de confirmación antes de enviar
    document.getElementById('formCliente').addEventListener('submit', function(e) {
        e.preventDefault();

        var esEdit = <%= esEdicion %>;
        var titulo = esEdit ? '¿Actualizar datos del cliente?' : '¿Registrar nuevo cliente?';
        var texto = esEdit ? 'Se actualizarán los datos del cliente' : 'Se registrará un nuevo cliente en el sistema';

        Swal.fire({
            title: titulo,
            text: texto,
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#28a745',
            cancelButtonColor: '#6c757d',
            confirmButtonText: esEdit ? 'Sí, actualizar' : 'Sí, registrar',
            cancelButtonText: 'Cancelar',
            allowOutsideClick: false
        }).then(function(result) {
            if (result.isConfirmed) {
                var btn = document.getElementById('btnSubmit');
                if (btn) { btn.disabled = true; btn.textContent = esEdit ? 'Actualizando...' : 'Registrando...'; }
                e.target.submit();
            }
        });
    });
</script>
</body>
</html>
