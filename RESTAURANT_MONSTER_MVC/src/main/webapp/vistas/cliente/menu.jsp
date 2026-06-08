<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.*,java.util.*" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"CLIENTE".equals(usuario.getPerfil())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    Cliente cliente = (Cliente) session.getAttribute("cliente");
    List<Categoria> categorias = (List<Categoria>) request.getAttribute("categorias");
    Map<Integer, List<Plato>> platosPorCategoria =
        (Map<Integer, List<Plato>>) request.getAttribute("platosPorCategoria");
    Pedido pedidoPendiente = (Pedido) request.getAttribute("pedidoPendiente");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Menú – Restaurant Master Monster</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
    <style>
        body { padding-bottom: 90px; }
        .plato-card.seleccionado { border: 2px solid #8b4513; }
        .cantidad-hidden { display: none; }
        .plato-footer .contador-cantidad { display: none; }
        .plato-footer.activo .contador-cantidad { display: flex; }
    </style>
</head>
<body>

<div class="encabezado">
    <h1>Restaurant Master Monster</h1>
    <img src="${pageContext.request.contextPath}/img/LOGO_EMPRESA/Monster.jpg" alt="Logo" class="logo-encabezado">
</div>
<nav class="navbar">
    <ul class="navbar-links">
        <li><a href="${pageContext.request.contextPath}/menu" class="activo">Menú</a></li>
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

        <% if (pedidoPendiente != null) { %>
        <input type="hidden" id="campoPedidoPendiente" name="idPedidoPendiente" value="<%= pedidoPendiente.getId() %>">
        <div style="background:#eaf4fb;border:1px solid #aed6f1;border-radius:10px;padding:18px 20px;margin-bottom:20px;">
            <div style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;">
                <div>
                    <span style="font-size:1.1em;font-weight:bold;color:#1a5276;">
                        Pedido pendiente #<%= pedidoPendiente.getId() %>
                    </span>
                    <span style="color:#555;margin-left:10px;">
                        Subtotal actual: <strong>$<%= String.format("%.2f", pedidoPendiente.getSubtotal()) %></strong>
                        &nbsp;·&nbsp; Total c/imp: <strong>$<%= String.format("%.2f", pedidoPendiente.getTotal()) %></strong>
                    </span>
                </div>
                <a href="${pageContext.request.contextPath}/factura?id=<%= pedidoPendiente.getId() %>"
                   class="btn btn-primario" style="background:#27ae60;border-radius:20px;padding:8px 20px;">
                    Pagar ahora
                </a>
            </div>
            <div style="margin-top:14px;display:flex;gap:24px;">
                <label style="cursor:pointer;display:flex;align-items:center;gap:6px;">
                    <input type="radio" name="modoPedido" value="agregar" checked
                           onchange="toggleModoPedido(this.value)">
                    <span style="color:#1a5276;font-weight:600;">Añadir platos a este pedido</span>
                </label>
                <label style="cursor:pointer;display:flex;align-items:center;gap:6px;">
                    <input type="radio" name="modoPedido" value="nuevo"
                           onchange="toggleModoPedido(this.value)">
                    <span style="color:#7d3c00;font-weight:600;">Iniciar un pedido nuevo</span>
                </label>
            </div>
        </div>
        <% } %>

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
                <img src="${pageContext.request.contextPath}/<%= p.getFoto() %>"
                     alt="<%= p.getNombre() %>"
                     onerror="this.src='${pageContext.request.contextPath}/img/LOGO_EMPRESA/Monster.jpg'">
                <div class="plato-card-body">
                    <h4><%= p.getNombre() %></h4>
                    <p><%= p.getDescripcion() %></p>
                    <span class="plato-precio">$<%= String.format("%.2f", p.getPrecio()) %></span>
                </div>
                <div class="plato-footer" id="footer_<%= p.getId() %>">
                    <label style="display:flex;align-items:center;gap:8px;cursor:pointer;">
                        <input type="checkbox"
                               class="checkbox-plato"
                               name="platos"
                               value="<%= p.getId() %>"
                               id="chk_<%= p.getId() %>"
                               onchange="toggleCantidad(<%= p.getId() %>, this.checked, <%= p.getPrecio() %>)">
                        <span style="font-size:0.9em;color:#555;">Seleccionar</span>
                    </label>
                    <div class="contador-cantidad" id="contador_<%= p.getId() %>">
                        <button type="button"
                                onclick="cambiarCantidad(<%= p.getId() %>, -1, <%= p.getPrecio() %>)">−</button>
                        <span class="cantidad-display" id="num_<%= p.getId() %>">1</span>
                        <button type="button"
                                onclick="cambiarCantidad(<%= p.getId() %>, +1, <%= p.getPrecio() %>)">+</button>
                        <input type="hidden"
                               name="cantidad_<%= p.getId() %>"
                               id="qty_<%= p.getId() %>"
                               value="1">
                    </div>
                </div>
            </div>
            <% } %>
        </div>
        <% } } %>

        <!-- Barra flotante de pedido -->
        <div class="barra-pedido">
            <div>
                <span id="resumenPedido">No has seleccionado ningún plato</span>
            </div>
            <div style="display:flex;align-items:center;gap:20px;">
                <span class="total-barra" id="totalBarra">$0.00</span>
                <a href="${pageContext.request.contextPath}/login" class="btn btn-secundario btn-sm">← Inicio</a>
                <button type="submit" id="btnEnviar" class="btn btn-exito" disabled
                        style="background:#27ae60;color:white;border-radius:25px;padding:10px 24px;">
                    Enviar Pedido
                </button>
            </div>
        </div>

    </form>
