<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.*" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"ADMIN".equals(usuario.getPerfil())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    Empleado empleado = (Empleado) request.getAttribute("empleado");
    boolean esEdicion = (empleado != null && empleado.getId() != null && !empleado.getId().isEmpty());
    boolean esExtranjero = esEdicion && (empleado.isEsExtranjero() || 
        (empleado.getIdentificacionExtranjera() != null && !empleado.getIdentificacionExtranjera().isEmpty()));
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title><%= esEdicion ? "Editar" : "Registrar" %> Empleado – Admin</title>
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
        <li><a href="${pageContext.request.contextPath}/admin?accion=listarClientes">Clientes</a></li>
        <li><a href="${pageContext.request.contextPath}/admin?accion=listarEmpleados" class="activo">Empleados</a></li>
        <li><a href="${pageContext.request.contextPath}/logout">Cerrar Sesión</a></li>
    </ul>
    <span class="navbar-user">Admin: <%= usuario.getUsername() %></span>
</nav>

<div class="contenedor contenedor-medio" style="margin-top:25px;">
    <h2 class="titulo-seccion"><%= esEdicion ? "Editar Empleado" : "Registrar Nuevo Empleado" %></h2>

    <% if (request.getAttribute("error") != null) { %><div class="alerta alerta-error">${error}</div><% } %>

    <form id="formEmpleado" action="${pageContext.request.contextPath}/admin" method="post">
        <input type="hidden" name="accion" value="<%= esEdicion ? "actualizarEmpleado" : "registrarEmpleado" %>">
        <% if (esEdicion) { %><input type="hidden" name="id" value="<%= empleado.getId() %>">
        <input type="hidden" name="esExtranjero" value="<%= esExtranjero ? "on" : "" %>"><% } %>

        <!-- FILA 1: Nombres + Apellidos -->
        <div class="form-row">
            <div class="form-grupo">
                <label>Nombres *</label>
                <input type="text" id="nombres" name="nombres" class="form-control" required
                       value="<%= esEdicion ? empleado.getNombres() : "" %>" placeholder="Ej: Juan Carlos"
                       minlength="4" maxlength="40"
                       onblur="validarNombresOnBlur()">
                <div id="nombres-message" class="validation-message"></div>
                <small style="color:#888;font-size:0.8em;">Solo letras. Mínimo 4, máximo 40 caracteres</small>
            </div>
            <div class="form-grupo">
                <label>Apellidos *</label>
                <input type="text" id="apellidos" name="apellidos" class="form-control" required
                       value="<%= esEdicion ? empleado.getApellidos() : "" %>" placeholder="Ej: Pérez Mora"
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
                               value="<%= empleado.getIdentificacionExtranjera() %>">
                        <small style="color:#888;font-size:0.8em;">No modificable</small>
                    </div>
                <% } else { %>
                    <!-- Edición NACIONAL: solo mostrar cédula -->
                    <div class="form-grupo" id="grupo-cedula">
                        <label>Cédula Ecuatoriana *</label>
                        <input type="text" id="cedula" name="cedula"
                               class="form-control field-disabled" readonly disabled
                               value="<%= empleado.getCedula() %>">
                        <small style="color:#888;font-size:0.8em;">10 dígitos numéricos (no modificable)</small>
                    </div>
                <% } %>
            <% } else { %>
                <!-- CREACIÓN: toggle entre cédula e identificación -->
                <div class="form-grupo" id="grupo-cedula">
                    <label>Cédula Ecuatoriana *</label>
                    <input type="text" id="cedula" name="cedula" class="form-control" required maxlength="10"
                           pattern="[0-9]{10}" title="10 dígitos numéricos" placeholder="0912345678"
                           onblur="validarCedulaEmpleadoOnBlur()">
                    <div id="cedula-message" class="validation-message"></div>
                    <small style="color:#888;font-size:0.8em;">10 dígitos numéricos</small>
                </div>
                <div class="form-grupo" id="grupo-identificacion" style="display:none;">
                    <label>Identificación Extranjera *</label>
                    <input type="text" id="identificacionExtranjera" name="identificacionExtranjera"
                           class="form-control" disabled
                           placeholder="Pasaporte o ID extranjero" minlength="5" maxlength="20"
                           oninput="this.value = this.value.replace(/[^a-zA-Z0-9]/g, '').trim()"
                           onblur="validarIdentificacionEmpleadoOnBlur()">
                    <div id="identificacion-message" class="validation-message"></div>
                    <small style="color:#888;font-size:0.8em;">5-20 caracteres alfanuméricos</small>
                </div>
            <% } %>
        </div>

        <!-- CARGO -->
        <div class="form-grupo">
            <label>Cargo *</label>
            <select id="cargo" name="cargo" class="form-control" required onchange="validarCargoEmpleado()">
                <option value="">-- Seleccionar --</option>
                <option value="EMPLEADO" <%= esEdicion && ("EMPLEADO".equals(empleado.getCargo()) || "Mesero".equals(empleado.getCargo())) ? "selected" : "" %>>MESERO</option>
                <option value="ADMIN" <%= esEdicion && ("ADMIN".equals(empleado.getCargo()) || "Admin".equals(empleado.getCargo())) ? "selected" : "" %>>ADMINISTRADOR</option>
            </select>
            <div id="cargo-message" class="validation-message"></div>
            <small style="color:#888;font-size:0.8em;">Seleccione un cargo</small>
        </div>

        <!-- FILA 2: Teléfono + Correo -->
        <div class="form-row">
            <div class="form-grupo">
                <label>Teléfono *</label>
                <input type="text" id="telefono" name="telefono" class="form-control" maxlength="10"
                       value="<%= esEdicion ? (empleado.getTelefono() != null ? empleado.getTelefono() : "") : "" %>"
                       placeholder="0991234567" required
                       onblur="validarTelefonoOnBlur()">
                <div id="telefono-message" class="validation-message"></div>
                <small style="color:#888;font-size:0.8em;">Exactamente 10 dígitos</small>
            </div>
            <div class="form-grupo">
                <label>Correo Electrónico *</label>
                <input type="email" id="correo" name="correo" class="form-control" required
                       value="<%= esEdicion ? (empleado.getCorreo() != null ? empleado.getCorreo() : "") : "" %>"
                       placeholder="correo@ejemplo.com"
                       onblur="validarCorreoOnBlur()">
                <div id="correo-message" class="validation-message"></div>
                <small style="color:#888;font-size:0.8em;">Mínimo 4 caracteres antes del @, formato válido</small>
            </div>
        </div>

        <!-- CREDENCIALES (solo en creación) -->
        <% if (!esEdicion) { %>
        <hr style="margin:20px 0;border-color:var(--borde);">
        <h3 style="font-family:'Playfair Display',serif;color:var(--marron);margin-bottom:15px;">Credenciales de acceso</h3>

        <!-- Usuario -->
        <div class="form-grupo">
            <label>Nombre de Usuario *</label>
            <input type="text" id="username" name="username" class="form-control" required
                   placeholder="usuario_empleado" minlength="4" maxlength="30"
                   onblur="validarUsuarioEmpleadoOnBlur()">
            <div id="username-message" class="validation-message"></div>
            <small style="color:#888;font-size:0.8em;">Solo letras, números y _. Sin espacios</small>
        </div>

        <!-- FILA 3: Contraseña + Confirmar -->
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

        <!-- Hidden inputs para disabled fields en edición -->
        <% if (esEdicion) { %>
            <input type="hidden" name="identificacionExtranjera" value="<%= esExtranjero ? empleado.getIdentificacionExtranjera() : "" %>">
            <input type="hidden" name="cedula" value="<%= !esExtranjero ? empleado.getCedula() : "" %>">
        <% } %>

        <!-- BOTONES -->
        <div style="display:flex;gap:15px;margin-top:15px;">
            <button type="submit" class="btn btn-primario" id="btnSubmitEmpleado">
                <%= esEdicion ? "Actualizar Empleado" : "Registrar Empleado" %>
            </button>
            <a href="${pageContext.request.contextPath}/admin?accion=listarEmpleados" class="btn btn-secundario">Cancelar</a>
        </div>
    </form>
</div>

<script src="${pageContext.request.contextPath}/js/validaciones.js"></script>
<script src="${pageContext.request.contextPath}/js/extranjero.js"></script>
<script>
// ===== CARGO VALIDATION =====
function validarCargoEmpleado() {
    var select = document.getElementById('cargo');
    var msgId = 'cargo-message';
    var valor = select.value;
    if (!valor || valor.trim() === '') {
        window.mostrarError(select, msgId, 'Seleccione un cargo');
        return false;
    }
    window.mostrarExito(select, msgId, '');
    return true;
}

// ===== VALIDACIÓN AJAX PARA EMPLEADOS (contra colección empleados, NO clientes) =====
function validarCedulaEmpleadoOnBlur() {
    var input = document.getElementById('cedula');
    var msgId = 'cedula-message';
    if (!input || input.disabled) { window.limpiarError(input, msgId); return true; }
    var valor = input.value.trim();
    if (valor.length === 0) { window.mostrarError(input, msgId, 'Campo obligatorio'); return false; }
    if (valor.length < 10) { window.mostrarError(input, msgId, 'La cédula debe tener 10 dígitos'); return false; }
    if (!window.validarCedulaEcuatoriana(valor)) { window.mostrarError(input, msgId, 'Cédula inválida'); return false; }
    var xhr = new XMLHttpRequest();
    xhr.open('GET', contextPath + '/admin?accion=validarCedulaEmpleado&cedula=' + encodeURIComponent(valor), true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            try {
                var r = JSON.parse(xhr.responseText);
                if (r.valid) { window.mostrarExito(input, msgId, 'Cédula válida'); }
                else { window.mostrarError(input, msgId, r.message); }
            } catch(e) {}
        }
    };
    xhr.send();
    return true;
}

