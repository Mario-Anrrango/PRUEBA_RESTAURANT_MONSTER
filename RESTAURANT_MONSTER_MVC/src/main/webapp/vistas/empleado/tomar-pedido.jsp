<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.*,java.util.*" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"EMPLEADO".equals(usuario.getPerfil())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    Cliente clienteSeleccionado = (Cliente) request.getAttribute("clienteSeleccionado");
    List<Categoria> categorias  = (List<Categoria>) request.getAttribute("categorias");
    Map<String, List<Plato>> platosPorCategoria =
        (Map<String, List<Plato>>) request.getAttribute("platosPorCategoria");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tomar Pedido – Empleado</title>
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
        <li><a href="${pageContext.request.contextPath}/empleado?accion=buscarCliente" class="activo">Buscar Cliente</a></li>
        <li><a href="${pageContext.request.contextPath}/logout">Cerrar Sesión</a></li>
    </ul>
    <span class="navbar-user">Mesero: <%= usuario.getUsername() %></span>
</nav>

<div style="padding:20px 30px;">
    <!-- Info del cliente -->
    <div class="alerta alerta-info" style="margin-bottom:20px;">
        Tomando pedido para: <strong><%= clienteSeleccionado.getNombreCompleto() %></strong>
        | Cédula: <strong><%= clienteSeleccionado.getCedula() %></strong>
    </div>

    <% if (request.getParameter("error") != null) { %>
        <div class="alerta alerta-error">Debe seleccionar al menos un plato.</div>
    <% } %>

    <form action="${pageContext.request.contextPath}/empleado/tomar-pedido" method="post" id="formPedido">
        <input type="hidden" name="idCliente" value="<%= clienteSeleccionado.getId() %>">

        <% if (categorias != null) {
            for (Categoria cat : categorias) {
                List<Plato> platos = platosPorCategoria.get(cat.getId());
                if (platos == null || platos.isEmpty()) continue;
        %>
        <div class="titulo-categoria"><%= cat.getNombre() %></div>
        <div class="menu-grid" style="background:white;padding:20px;border-radius:0 0 12px 12px;
             box-shadow:0 4px 12px rgba(0,0,0,0.08);margin-bottom:10px;">
            <% for (Plato p : platos) { %>
            <div class="plato-card" id="card_<%= p.getId() %>">
                <img src="${pageContext.request.contextPath}/images/<%= p.getFoto() %>"
                     alt="<%= p.getNombre() %>"
                     onerror="this.src='${pageContext.request.contextPath}/img/LOGO_EMPRESA/Monster.jpg'">
                <div class="plato-card-body">
                    <h4><%= p.getNombre() %></h4>
                    <p><%= p.getDescripcion() %></p>
                    <span class="plato-precio">$<%= p.getPrecio() != null ? String.format("%.2f", p.getPrecio().doubleValue()) : "0.00" %></span>
                </div>
                <div class="plato-footer" id="footer_<%= p.getId() %>">
                    <label style="display:flex;align-items:center;gap:8px;cursor:pointer;">
                        <input type="checkbox" class="checkbox-plato"
                               name="platos" value="<%= p.getId() %>" id="chk_<%= p.getId() %>"
                               onchange="toggleCantidad('<%= p.getId() %>', this.checked, <%= p.getPrecio() %>)">
                        <span style="font-size:0.9em;color:#555;">Seleccionar</span>
                    </label>
                    <div class="contador-cantidad" id="contador_<%= p.getId() %>" style="display:none;">
                        <button type="button" onclick="cambiarCantidad('<%= p.getId() %>', -1, <%= p.getPrecio() %>)">−</button>
                        <span class="cantidad-display" id="num_<%= p.getId() %>">1</span>
                        <button type="button" onclick="cambiarCantidad('<%= p.getId() %>', +1, <%= p.getPrecio() %>)">+</button>
                        <input type="hidden" name="cantidad_<%= p.getId() %>" id="qty_<%= p.getId() %>" value="1">
                    </div>
                </div>
            </div>
            <% } %>
        </div>
        <% } } %>

        <div class="barra-pedido">
            <div>
                <span id="resumenPedido">No has seleccionado ningún plato</span>
            </div>
            <div style="display:flex;align-items:center;gap:15px;">
                <span class="total-barra" id="totalBarra">$0.00</span>
                <a href="${pageContext.request.contextPath}/empleado?accion=buscarCliente"
                   class="btn btn-secundario btn-sm">← Atrás</a>
                <button type="submit" id="btnEnviar" class="btn btn-exito" disabled
                        style="background:#27ae60;color:white;border-radius:25px;padding:10px 24px;">
                    Confirmar Pedido
                </button>
            </div>
        </div>
    </form>
</div>

<script src="${pageContext.request.contextPath}/js/menu.js"></script>
</body>
</html>
