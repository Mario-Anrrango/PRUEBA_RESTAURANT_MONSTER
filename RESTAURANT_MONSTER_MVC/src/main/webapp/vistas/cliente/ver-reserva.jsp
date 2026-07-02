<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.*,java.util.*,java.time.*" %>
<%
    Pedido pedido = (Pedido) request.getAttribute("pedido");
    if (pedido == null) { response.sendRedirect(request.getContextPath() + "/reservas"); return; }
    boolean esModificable = "PENDIENTE".equals(pedido.getEstado())
        && Duration.between(pedido.getFecha().atTime(pedido.getHora()), LocalDateTime.now()).toHours() < 24;
    List<DetallePedido> detalles = pedido.getDetalles();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reserva #<%= pedido.getId() %> – Restaurant Master Monster</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/validaciones.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/print.css">
</head>
<body style="background:#f0e6d3;padding:20px;">
<div class="factura-container">
    <div class="factura-header">
        <h2>RESTAURANT MASTER MONSTER</h2>
        <p>RUC: 1712345678001 | Tel: (02) 555-0100</p>
        <div style="margin-top:10px;">
            <strong>RESERVA N° <%= pedido.getId() %></strong>
            &nbsp;|&nbsp; Fecha: <strong><%= pedido.getFecha() %></strong>
            &nbsp;|&nbsp; Hora: <strong><%= pedido.getHora() %></strong>
        </div>
    </div>
    <div class="factura-body">
        <div class="factura-datos">
            <div><span>Cliente:</span><br><%= pedido.getNombreCliente() %></div>
            <div><span>Cédula:</span><br><%= pedido.getCedulaCliente() %></div>
            <div><span>Estado:</span><br>
                <span style="font-weight:700;color:<%= "PAGADO".equals(pedido.getEstado()) ? "#27ae60" : "PENDIENTE".equals(pedido.getEstado()) ? "#e67e22" : "#c0392b" %>;">
                    <%= pedido.getEstado() %>
                </span>
            </div>
            <div><span>Modificable:</span><br><%= esModificable ? "Sí (antes de 24h)" : "No" %></div>
        </div>
        <h3 style="font-family:'Playfair Display',serif;color:#8b4513;">Detalle del Pedido</h3>
        <table class="tabla">
            <thead><tr><th>Plato</th><th>Categoría</th><th>Cant.</th><th>P. Unit.</th><th>Subtotal</th></tr></thead>
            <tbody>
            <% if (detalles != null) { for (DetallePedido d : detalles) { %>
                <tr>
                    <td><strong><%= d.getNombrePlato() %></strong></td>
                    <td><small><%= d.getCategoriaPlato() %></small></td>
                    <td style="text-align:center;"><%= d.getCantidad() %></td>
                    <td style="text-align:right;">$<%= String.format("%.2f", d.getPrecioUnitario().doubleValue()) %></td>
                    <td style="text-align:right;">$<%= String.format("%.2f", d.getSubtotalLinea().doubleValue()) %></td>
                </tr>
            <% } } %>
            </tbody>
        </table>
        <div class="factura-totales">
            <div class="linea-total"><span>Subtotal:</span><span>$<%= String.format("%.2f", pedido.getSubtotal().doubleValue()) %></span></div>
            <div class="linea-total"><span>IVA (15%):</span><span>$<%= String.format("%.2f", pedido.getIva().doubleValue()) %></span></div>
            <div class="linea-total"><span>Servicio (10%):</span><span>$<%= String.format("%.2f", pedido.getServicio().doubleValue()) %></span></div>
            <div class="linea-total gran-total"><span>TOTAL:</span><span>$<%= String.format("%.2f", pedido.getTotal().doubleValue()) %></span></div>
        </div>
    </div>
    <div class="factura-acciones no-print">
        <button onclick="window.print()" class="btn btn-secundario">🖨️ Imprimir</button>
        <% if (esModificable) { %>
            <a href="${pageContext.request.contextPath}/menu?modificar=<%= pedido.getId() %>" class="btn btn-exito">✏️ Modificar Pedido</a>
            <a href="#" class="btn btn-peligro" onclick="confirmarCancelar('<%= pedido.getId() %>'); return false;">✖ Cancelar Pedido</a>
        <% } %>
        <a href="${pageContext.request.contextPath}/reservas" class="btn btn-secundario">← Volver</a>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>var contextPath = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/js/confirmaciones.js"></script>
</body>
</html>
