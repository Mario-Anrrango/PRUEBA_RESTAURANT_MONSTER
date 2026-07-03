<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.*" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"ADMIN".equals(usuario.getPerfil())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    Cliente cliente = (Cliente) request.getAttribute("cliente");
    boolean esEdicion = (cliente != null && cliente.getId() != null && !cliente.getId().isEmpty());
    boolean esExtranjero = esEdicion && cliente.isEsExtranjero();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title><%= esEdicion ? "Editar" : "Registrar" %> Cliente – Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/validaciones.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>var contextPath = '${pageContext.request.contextPath}';</script>
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

    <% if (request.getAttribute("error") != null) { %><div class="alerta alerta-error">${error}</div><% } %>

    <form action="${pageContext.request.contextPath}/admin" method="post" id="formCliente">
        <input type="hidden" name="accion" value="<%= esEdicion ? "actualizarCliente" : "registrarCliente" %>">
        <% if (esEdicion) { %><input type="hidden" name="id" value="<%= cliente.getId() %>"><% } %>

        <!-- NOMBRES -->
        <div class="form-row">
            <div class="form-grupo">
                <label>Nombres *</label>
                <input type="text" id="nombres" name="nombres" class="form-control" required
                       value="<%= esEdicion ? cliente.getNombres() : "" %>" placeholder="Ej: Juan Carlos"
                       minlength="4" maxlength="40"
                       onblur="validarNombresOnBlur()">
                <div id="nombres-message" class="validation-message"></div>
                <small style="color:#888;font-size:0.8em;">Solo letras. Mínimo 4, máximo 40 caracteres</small>
            </div>
            <div class="form-grupo">
                <label>Apellidos *</label>
                <input type="text" id="apellidos" name="apellidos" class="form-control" required
                       value="<%= esEdicion ? cliente.getApellidos() : "" %>" placeholder="Ej: Pérez Mora"
                       minlength="4" maxlength="40"
                       onblur="validarApellidosOnBlur()">
                <div id="apellidos-message" class="validation-message"></div>
                <small style="color:#888;font-size:0.8em;">Solo letras. Mínimo 4, máximo 40 caracteres</small>
            </div>
        </div>

        <!-- CHECKBOX EXTRANJERO (disabled en edición) -->
        <div class="form-grupo checkbox-extranjero">
            <input type="checkbox" id="esExtranjero" name="esExtranjero"
                <%= esExtranjero ? "checked" : "" %>
                <%= esEdicion ? "disabled" : "onchange=\"toggleExtranjero()\"" %>>
            <label for="esExtranjero">Soy extranjero (no tengo cédula ecuatoriana)</label>
        </div>

        <!-- CÉDULA / IDENTIFICACIÓN -->
        <div class="form-row">
            <% if (esEdicion) { %>
                <% if (esExtranjero) { %>
                    <!-- Edición EXTRANJERO: solo mostrar identificación -->
                    <div class="form-grupo" id="grupo-identificacion">
                        <label>Identificación Extranjera *</label>
                        <input type="text" id="identificacionExtranjera" name="identificacionExtranjera"
                               class="form-control field-disabled" readonly disabled
                               value="<%= cliente.getIdentificacionExtranjera() %>">
                        <small style="color:#888;font-size:0.8em;">No modificable</small>
                    </div>
                <% } else { %>
                    <!-- Edición NACIONAL: solo mostrar cédula -->
                    <div class="form-grupo" id="grupo-cedula">
                        <label>Cédula Ecuatoriana *</label>
                        <input type="text" id="cedula" name="cedula"
                               class="form-control field-disabled" readonly disabled
                               value="<%= cliente.getCedula() %>">
                        <small style="color:#888;font-size:0.8em;">10 dígitos numéricos (no modificable)</small>
                    </div>
                <% } %>
            <% } else { %>
                <!-- CREACIÓN: toggle entre cédula e identificación -->
                <div class="form-grupo" id="grupo-cedula">
                    <label>Cédula Ecuatoriana *</label>
                    <input type="text" id="cedula" name="cedula" class="form-control" required maxlength="10"
                           pattern="[0-9]{10}" title="10 dígitos numéricos" placeholder="0912345678"
                           onblur="validarCedulaOnBlur()">
                    <div id="cedula-message" class="validation-message"></div>
                    <small style="color:#888;font-size:0.8em;">10 dígitos numéricos</small>
                </div>
                <div class="form-grupo" id="grupo-identificacion" style="display:none;">
                    <label>Identificación Extranjera *</label>
                    <input type="text" id="identificacionExtranjera" name="identificacionExtranjera"
                           class="form-control" disabled
                           placeholder="Pasaporte o ID extranjero" minlength="5" maxlength="20"
                           onblur="validarIdentificacionOnBlur()">
                    <div id="identificacion-message" class="validation-message"></div>
                    <small style="color:#888;font-size:0.8em;">5-20 caracteres alfanuméricos</small>
                </div>
            <% } %>
        </div>

        <!-- TELÉFONO -->
        <div class="form-row">
            <div class="form-grupo">
                <label>Teléfono *</label>
                <input type="text" id="telefono" name="telefono" class="form-control" maxlength="10"
                       value="<%= esEdicion ? cliente.getTelefono() : "" %>" placeholder="0991234567" required
                       onblur="validarTelefonoOnBlur()">
                <div id="telefono-message" class="validation-message"></div>
            </div>
            <div class="form-grupo">
                <label>Correo Electrónico *</label>
                <input type="email" id="correo" name="correo" class="form-control" required
                       value="<%= esEdicion ? cliente.getCorreo() : "" %>" placeholder="correo@ejemplo.com"
                       onblur="validarCorreoOnBlur()">
                <div id="correo-message" class="validation-message"></div>
            </div>
        </div>

        <!-- DIRECCIÓN (TEXTAREA) -->
        <div class="form-grupo">
            <label>Dirección *</label>
            <textarea id="direccion" name="direccion" class="form-control" required rows="3"
                      placeholder="Calle, número, ciudad"
                      minlength="10" maxlength="300"
                      oninput="actualizarContador(this, 300)"
                      onblur="validarDireccionOnBlur()"><%= esEdicion ? cliente.getDireccion() : "" %></textarea>
            <small style="color:#888;font-size:0.8em;">Mínimo 10, máximo 300 caracteres</small>
            <div id="direccion-message" class="validation-message"></div>
        </div>

        <!-- CREDENCIALES (solo en creación) -->
        <% if (!esEdicion) { %>
        <hr style="margin:20px 0;border-color:var(--borde);">
        <h3 style="font-family:'Playfair Display',serif;color:var(--marron);margin-bottom:15px;">Credenciales de acceso</h3>

        <div class="form-grupo">
            <label>Nombre de Usuario *</label>
            <input type="text" id="username" name="username" class="form-control" required
                   placeholder="usuario_cliente" minlength="4" maxlength="30"
                   onblur="validarUsuarioOnBlur()">
            <div id="username-message" class="validation-message"></div>
            <small style="color:#888;font-size:0.8em;">Solo letras, números y _. Sin espacios</small>
        </div>

        <div class="form-row">
            <div class="form-grupo">
                <label>Contraseña *</label>
                <div class="password-wrapper">
                    <input type="password" id="contrasena" name="password" class="form-control" required minlength="8"
                           onblur="validarContrasenaOnBlur()">
                    <button type="button" class="password-toggle" data-target="contrasena"
                            onclick="togglePasswordVisibility('contrasena')" tabindex="-1">&#x1F441;</button>
                </div>
                <div id="contrasena-message" class="validation-message"></div>
                <small style="color:#888;font-size:0.8em;">Mínimo 8 caracteres, 1 mayúscula y 1 carácter especial</small>
            </div>
            <div class="form-grupo">
                <label>Confirmar Contraseña *</label>
                <input type="password" id="confirmPassword" class="form-control" required minlength="8"
                       onblur="validarConfirmacionOnBlur()">
                <div id="confirmPassword-message" class="validation-message"></div>
            </div>
        </div>
        <% } %>

        <!-- Hidden inputs para que disabled fields se envíen correctamente en edición -->
        <% if (esEdicion) { %>
            <input type="hidden" name="esExtranjero" value="<%= esExtranjero ? "on" : "" %>">
            <input type="hidden" name="identificacionExtranjera" value="<%= esExtranjero ? cliente.getIdentificacionExtranjera() : "" %>">
            <input type="hidden" name="cedula" value="<%= !esExtranjero ? cliente.getCedula() : "" %>">
        <% } %>

        <!-- BOTONES -->
        <div style="display:flex;gap:15px;margin-top:15px;">
            <button type="submit" class="btn btn-primario" id="btnSubmitCliente">
                <%= esEdicion ? "Actualizar Cliente" : "Registrar Cliente" %>
            </button>
            <a href="${pageContext.request.contextPath}/admin?accion=listarClientes" class="btn btn-secundario">Cancelar</a>
        </div>
    </form>