</div>

<script>
    const seleccionados = {};

    function toggleModoPedido(valor) {
        const campo = document.getElementById('campoPedidoPendiente');
        if (!campo) return;
        if (valor === 'nuevo') {
            campo.disabled = true;
            campo.value = '';
        } else {
            campo.disabled = false;
            campo.value = campo.dataset.id;
        }
    }

    // Guardar el id original en data-id para poder restaurarlo
    window.addEventListener('DOMContentLoaded', function() {
        const campo = document.getElementById('campoPedidoPendiente');
        if (campo) campo.dataset.id = campo.value;
    });

    function toggleCantidad(idPlato, checked, precio) {
        const footer   = document.getElementById('footer_' + idPlato);
        const contador = document.getElementById('contador_' + idPlato);
        const card     = document.getElementById('card_' + idPlato);

        if (checked) {
            contador.style.display = 'flex';
            card.classList.add('seleccionado');
            seleccionados[idPlato] = {
                qty: parseInt(document.getElementById('num_' + idPlato).textContent),
                precio: precio
            };
        } else {
            contador.style.display = 'none';
            card.classList.remove('seleccionado');
            delete seleccionados[idPlato];
        }
        actualizarBarra();
    }

    function cambiarCantidad(idPlato, delta, precio) {
        const numEl = document.getElementById('num_' + idPlato);
        const qtyEl = document.getElementById('qty_' + idPlato);
        let val = parseInt(numEl.textContent) + delta;
        if (val < 1) val = 1;
        numEl.textContent = val;
        qtyEl.value = val;
        if (seleccionados[idPlato]) {
            seleccionados[idPlato].qty = val;
        }
        actualizarBarra();
    }

    function actualizarBarra() {
        const ids  = Object.keys(seleccionados);
        const btn  = document.getElementById('btnEnviar');
        const res  = document.getElementById('resumenPedido');
        const tot  = document.getElementById('totalBarra');

        if (ids.length === 0) {
            res.textContent = 'No has seleccionado ningún plato';
            tot.textContent = '$0.00';
            btn.disabled = true;
            return;
        }

        let total = 0, items = 0;
        ids.forEach(id => {
            total += seleccionados[id].qty * seleccionados[id].precio;
            items += seleccionados[id].qty;
        });

        res.textContent = ids.length + ' plato(s) – ' + items + ' unidad(es)';
        tot.textContent = '$' + total.toFixed(2) + ' (sin impuestos)';
        btn.disabled = false;
    }
</script>
</body>
</html>
