<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de Cliente – Restaurant Master Monster</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
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

    <form action="${pageContext.request.contextPath}/registro" method="post"
          onsubmit="return validarFormulario(event)">
        <div class="form-row">
            <div class="form-grupo">
                <label>Nombres *</label>
                <input type="text" name="nombres" class="form-control" required placeholder="Ej: María Fernanda"
                       onkeydown="bloquearTecladoNumerico(event)" oninput="permitirSoloLetras(this)">
            </div>
            <div class="form-grupo">
                <label>Apellidos *</label>
                <input type="text" name="apellidos" class="form-control" required placeholder="Ej: García López"
                       onkeydown="bloquearTecladoNumerico(event)" oninput="permitirSoloLetras(this)">
            </div>
        </div>
        <div class="form-row">
            <div class="form-grupo">
                <label>Cédula Ecuatoriana *</label>
                <input type="text" name="cedula" id="cedula" class="form-control" required maxlength="10"
                       pattern="[0-9]{10}" title="10 dígitos numéricos" placeholder="0912345678"
                       onkeydown="bloquearTecladoAlfabetico(event)" oninput="permitirSoloNumeros(this, 10)">
            </div>
            <div class="form-grupo">
                <label>Teléfono</label>
                <input type="text" name="telefono" id="telefono" class="form-control"
                       placeholder="Ej: 0991234567" maxlength="10"
                       onkeydown="bloquearTecladoAlfabetico(event)" oninput="permitirSoloNumeros(this, 10)">
            </div>
        </div>
        <div class="form-grupo">
            <label>Correo Electrónico</label>
            <input type="email" name="correo" id="correo" class="form-control"
                   placeholder="correo@ejemplo.com" onkeydown="bloquearCaracteresCorreo(event)">
        </div>
        <div class="form-grupo">
            <label>Dirección</label>
            <input type="text" name="direccion" class="form-control" placeholder="Av. Principal 123, Quito">
        </div>
        <hr style="margin:20px 0;border-color:var(--borde);">
        <h3 style="font-family:'Playfair Display',serif;color:var(--marron);margin-bottom:15px;">Datos de acceso</h3>
        <div class="form-row">
            <div class="form-grupo">
                <label>Nombre de Usuario *</label>
                <input type="text" name="username" class="form-control" required placeholder="usuario_ejemplo">
            </div>
            <div class="form-grupo">
                <label>Contraseña *</label>
                <input type="password" name="password" class="form-control" required minlength="4">
            </div>
        </div>
        <div style="display:flex;gap:15px;margin-top:10px;">
            <button type="submit" class="btn btn-primario">Registrarme</button>
            <a href="${pageContext.request.contextPath}/login" class="btn btn-secundario">Cancelar</a>
        </div>
    </form>
</div>
</div>
<script src="${pageContext.request.contextPath}/js/validacionCliente.js"></script>
</body>
</html>
