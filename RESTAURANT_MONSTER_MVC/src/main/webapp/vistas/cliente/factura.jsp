<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.*,java.util.*" %>
<%
    Pedido pedido = (Pedido) request.getAttribute("pedido");
    if (pedido == null) {
        response.sendRedirect(request.getContextPath() + "/menu"); return;
    }
    List<DetallePedido> detalles = pedido.getDetalles();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Factura #<%= pedido.getId() %> – Restaurant Master Monster</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
    <style>
        @media print {
            .no-print { display: none !important; }
            body { background: white; }
        }
    </style>
</head>
<body style="background:#f0e6d3;padding:20px;">

<div class="factura-container">

    <!-- Encabezado -->
    <div class="factura-header">
        <div style="display:flex;align-items:center;justify-content:center;gap:20px;">
            <img src="${pageContext.request.contextPath}/img/LOGO_EMPRESA/Monster.jpg"
                 width="70" height="70" style="border-radius:50%;border:3px solid rgba(255,255,255,0.5);"
                 alt="Logo">
            <div>
                <h2>RESTAURANT MASTER MONSTER</h2>
                <p>RUC: 1712345678001 | Tel: (02) 555-0100</p>
                <p>Av. de los Shyris N45-12, Quito – Ecuador</p>
            </div>
        </div>
        <div style="margin-top:15px;background:rgba(255,255,255,0.15);border-radius:8px;padding:10px;">
            <strong>FACTURA N° <%= String.format("%06d", pedido.getId()) %></strong>
            &nbsp;&nbsp;|&nbsp;&nbsp;
            Fecha: <strong><%= pedido.getFecha() %></strong>
            &nbsp;&nbsp;|&nbsp;&nbsp;
            Hora: <strong><%= pedido.getHora() %></strong>
        </div>
    </div>

    <div class="factura-body">

        <!-- Datos del cliente -->
        <div class="factura-datos">
            <div><span>Cliente:</span><br><%= pedido.getNombreCliente() %></div>
            <div><span>Cédula:</span><br><%= pedido.getCedulaCliente() %></div>
            <div><span>Teléfono:</span><br><%= pedido.getTelefonoCliente() != null ? pedido.getTelefonoCliente() : "-" %></div>
            <div><span>Correo:</span><br><%= pedido.getCorreoCliente() != null ? pedido.getCorreoCliente() : "-" %></div>
        </div>

        <!-- Detalle de platos -->
        <h3 style="font-family:'Playfair Display',serif;color:#8b4513;margin-bottom:10px;">
            Detalle del Pedido
        </h3>
        <table class="tabla">
            <thead>
                <tr>
                    <th>Categoría</th>
                    <th>Plato</th>
                    <th style="text-align:center;">Cant.</th>
                    <th style="text-align:right;">P. Unit.</th>
                    <th style="text-align:right;">Subtotal</th>
                </tr>
            </thead>
            <tbody>
            <% if (detalles != null) { for (DetallePedido d : detalles) { %>
                <tr>
                    <td><small style="color:#888;"><%= d.getCategoriaPlato() %></small></td>
                    <td><strong><%= d.getNombrePlato() %></strong></td>
                    <td style="text-align:center;"><%= d.getCantidad() %></td>
                    <td style="text-align:right;">$<%= String.format("%.2f", d.getPrecioUnitario()) %></td>
                    <td style="text-align:right;font-weight:600;">$<%= String.format("%.2f", d.getSubtotalLinea()) %></td>
                </tr>
            <% } } %>
            </tbody>
        </table>

        <!-- Totales -->
        <div class="factura-totales">
            <div class="linea-total">
                <span>Subtotal:</span>
                <span>$<%= String.format("%.2f", pedido.getSubtotal()) %></span>
            </div>
            <div class="linea-total">
                <span>IVA (15%):</span>
                <span>$<%= String.format("%.2f", pedido.getIva()) %></span>
            </div>
            <div class="linea-total">
                <span>Servicio (10%):</span>
                <span>$<%= String.format("%.2f", pedido.getServicio()) %></span>
            </div>
            <div class="linea-total gran-total">
                <span>TOTAL A PAGAR:</span>
                <span>$<%= String.format("%.2f", pedido.getTotal()) %></span>
            </div>
        </div>

        <p style="text-align:center;color:#888;font-size:0.85em;margin-top:15px;">
            ¡Gracias por su preferencia! Vuelva pronto.
        </p>
    </div>

    <!-- Acciones -->
    <div class="factura-acciones no-print">
        <% if ("PENDIENTE".equals(pedido.getEstado())) { %>
        <form action="${pageContext.request.contextPath}/factura" method="post" style="display:inline;">
            <input type="hidden" name="idPedido" value="<%= pedido.getId() %>">
            <button type="submit" class="btn btn-exito"
                    onclick="return confirm('¿Confirmar el pago de $<%= String.format("%.2f", pedido.getTotal()) %>?')">
                💳 Pagar
            </button>
        </form>
        <% } else { %>
            <span style="color:#27ae60;font-weight:700;font-size:1.1em;">✔ PAGADO</span>
        <% } %>
        <button onclick="window.print()" class="btn btn-secundario">🖨️ Imprimir</button>
        <a href="${pageContext.request.contextPath}/menu" class="btn btn-secundario">← Volver al Menú</a>
    </div>
</div>

</body>
</html>