function validarIdentificacionEmpleadoOnBlur() {
    var input = document.getElementById('identificacionExtranjera');
    var msgId = 'identificacion-message';
    if (!input || input.disabled) { window.limpiarError(input, msgId); return true; }
    var valor = input.value.trim();
    if (valor.length === 0) { window.mostrarError(input, msgId, 'Campo obligatorio'); return false; }
    if (valor.length < 5) { window.mostrarError(input, msgId, 'Mínimo 5 caracteres'); return false; }
    if (valor.length > 20) { window.mostrarError(input, msgId, 'Máximo 20 caracteres'); return false; }
    if (!/^[a-zA-Z0-9]+$/.test(valor)) { window.mostrarError(input, msgId, 'Solo letras y números'); return false; }
    var xhr = new XMLHttpRequest();
    xhr.open('GET', contextPath + '/admin?accion=validarIdentificacionEmpleado&identificacion=' + encodeURIComponent(valor), true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            try {
                var r = JSON.parse(xhr.responseText);
                if (r.valid) { window.mostrarExito(input, msgId, 'Identificación válida'); }
                else { window.mostrarError(input, msgId, r.message); }
            } catch(e) {}
        }
    };
    xhr.send();
    return true;
}

function validarUsuarioEmpleadoOnBlur() {
    var input = document.getElementById('username');
    var msgId = 'username-message';
    var valor = input.value.trim();
    if (valor.length === 0) { window.mostrarError(input, msgId, 'Campo obligatorio'); return false; }
    if (valor.length < 4) { window.mostrarError(input, msgId, 'Mínimo 4 caracteres'); return false; }
    if (valor.includes(' ')) { window.mostrarError(input, msgId, 'No se permiten espacios'); return false; }
    var xhr = new XMLHttpRequest();
    xhr.open('GET', contextPath + '/admin?accion=validarUsuarioEmpleado&usuario=' + encodeURIComponent(valor), true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            try {
                var r = JSON.parse(xhr.responseText);
                if (r.valid) { window.mostrarExito(input, msgId, 'Usuario válido'); }
                else { window.mostrarError(input, msgId, r.message); }
            } catch(e) {}
        }
    };
    xhr.send();
    return true;
}

