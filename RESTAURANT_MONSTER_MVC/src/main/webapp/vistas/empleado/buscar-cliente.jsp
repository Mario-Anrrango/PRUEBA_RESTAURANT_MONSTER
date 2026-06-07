<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.*,java.util.*" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"EMPLEADO".equals(usuario.getPerfil())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    Cliente clienteEncontrado = (Cliente) request.getAttribute("clienteEncontrado");
    List<Pedido> historial     = (List<Pedido>) request.getAttribute("historialPedidos");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Buscar Cliente – Empleado</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body>
<div class="encabezado">
    <h1>Restaurant Master Monster</h1>
    <img src="${pageContext.request.contextPath}/img/LOGO_EMPRESA/Monster.jpg" alt="Logo" class="logo-encabezado">
</div>
<nav class="navbar">
    <ul class="navbar-links">
        <li><a href="${pageContext.request.contextPath}/empleado">Inicio</a></li>
        <li><a href="${pageContext.request.contextPath}/empleado?accion=formCliente">Registrar Cliente</a></li>
        <li><a href="${pageContext.request.contextPath}/empleado?accion=buscarCliente" class="activo">Buscar Cliente</a></li>
        <li><a href="${pageContext.request.contextPath}/logout">Cerrar Sesión</a></li>
    </ul>
    <span class="navbar-user">Mesero: <%= usuario.getUsername() %></span>
</nav>

<div class="contenedor" style="margin-top:25px;">
    <h2 class="titulo-seccion">Buscar Cliente por Cédula</h2>

    <!-- Formulario de búsqueda -->
    <form action="${pageContext.request.contextPath}/empleado" method="post" class="busqueda-form">
        <input type="hidden" name="accion" value="buscarCedula">
        <div class="form-grupo">
            <label>Número de Cédula</label>
            <input type="text" name="cedula" class="form-control" maxlength="10"
                   pattern="[0-9]{10}" placeholder="0912345678" required autofocus>
        </div>
        <button type="submit" class="btn btn-primario" style="height:44px;margin-top:22px;">Buscar</button>
    </form>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alerta alerta-error">${error}</div>
    <% } %>

    <!-- Resultado de búsqueda -->
    <% if (clienteEncontrado != null) { %>
    <div style="background:#fef9f1;border:1px solid var(--borde);border-radius:12px;padding:20px;margin-top:10px;">
        <h3 style="font-family:'Playfair Display',serif;color:var(--marron);margin-bottom:15px;">
            Cliente Encontrado
        </h3>
        <table class="tabla" style="margin-top:0;">
            <tbody>
                <tr><td><strong>Nombre Completo:</strong></td><td><%= clienteEncontrado.getNombreCompleto() %></td>
                    <td><strong>Cédula:</strong></td><td><%= clienteEncontrado.getCedula() %></td></tr>
                <tr><td><strong>Teléfono:</strong></td><td><%= clienteEncontrado.getTelefono() != null ? clienteEncontrado.getTelefono() : "-" %></td>
                    <td><strong>Correo:</strong></td><td><%= clienteEncontrado.getCorreo() != null ? clienteEncontrado.getCorreo() : "-" %></td></tr>
                <tr><td colspan="4"><strong>Dirección:</strong> <%= clienteEncontrado.getDireccion() != null ? clienteEncontrado.getDireccion() : "-" %></td></tr>
            </tbody>
        </table>

        <div style="margin-top:20px;display:flex;gap:15px;flex-wrap:wrap;">
            <a href="${pageContext.request.contextPath}/empleado/tomar-pedido?idCliente=<%= clienteEncontrado.getId() %>"
               class="btn btn-exito">
                🍽️ Tomar Pedido Ahora
            </a>
        </div>

        <!-- Historial de pedidos -->
        <% if (historial != null && !historial.isEmpty()) { %>
        <h4 style="font-family:'Playfair Display',serif;color:var(--marron);margin:20px 0 10px;">
            Historial de Pedidos
        </h4>
        <table class="tabla">
            <thead>
                <tr><th>#</th><th>Fecha</th><th>Hora</th><th>Estado</th><th>Total</th><th>Detalle</th></tr>
            </thead>
            <tbody>
            <% for (Pedido p : historial) { %>
                <tr>
                    <td><%= p.getId() %></td>
                    <td><%= p.getFecha() %></td>
                    <td><%= p.getHora() %></td>
                    <td>
                        <span style="padding:3px 10px;border-radius:12px;font-size:0.85em;font-weight:600;
                            background:<%= "PAGADO".equals(p.getEstado()) ? "#e8f8f2" : "#fde8e8" %>;
                            color:<%= "PAGADO".equals(p.getEstado()) ? "#1e8449" : "#7b241c" %>;">
                            <%= p.getEstado() %>
                        </span>
                    </td>
                    <td>$<%= String.format("%.2f", p.getTotal()) %></td>
                    <td>
                        <a href="${pageContext.request.contextPath}/factura?id=<%= p.getId() %>"
                           class="btn btn-sm btn-secundario">Ver</a>
                    </td>
                </tr>
            <% } %>
            </tbody>
        </table>
        <% } else { %>
            <p style="margin-top:15px;color:#666;">Este cliente aún no tiene pedidos registrados.</p>
        <% } %>
    </div>
    <% } %>
</div>
</body>
</html>
