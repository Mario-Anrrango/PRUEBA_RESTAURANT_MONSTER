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
    // PROBLEMA 2 + FASE 6.6: Cargar detalles existentes para modificación
    List<DetallePedido> detallesModificar = (List<DetallePedido>) request.getAttribute("detallesModificar");
    String modificandoId = (String) request.getAttribute("modificandoId");
    boolean modoModificacion = request.getAttribute("modoModificacion") != null;
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
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
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

<%-- FASE 6.6: SweetAlert si hay platos inactivos --%>
<%
Boolean hayInactivos = (Boolean) session.getAttribute("hayPlatosInactivos");
if (hayInactivos != null && hayInactivos) {
    session.removeAttribute("hayPlatosInactivos");
%>
<script>
function cancelarPedido(pedidoId) {
    var url = '${pageContext.request.contextPath}/reservas?accion=cancelar&id=' + pedidoId;
    fetch(url, { method: 'GET' })
        .then(function(response) {
            if (response.ok || response.redirected) {
                Swal.fire({
                    icon: 'success',
                    title: 'Pedido cancelado',
                    text: 'El pedido ha sido cancelado correctamente',
                    timer: 2000,
                    showConfirmButton: false
                }).then(function() {
                    window.location.href = '${pageContext.request.contextPath}/reservas';
                });
            } else {
                Swal.fire({
                    icon: 'error',
                    title: 'Error',
                    text: 'No se pudo cancelar el pedido'
                });
            }
        })
        .catch(function(error) {
            console.error('Error:', error);
            Swal.fire({
                icon: 'error',
                title: 'Error',
                text: 'Ocurrió un error al cancelar el pedido'
            });
        });
}

document.addEventListener('DOMContentLoaded', function() {
    Swal.fire({
        icon: 'warning',
        title: 'Productos no disponibles',
        html: 'Algunos productos de su pedido ya no están disponibles o no son modificables.<br><br>' +
              'Puede:<br>' +
              '&bull; Mantener su pedido actual (los productos se conservarán)<br>' +
              '&bull; Modificar solo los productos disponibles<br>' +
              '&bull; Cancelar el pedido completo',
        showCancelButton: true,
        confirmButtonColor: '#28a745',
        cancelButtonColor: '#dc3545',
        confirmButtonText: 'Continuar modificando',
        cancelButtonText: 'Cancelar pedido'
    }).then((result) => {
        if (result.isConfirmed) {
            console.log('Usuario continúa con modificación');
        } else if (result.dismiss === Swal.DismissReason.cancel) {
            cancelarPedido('${pedidoModificando.id}');
        }
    });
});
</script>
<%
}
%>

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
                // FASE 6.6: Verificar si el plato está activo en BD
                boolean activoEnBD = true;
                if (det != null) {
                    activoEnBD = det.isActivoEnBD();
                } else {
                    activoEnBD = p.isActivo();
                }
                // Precio mostrado: si el plato tiene precio null, usar el del detalle
                java.math.BigDecimal precioMostrar = p.getPrecio();
                if (precioMostrar == null && det != null && det.getPrecioUnitario() != null) {
                    precioMostrar = det.getPrecioUnitario();
                }
                if (precioMostrar == null) precioMostrar = java.math.BigDecimal.ZERO;
                String claseCard = activoEnBD ? "plato-card" : "plato-card plato-inactivo";
                String claseImg = activoEnBD ? "" : "img-inactiva";
            %>
            <div class="<%= claseCard %>" id="card_<%= p.getId() %>">
                <img src="${pageContext.request.contextPath}/images/<%= p.getFoto() %>"
                     alt="<%= p.getNombre() %>"
                     class="<%= claseImg %>"
                     onerror="this.src='${pageContext.request.contextPath}/img/LOGO_EMPRESA/Monster.jpg'">
                <div class="plato-card-body">
                    <h4><%= p.getNombre() %></h4>
                    <p><%= p.getDescripcion() %></p>
                    <span class="plato-precio">$<%= precioMostrar.setScale(2, java.math.RoundingMode.HALF_UP) %></span>
                </div>
                <div class="plato-footer" id="footer_<%= p.getId() %>">
                <% if (activoEnBD) { %>
                    <!-- PLATO ACTIVO: checkbox habilitado -->
                    <label style="display:flex;align-items:center;gap:8px;cursor:pointer;">
                        <input type="checkbox" class="checkbox-plato" name="platos"
                               value="<%= p.getId() %>" id="chk_<%= p.getId() %>"
                               <%= seleccionado ? "checked" : "" %>
                               data-precio="<%= precioMostrar %>"
                               onchange="toggleCantidad('<%= p.getId() %>', this.checked, <%= precioMostrar %>)">
                        <span style="font-size:0.9em;color:#555;">Seleccionar</span>
                    </label>
                    <div class="contador-cantidad" id="contador_<%= p.getId() %>"
                         style="<%= seleccionado ? "display:flex;" : "" %>">
                        <button type="button" onclick="cambiarCantidad('<%= p.getId() %>', -1, <%= precioMostrar %>)">−</button>
                        <span class="cantidad-display" id="num_<%= p.getId() %>"><%= cantidadInicial %></span>
                        <button type="button" onclick="cambiarCantidad('<%= p.getId() %>', +1, <%= precioMostrar %>)">+</button>
                        <input type="hidden" name="cantidad_<%= p.getId() %>" id="qty_<%= p.getId() %>" value="<%= cantidadInicial %>">
                    </div>
                <% } else { %>
                    <!-- FASE 6.6: PLATO INACTIVO - checkbox deshabilitado, se conserva en pedido -->
                    <!-- NOTA: SIN class="checkbox-plato" para que DOMContentLoaded init no lo procese con precio=0 -->
                    <input type="checkbox"
                           value="<%= p.getId() %>" id="chk_<%= p.getId() %>"
                           disabled <%= seleccionado ? "checked" : "" %>
                           data-precio="<%= precioMostrar %>"
                           data-cantidad="<%= cantidadInicial %>">
                    <label class="label-inactivo">
                        <span class="badge-no-disponible">No disponible</span>
                    </label>
                    <div class="cantidad-inactiva" id="contador_<%= p.getId() %>">
                        Cantidad: <strong><%= cantidadInicial %></strong><br>
                        <small>Subtotal: $<%= precioMostrar.multiply(new java.math.BigDecimal(cantidadInicial)).setScale(2, java.math.RoundingMode.HALF_UP) %></small>
                        <input type="hidden" name="platos_inactivos" value="<%= p.getId() %>">
                        <input type="hidden" name="cantidad_inactiva_<%= p.getId() %>" value="<%= cantidadInicial %>">
                    </div>
                <% } %>
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
    // FASE 6.6: Agregar platos INACTIVOS (NO tienen class="checkbox-plato")
    document.querySelectorAll('.plato-inactivo').forEach(function(card) {
        var chk = card.querySelector('input[type="checkbox"]');
        if (chk && chk.checked) {
            var idPlato = chk.value;
            var precio = parseFloat(chk.getAttribute('data-precio')) || 0;
            var qty = parseInt(chk.getAttribute('data-cantidad')) || 1;
            // Siempre agregar (inactivos nunca están en seleccionados del primer loop)
            seleccionados[idPlato] = { qty: qty, precio: precio };
        }
    });
    actualizarBarra();
    
    // Si hay platos inactivos, actualizar el texto del footer
    var inactivosCount = document.querySelectorAll('.plato-inactivo input[type="checkbox"]:checked').length;
    if (inactivosCount > 0) {
        var resumenEl = document.getElementById('resumenPedido');
        if (resumenEl) {
            resumenEl.textContent = resumenEl.textContent + ' (incluye ' + inactivosCount + ' plato(s) no modificable(s))';
        }
    }
    
    // Debug log
    console.log('=== DEBUG Total ===');
    console.log('Total calculado por actualizarBarra:', document.getElementById('totalBarra').textContent);
    console.log('Platos en seleccionados:', Object.keys(seleccionados).length);
    var totalCalc = 0;
    Object.keys(seleccionados).forEach(function(id) {
        totalCalc += seleccionados[id].qty * seleccionados[id].precio;
        console.log('  - Plato ' + id + ': ' + seleccionados[id].qty + ' x ' + seleccionados[id].precio.toFixed(2));
    });
    console.log('Total verificado:', totalCalc.toFixed(2));
});
</script>
</body>
</html>