// ===== EVENT HANDLERS =====
document.addEventListener('DOMContentLoaded', function() {
    // --- FILTROS EN TIEMPO REAL ---
    validarSoloLetras(document.getElementById('nombres'));
    validarSoloLetras(document.getElementById('apellidos'));
    validarSoloNumeros(document.getElementById('telefono'));
    var cedulaInput = document.getElementById('cedula');
    if (cedulaInput) validarSoloNumeros(cedulaInput);
    var usernameInput = document.getElementById('username');
    if (usernameInput) validarUsuario(usernameInput);
    // Identificación extranjera: oninput filter (for create mode)
    var identInput = document.getElementById('identificacionExtranjera');
    if (identInput && !identInput.disabled) {
        identInput.addEventListener('input', function() {
            this.value = this.value.replace(/[^a-zA-Z0-9]/g, '').trim();
        });
    }

    // --- INICIALIZAR MENSAJE DE CARGO SI YA TIENE VALOR ---
    var cargoSelect = document.getElementById('cargo');
    if (cargoSelect && cargoSelect.value !== '') {
        var msgCargo = document.getElementById('cargo-message');
        if (msgCargo) {
            msgCargo.textContent = '';
            msgCargo.className = 'validation-message';
        }
    }

    // --- VALIDACIÓN PREVIA AL ENVÍO ---
    var form = document.getElementById('formEmpleado');
    if (form) {
        form.addEventListener('submit', function(e) {
            var errores = [];

            // Validar campos visibles
            if (!validarNombresOnBlur()) errores.push('Nombres');
            if (!validarApellidosOnBlur()) errores.push('Apellidos');
            if (!validarCargoEmpleado()) errores.push('Cargo');
            if (!validarTelefonoOnBlur()) errores.push('Teléfono');
            if (!validarCorreoOnBlur()) errores.push('Correo');

            // Validar cédula o identificación (solo el visible) — usando funciones específicas de empleados
            if (document.getElementById('grupo-cedula') && document.getElementById('grupo-cedula').style.display !== 'none') {
                if (!validarCedulaEmpleadoOnBlur()) errores.push('Cédula');
            }
            if (document.getElementById('grupo-identificacion') && document.getElementById('grupo-identificacion').style.display !== 'none') {
                if (!validarIdentificacionEmpleadoOnBlur()) errores.push('Identificación');
            }

            // Validar credenciales (solo en creación)
            var pwdInput = document.getElementById('contrasena');
            if (pwdInput) {
                if (!validarContrasenaOnBlur()) errores.push('Contraseña');
                if (!validarConfirmacionOnBlur()) errores.push('Confirmar contraseña');
            }
            var usrInput = document.getElementById('username');
            if (usrInput) {
                if (!validarUsuarioEmpleadoOnBlur()) errores.push('Usuario');
            }

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

            // Confirmación
            e.preventDefault();
            var modo = '<%= esEdicion ? "editar" : "crear" %>';
            Swal.fire({
                title: modo === 'editar' ? '¿Actualizar empleado?' : '¿Registrar empleado?',
                text: modo === 'editar' ? 'Se actualizarán los datos del empleado' : 'Se registrará un nuevo empleado',
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#28a745',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Sí, confirmar',
                cancelButtonText: 'Cancelar'
            }).then(function(result) {
                if (result.isConfirmed) {
                    var btn = document.getElementById('btnSubmitEmpleado');
                    if (btn) { btn.disabled = true; btn.textContent = modo === 'editar' ? 'Actualizando...' : 'Registrando...'; }
                    form.submit();
                }
            });
        });
    }
});
</script>
</body>
</html>
