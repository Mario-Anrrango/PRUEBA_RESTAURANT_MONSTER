<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de Cliente – Restaurant Master Monster</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/validaciones.css">
</head>
<body>
<div style="padding:20px;">
<div class="encabezado">
    <h1>Restaurant Master Monster</h1>
    <img src="${pageContext.request.contextPath}/img/LOGO_EMPRESA/Monster.jpg" alt="Logo" class="logo-encabezado">
</div>

<div class="contenedor contenedor-medio" style="margin-top:25px;">
    <h2 class="titulo-seccion">Registro de Nuevo Cliente</h2>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alerta alerta-error">${error}</div>
    <% } %>

    <form action="${pageContext.request.contextPath}/registro" method="post">
        <div class="form-row">
            <div class="form-grupo">
                <label>Nombres *</label>
                <input type="text" name="nombres" class="form-control" required placeholder="Ej: María Fernanda"
                       minlength="4" maxlength="40">
            </div>
            <div class="form-grupo">
                <label>Apellidos *</label>
                <input type="text" name="apellidos" class="form-control" required placeholder="Ej: García López"
                       minlength="4" maxlength="40">
            </div>
        </div>

        <div class="form-grupo">
            <label style="display:flex;align-items:center;gap:8px;">
                <input type="checkbox" id="esExtranjero" name="esExtranjero" onchange="toggleExtranjero()">
                <span>Soy extranjero (no tengo cédula ecuatoriana)</span>
            </label>
        </div>

        <div class="form-row">
            <div class="form-grupo">
                <label>Cédula Ecuatoriana *</label>
                <input type="text" name="cedula" class="form-control" required maxlength="10"
                       id="cedulaInput"
                       pattern="[0-9]{10}" title="10 dígitos numéricos" placeholder="0912345678">
                <small style="color:#888;font-size:0.8em;">10 dígitos numéricos</small>
            </div>
            <div class="form-grupo" id="extranjeroGroup" style="display:none;">
                <label>Identificación Extranjera *</label>
                <input type="text" name="identificacionExtranjera" class="form-control"
                       id="extranjeroInput" disabled
                       placeholder="Pasaporte o ID extranjero" minlength="5" maxlength="20">
                <small style="color:#888;font-size:0.8em;">5-20 caracteres alfanuméricos</small>
            </div>
        </div>

        <div class="form-row">
            <div class="form-grupo">
                <label>Teléfono</label>
                <input type="text" name="telefono" class="form-control" maxlength="10" placeholder="Ej: 0991234567">
            </div>
            <div class="form-grupo">
                <label>Correo Electrónico</label>
                <input type="email" name="correo" class="form-control" placeholder="correo@ejemplo.com">
            </div>
        </div>
        <div class="form-grupo">
            <label>Dirección</label>
            <input type="text" name="direccion" class="form-control" placeholder="Av. Principal 123, Quito"
                   minlength="10" maxlength="200">
        </div>
        <hr style="margin:20px 0;border-color:var(--borde);">
        <h3 style="font-family:'Playfair Display',serif;color:var(--marron);margin-bottom:15px;">Datos de acceso</h3>
        <div class="form-row">
            <div class="form-grupo">
                <label>Nombre de Usuario *</label>
                <input type="text" name="username" class="form-control" required placeholder="usuario_ejemplo"
                       minlength="4" maxlength="30">
                <small style="color:#888;font-size:0.8em;">Solo letras, números y _. Sin espacios</small>
            </div>
            <div class="form-grupo">
                <label>Contraseña *</label>
                <input type="password" name="password" id="password" class="form-control" required minlength="8">
                <small style="color:#888;font-size:0.8em;">Mínimo 8 caracteres, 1 mayúscula y 1 carácter especial</small>
                <div id="error-password" class="error-message"></div>
            </div>
            <div class="form-grupo">
                <label>Confirmar Contraseña *</label>
                <input type="password" id="confirmPassword" class="form-control" required minlength="8">
                <div id="error-confirm" class="error-message"></div>
            </div>
        </div>
        <div style="display:flex;gap:15px;margin-top:10px;">
            <button type="submit" class="btn btn-primario">Registrarme</button>
            <a href="${pageContext.request.contextPath}/login" class="btn btn-secundario">Cancelar</a>
        </div>
    </form>
</div>
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
        validarContrasena(document.getElementById('password'));
        validarConfirmacionContrasena(document.getElementById('password'), document.getElementById('confirmPassword'));
    });
</script>
</body>
</html>
