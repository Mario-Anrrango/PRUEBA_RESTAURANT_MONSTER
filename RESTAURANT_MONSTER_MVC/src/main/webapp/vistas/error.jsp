<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Error – Restaurant Master Monster</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body>
<div style="min-height:100vh;display:flex;align-items:center;justify-content:center;background:#f9f3e6;">
    <div class="contenedor contenedor-angosto" style="text-align:center;padding:50px 40px;">
        <div style="font-size:4em;margin-bottom:15px;">🍽️</div>
        <h2 style="font-family:'Playfair Display',serif;color:#8b4513;font-size:2em;">
            ¡Ups! Algo salió mal
        </h2>
        <p style="color:#888;margin:15px 0 25px;">
            La página que buscas no está disponible en este momento.
        </p>
        <a href="${pageContext.request.contextPath}/login" class="btn btn-primario">Volver al inicio</a>
    </div>
</div>
</body>
</html>
