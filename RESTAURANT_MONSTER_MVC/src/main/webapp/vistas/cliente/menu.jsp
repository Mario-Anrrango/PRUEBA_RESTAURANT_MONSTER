<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.*,java.util.*" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"CLIENTE".equals(usuario.getPerfil())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    Cliente cliente = (Cliente) session.getAttribute("cliente");
    List<Categoria> categorias = (List<Categoria>) request.getAttribute("categorias");
    Map<String, List<Plato>> platosPorCategoria =
        (Map<String, List<Plato>>) request.getAttribute("platosPorCategoria");
    // PROBLEMA 2: Cargar detalles existentes para modificación
    List<DetallePedido> detallesModificar = (List<DetallePedido>) request.getAttribute("detallesModificar");
    String modificandoId = (String) request.getAttribute("modificandoId");
    // Mapa rápido: id_plato -> DetallePedido
    Map<String, DetallePedido> detalleMap = new java.util.HashMap<>();
    if (detallesModificar != null) {
        for (DetallePedido d : detallesModificar) {
            detalleMap.put(d.getIdPlato(), d);
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Menú – Restaurant Master Monster</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/validaciones.css">
</head>
<body>

<div class="encabezado">
    <h1>Restaurant Master Monster</h1>
    <img src="${pageContext.request.contextPath}/img/LOGO_EMPRESA/Monster.jpg" alt="Logo" class="logo-encabezado">
</div>
<nav class="navbar">
    <ul class="navbar-links">
        <li><a href="${pageContext.request.contextPath}/menu" class="activo">Menú</a></li>
        <li><a href="${pageContext.request.contextPath}/reservas">Mis Reservas</a></li>
        <li><a href="${pageContext.request.contextPath}/logout">Cerrar Sesión</a></li>
    </ul>
    <span class="navbar-user">
        <%= cliente != null ? cliente.getNombreCompleto() : usuario.getUsername() %>
    </span>
</nav>

<% if (request.getParameter("pagado") != null) { %>
    <div style="margin:15px 20px;">
        <div class="alerta alerta-exito">¡Pago registrado! Gracias por su preferencia.</div>
    </div>
<% } %>
<% if (request.getParameter("error") != null) { %>
    <div style="margin:15px 20px;">
        <div class="alerta alerta-error">
            <% if ("vacio".equals(request.getParameter("error"))) { %>
                Debe seleccionar al menos un plato antes de enviar el pedido.
            <% } else { %>
                Ocurrió un error al procesar el pedido. Intente nuevamente.
            <% } %>
        </div>
    </div>
<% } %>

<div style="padding:20px 30px;">
    <h2 style="font-family:'Playfair Display',serif;color:#8b4513;text-align:center;
               font-size:1.6em;margin-bottom:5px;">Nuestro Menú</h2>
    <p style="text-align:center;color:#888;margin-bottom:10px;">
        Selecciona los platos que deseas y ajusta la cantidad con los botones + y −
    </p>

    <form action="${pageContext.request.contextPath}/pedido" method="post" id="formPedido">

        <% if (categorias != null) {
            for (Categoria cat : categorias) {
                List<Plato> platos = platosPorCategoria.get(cat.getId());
                if (platos == null || platos.isEmpty()) continue;
        %>
        <div class="titulo-categoria"><%= cat.getNombre() %></div>
        <div class="menu-grid" style="background:white;padding:20px;border-radius:0 0 12px 12px;
             box-shadow:0 4px 12px rgba(0,0,0,0.08);margin-bottom:10px;">
            <% for (Plato p : platos) { 
                DetallePedido det = detalleMap.get(p.getId());
                boolean seleccionado = det != null;
                int cantidadInicial = seleccionado ? det.getCantidad() : 1;
            %>
            <div class="plato-card" id="card_<%= p.getId() %>">
                <img src="${pageContext.request.contextPath}/<%= p.getFoto() %>"
                     alt="<%= p.getNombre() %>"
                     onerror="this.src='${pageContext.request.contextPath}/img/LOGO_EMPRESA/Monster.jpg'">
                <div class="plato-card-body">
                    <h4><%= p.getNombre() %></h4>
                    <p><%= p.getDescripcion() %></p>
                    <span class="plato-precio">$<%= p.getPrecio() != null ? p.getPrecio().setScale(2, java.math.RoundingMode.HALF_UP) : "0.00" %></span>
                </div>
                <div class="plato-footer" id="footer_<%= p.getId() %>">
                    <label style="display:flex;align-items:center;gap:8px;cursor:pointer;">
                        <input type="checkbox" class="checkbox-plato" name="platos"
                               value="<%= p.getId() %>" id="chk_<%= p.getId() %>"
                               <%= seleccionado ? "checked" : "" %>
                               data-precio="<%= p.getPrecio() %>"
                               onchange="toggleCantidad('<%= p.getId() %>', this.checked, <%= p.getPrecio() %>)">
                        <span style="font-size:0.9em;color:#555;">Seleccionar</span>
                    </label>
                    <div class="contador-cantidad" id="contador_<%= p.getId() %>"
                         style="<%= seleccionado ? "display:flex;" : "" %>">
                        <button type="button" onclick="cambiarCantidad('<%= p.getId() %>', -1, <%= p.getPrecio() %>)">−</button>
                        <span class="cantidad-display" id="num_<%= p.getId() %>"><%= cantidadInicial %></span>
                        <button type="button" onclick="cambiarCantidad('<%= p.getId() %>', +1, <%= p.getPrecio() %>)">+</button>
                        <input type="hidden" name="cantidad_<%= p.getId() %>" id="qty_<%= p.getId() %>" value="<%= cantidadInicial %>">
                    </div>
                </div>
            </div>
            <% } %>
        </div>
        <% } } %>

        <div class="barra-pedido">
            <div><span id="resumenPedido">No has seleccionado ningún plato</span></div>
            <div style="display:flex;align-items:center;gap:20px;">
                <span class="total-barra" id="totalBarra">$0.00</span>
                <a href="${pageContext.request.contextPath}/reservas" class="btn btn-secundario btn-sm">📋 Mis Reservas</a>
                <button type="submit" id="btnEnviar" class="btn btn-exito" disabled
                        style="background:#27ae60;color:white;border-radius:25px;padding:10px 24px;">
                    Enviar Pedido
                </button>
            </div>
        </div>
    </form>
</div>

<script src="${pageContext.request.contextPath}/js/validaciones.js"></script>
<script src="${pageContext.request.contextPath}/js/menu.js"></script>
<script>
// Inicializar seleccionados con items pre-marcados (modificación)
document.addEventListener('DOMContentLoaded', function() {
    var checkboxes = document.querySelectorAll('.checkbox-plato:checked');
    checkboxes.forEach(function(chk) {
        var idPlato = chk.value;
        var precio = parseFloat(chk.getAttribute('data-precio')) || 0;
        var numEl = document.getElementById('num_' + idPlato);
        var qty = numEl ? parseInt(numEl.textContent) : 1;
        var contador = document.getElementById('contador_' + idPlato);
        var card = document.getElementById('card_' + idPlato);
        if (contador) contador.style.display = 'flex';
        if (card) card.classList.add('seleccionado');
        seleccionados[idPlato] = { qty: qty, precio: precio };
    });
    actualizarBarra();
});
</script>
</body>
</html>