</div>

<script src="${pageContext.request.contextPath}/js/validaciones.js"></script>
<script src="${pageContext.request.contextPath}/js/extranjero.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    // --- FILTROS EN TIEMPO REAL ---
    validarSoloLetras(document.getElementById('nombres'));
    validarSoloLetras(document.getElementById('apellidos'));
    validarSoloNumeros(document.getElementById('telefono'));
    var cedulaInput = document.getElementById('cedula');
    if (cedulaInput) validarSoloNumeros(cedulaInput);
    var usernameInput = document.getElementById('username');
    if (usernameInput) validarUsuario(usernameInput);

    // --- VALIDACIÓN PREVIA AL ENVÍO ---
    document.getElementById('formCliente').addEventListener('submit', function(e) {
        var accion = this.querySelector('input[name="accion"]').value;

        if (accion === 'actualizarCliente') {
            // Edición: validar solo nombres, apellidos, teléfono, correo, dirección
            var errores = [];
            if (!validarNombresOnBlur()) errores.push('Nombres');
            if (!validarApellidosOnBlur()) errores.push('Apellidos');
            if (!validarTelefonoOnBlur()) errores.push('Teléfono');
            if (!validarCorreoOnBlur()) errores.push('Correo');
            if (!validarDireccionOnBlur()) errores.push('Dirección');

            if (errores.length > 0) {
                e.preventDefault();
                Swal.fire({
                    icon: 'error',
                    title: 'Errores de validación',
                    html: '<ul style="text-align:left;font-size:0.9em;margin:0;padding-left:20px;"><li>' +
                          errores.join('</li><li>') + '</li></ul>',
                    confirmButtonColor: '#8b4513',
                    confirmButtonText: 'Corregir'
                });
                return;
            }

            e.preventDefault();
            Swal.fire({
                title: '¿Actualizar cliente?',
                text: 'Se actualizarán los datos del cliente',
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#28a745',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Sí, actualizar',
                cancelButtonText: 'Cancelar'
            }).then(function(result) {
                if (result.isConfirmed) {
                    var btn = document.getElementById('btnSubmitCliente');
                    if (btn) { btn.disabled = true; btn.textContent = 'Actualizando...'; }
                    document.getElementById('formCliente').submit();
                }
            });
        } else {
            // Creación: validar todos los campos
            validarNombresOnBlur();
            validarApellidosOnBlur();
            validarTelefonoOnBlur();
            validarCorreoOnBlur();
            validarDireccionOnBlur();
            validarUsuarioOnBlur();
            validarContrasenaOnBlur();
            validarConfirmacionOnBlur();

            // Si el checkbox extranjero está activo, validar identificación
            if (document.getElementById('esExtranjero').checked) {
                validarIdentificacionOnBlur();
            }

            var errores = [];
            var msgDivs = document.getElementById('formCliente').querySelectorAll('.validation-message.error');
            for (var i = 0; i < msgDivs.length; i++) {
                var label = msgDivs[i].previousElementSibling;
                while (label && label.tagName !== 'LABEL') label = label.previousElementSibling;
                var nombreCampo = label ? label.textContent.replace(' *', '') : 'Un campo';
                errores.push(nombreCampo + ': ' + msgDivs[i].textContent);
            }

            if (errores.length > 0) {
                e.preventDefault();
                var lista = errores.map(function(e) { return '<li>' + e + '</li>'; }).join('');
                Swal.fire({
                    icon: 'error',
                    title: 'Errores en el formulario',
                    html: '<ul style="text-align:left;font-size:0.9em;margin:0;padding-left:20px;">' + lista + '</ul>',
                    confirmButtonColor: '#8b4513',
                    confirmButtonText: 'Corregir'
                });
                return;
            }

            e.preventDefault();
            Swal.fire({
                title: '¿Registrar cliente?',
                text: 'Se creará un nuevo cliente con los datos ingresados',
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#28a745',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Sí, registrar',
                cancelButtonText: 'Cancelar'
            }).then(function(result) {
                if (result.isConfirmed) {
                    var btn = document.getElementById('btnSubmitCliente');
                    if (btn) { btn.disabled = true; btn.textContent = 'Registrando...'; }
                    document.getElementById('formCliente').submit();
                }
            });
        }
    });
});
</script>
</body>
</html>
