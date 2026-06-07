<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar Sesión – Restaurant Master Monster</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body>
<div class="login-wrapper">
    <div class="login-card">
        <img src="${pageContext.request.contextPath}/img/LOGO_EMPRESA/Monster.jpg"
             alt="Logo" class="login-logo">
        <h2 class="login-titulo">Restaurant Master Monster</h2>
        <p class="login-subtitulo">Ingresa con tu cuenta</p>

        <% if (request.getParameter("registrado") != null) { %>
            <div class="alerta alerta-exito">¡Registro exitoso! Ya puedes iniciar sesión.</div>
        <% } %>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alerta alerta-error">${error}</div>
        <% } %>

        <form action="${pageContext.request.contextPath}/login" method="post">
            <div class="form-grupo">
                <label for="username">Usuario</label>
                <input type="text" id="username" name="username" class="form-control"
                       placeholder="Nombre de usuario" required autofocus>
            </div>
            <div class="form-grupo">
                <label for="password">Contraseña</label>
                <input type="password" id="password" name="password" class="form-control"
                       placeholder="Contraseña" required>
            </div>
            <button type="submit" class="btn btn-primario" style="width:100%;margin-top:8px;">
                Iniciar Sesión
            </button>
        </form>

        <a href="${pageContext.request.contextPath}/registro" class="login-link">
            ¿No tienes cuenta? Regístrate como cliente
        </a>
    </div>
</div>
</body>
</html>
