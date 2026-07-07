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
    List<DetallePedido> detallesModificar = (List<DetallePedido>) request.getAttribute("detallesModificar");
    String modificandoId = (String) request.getAttribute("modificandoId");
    boolean modoModificacion = request.getAttribute("modoModificacion") != null;
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
    <style>
        .plato-card.seleccionado { border-color: #27ae60; background-color: #f0fff4; }
        /* FASE 6.27: Paginación y ordenamiento */
        .categoria-section { margin-bottom: 10px; }
        .controles-categoria { display: flex; align-items: center; gap: 10px; margin: 8px 0 15px; }
        .controles-categoria label { font-size: 0.85em; color: #666; }
        .controles-categoria select {
            padding: 6px 10px; border: 2px solid #d4a577; border-radius: 8px;
            background-color: white; cursor: pointer; font-size: 0.85em;
        }
        .paginacion-categoria {
            display: flex; justify-content: center; align-items: center; gap: 8px;
            margin-top: 15px; padding: 12px; background-color: #f8f9fa;
            border-radius: 8px; border: 1px solid #eee;
        }
        .btn-pagina {
            padding: 6px 14px; background-color: #8b4513; color: white;
            border: none; border-radius: 6px; cursor: pointer;
            transition: background-color 0.3s; font-size: 0.85em;
        }
        .btn-pagina:hover:not(:disabled) { background-color: #a0522d; }
        .btn-pagina:disabled { background-color: #ccc; cursor: not-allowed; }
        .pagina-info { font-weight: bold; color: #8b4513; font-size: 0.9em; }
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

<%-- SweetAlert si hay platos inactivos --%>
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

    <form action="${pageContext.request.contextPath}/pedido" method="post" id="formPedido" onsubmit="return confirmarPedido(event)">

        <% if (categorias != null) {
            for (Categoria cat : categorias) {
                List<Plato> platos = platosPorCategoria.get(cat.getId());
                if (platos == null || platos.isEmpty()) continue;
                String catId = cat.getId();
        %>
        <div class="categoria-section" data-categoria="<%= catId %>">
            <div class="titulo-categoria"><%= cat.getNombre() %></div>
            <div class="controles-categoria">
                <label>Ordenar:</label>
                <select onchange="ordenarCategoria('<%= catId %>', this.value)">
                    <option value="default">Predeterminado</option>
                    <option value="precio-asc">Precio: Menor a Mayor</option>
                    <option value="precio-desc">Precio: Mayor a Menor</option>
                    <option value="nombre-asc">Nombre: A-Z</option>
                    <option value="nombre-desc">Nombre: Z-A</option>
                </select>
            </div>
            <div class="menu-grid platos-grid" id="grid-<%= catId %>"
                 style="background:white;padding:20px;border-radius:0 0 12px 12px;
                 box-shadow:0 4px 12px rgba(0,0,0,0.08);margin-bottom:10px;">
            <% for (Plato p : platos) { 
                DetallePedido det = detalleMap.get(p.getId());
                boolean seleccionado = det != null;
                int cantidadInicial = seleccionado ? det.getCantidad() : 1;
                boolean activoEnBD = true;
                if (det != null) {
                    activoEnBD = det.isActivoEnBD();
                } else {
                    activoEnBD = p.isActivo();
                }
                java.math.BigDecimal precioMostrar = p.getPrecio();
                if (precioMostrar == null && det != null && det.getPrecioUnitario() != null) {
                    precioMostrar = det.getPrecioUnitario();
                }
                if (precioMostrar == null) precioMostrar = java.math.BigDecimal.ZERO;
                String claseCard = activoEnBD ? "plato-card" : "plato-card plato-inactivo";
                String claseImg = activoEnBD ? "" : "img-inactiva";
                String nombreAttr = p.getNombre().replace("\"", "&quot;");
            %>
            <div class="<%= claseCard %><%= modoModificacion && seleccionado ? " editando" : "" %>"
                 id="card_<%= p.getId() %>"
                 data-precio="<%= precioMostrar %>"
                 data-nombre="<%= nombreAttr %>">
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
                    <label style="display:flex;align-items:center;gap:8px;cursor:pointer;">
                        <input type="checkbox" class="checkbox-plato" name="platos"
                               value="<%= p.getId() %>" id="chk_<%= p.getId() %>"
                               <%= seleccionado ? "checked" : "" %>
                               data-precio="<%= precioMostrar %>"
                               onchange="toggleCantidad('<%= p.getId() %>', this.checked, <%= precioMostrar %>); actualizarEstadoBoton()">
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
            <% if (platos.size() > 8) { %>
            <div class="paginacion-categoria" id="pag-<%= catId %>">
                <button class="btn-pagina" onclick="cambiarPagina('<%= catId %>', 1)">≪ Inicio</button>
                <button class="btn-pagina" onclick="cambiarPagina('<%= catId %>', paginaActual['<%= catId %>'] - 1)">‹ Anterior</button>
                <span class="pagina-info">Pág <span id="pagina-actual-<%= catId %>">1</span> de <span id="total-paginas-<%= catId %>"><%= (platos.size() + 7) / 8 %></span></span>
                <button class="btn-pagina" onclick="cambiarPagina('<%= catId %>', paginaActual['<%= catId %>'] + 1)">Siguiente ›</button>
                <button class="btn-pagina" onclick="cambiarPagina('<%= catId %>', <%= (platos.size() + 7) / 8 %>)">Fin ≫</button>
            </div>
            <% } %>
        </div>
        <% } } %>

        <div class="barra-pedido">
            <div><span id="resumenPedido">No has seleccionado ningún plato</span></div>
            <div style="display:flex;align-items:center;gap:20px;">
                <span class="total-barra" id="totalBarra">$0.00</span>
                <a href="${pageContext.request.contextPath}/reservas" class="btn btn-secundario btn-sm">📋 Mis Reservas</a>
                <button type="submit" id="btnEnviar" class="btn btn-exito"
                        style="background:#27ae60;color:white;border-radius:25px;padding:10px 24px;">
                    <%= modoModificacion ? "Actualizar Pedido" : "Enviar Pedido" %>
                </button>
            </div>
        </div>
    </form>
</div>

<script src="${pageContext.request.contextPath}/js/validaciones.js"></script>
<script src="${pageContext.request.contextPath}/js/menu.js"></script>
<script>
// FASE 6.25: SweetAlert de confirmación antes de enviar pedido
function confirmarPedido(event) {
    event.preventDefault();
    
    var modoEdit = <%= modoModificacion %>;
    var activosSeleccionados = document.querySelectorAll('input[type="checkbox"]:checked:not([disabled])').length;
    var inactivosSeleccionados = document.querySelectorAll('.plato-inactivo input[type="checkbox"]:checked').length;
    var totalPlatos = activosSeleccionados + inactivosSeleccionados;
    
    if (totalPlatos === 0) {
        Swal.fire({
            icon: 'warning',
            title: 'Sin platos',
            text: 'Debe seleccionar al menos un plato',
            confirmButtonText: 'Entendido'
        });
        return false;
    }
    
    var titulo = modoEdit ? '¿Actualizar pedido?' : '¿Confirmar pedido?';
    var texto = modoEdit ? 'Se actualizarán los platos y cantidades del pedido' : 'Esta acción no se puede deshacer';
    
    Swal.fire({
        title: titulo,
        text: texto,
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#27ae60',
        cancelButtonColor: '#6c757d',
        confirmButtonText: modoEdit ? 'Sí, actualizar' : 'Sí, confirmar',
        cancelButtonText: 'Cancelar',
        allowOutsideClick: false
    }).then(function(result) {
        if (result.isConfirmed) {
            var btn = document.getElementById('btnEnviar');
            if (btn) { btn.disabled = true; btn.textContent = modoEdit ? 'Actualizando...' : 'Confirmando...'; }
            document.getElementById('formPedido').submit();
        }
    });
    
    return false;
}

// FASE 6.27: Deshabilitar/habilitar botón según platos seleccionados
function actualizarEstadoBoton() {
    var activos = document.querySelectorAll('input[type="checkbox"]:checked:not([disabled])').length;
    var inactivos = document.querySelectorAll('.plato-inactivo input[type="checkbox"]:checked').length;
    var total = activos + inactivos;
    var boton = document.getElementById('btnEnviar');
    if (total === 0) {
        boton.disabled = true;
        boton.style.opacity = '0.5';
        boton.style.cursor = 'not-allowed';
        boton.title = 'Seleccione al menos un plato';
    } else {
        boton.disabled = false;
        boton.style.opacity = '1';
        boton.style.cursor = 'pointer';
        boton.title = '';
    }
}

// FASE 6.27: Paginación del menú
var paginaActual = {};
var totalPaginas = {};
var platosPorCategoria = {};

function mostrarPagina(categoria, pagina) {
    var platos = platosPorCategoria[categoria];
    if (!platos) return;
    var inicio = (pagina - 1) * 8;
    var fin = inicio + 8;
    for (var i = 0; i < platos.length; i++) {
        platos[i].style.display = (i >= inicio && i < fin) ? '' : 'none';
    }
    paginaActual[categoria] = pagina;
    var pagLabel = document.getElementById('pagina-actual-' + categoria);
    if (pagLabel) pagLabel.textContent = pagina;
    actualizarBotonesPaginacion(categoria);
}

function cambiarPagina(categoria, pagina) {
    if (pagina < 1) pagina = 1;
    if (pagina > totalPaginas[categoria]) pagina = totalPaginas[categoria];
    mostrarPagina(categoria, pagina);
}

function actualizarBotonesPaginacion(categoria) {
    var pagDiv = document.getElementById('pag-' + categoria);
    if (!pagDiv) return;
    var botones = pagDiv.querySelectorAll('.btn-pagina');
    var actual = paginaActual[categoria] || 1;
    var total = totalPaginas[categoria] || 1;
    if (botones.length >= 4) {
        botones[0].disabled = (actual <= 1);
        botones[1].disabled = (actual <= 1);
        botones[2].disabled = (actual >= total);
        botones[3].disabled = (actual >= total);
    }
}

function ordenarCategoria(categoria, criterio) {
    var grid = document.getElementById('grid-' + categoria);
    if (!grid) return;
    var platos = Array.from(grid.querySelectorAll('.plato-card, .plato-inactivo'));
    if (criterio === 'default') {
        // Restaurar orden original
        platos.sort(function(a, b) { return a._index - b._index; });
    } else if (criterio === 'precio-asc') {
        platos.sort(function(a, b) {
            return parseFloat(a.getAttribute('data-precio')) - parseFloat(b.getAttribute('data-precio'));
        });
    } else if (criterio === 'precio-desc') {
        platos.sort(function(a, b) {
            return parseFloat(b.getAttribute('data-precio')) - parseFloat(a.getAttribute('data-precio'));
        });
    } else if (criterio === 'nombre-asc') {
        platos.sort(function(a, b) {
            return (a.getAttribute('data-nombre') || '').localeCompare(b.getAttribute('data-nombre') || '');
        });
    } else if (criterio === 'nombre-desc') {
        platos.sort(function(a, b) {
            return (b.getAttribute('data-nombre') || '').localeCompare(a.getAttribute('data-nombre') || '');
        });
    }
    platos.forEach(function(p) { grid.appendChild(p); });
    paginaActual[categoria] = 1;
    mostrarPagina(categoria, 1);
}

// Inicializar
document.addEventListener('DOMContentLoaded', function() {
    // Guardar índice original para restaurar orden
    document.querySelectorAll('.categoria-section').forEach(function(section) {
        var categoria = section.getAttribute('data-categoria');
        var grid = document.getElementById('grid-' + categoria);
        if (!grid) return;
        var cards = Array.from(grid.querySelectorAll('.plato-card, .plato-inactivo'));
        cards.forEach(function(card, idx) { card._index = idx; });
        platosPorCategoria[categoria] = cards;
        totalPaginas[categoria] = Math.ceil(cards.length / 8);
        paginaActual[categoria] = 1;
        if (cards.length > 8) {
            mostrarPagina(categoria, 1);
        }
    });

    // Inicializar seleccionados con items pre-marcados (modificación)
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
    // Agregar platos INACTIVOS
    document.querySelectorAll('.plato-inactivo').forEach(function(card) {
        var chk = card.querySelector('input[type="checkbox"]');
        if (chk && chk.checked) {
            var idPlato = chk.value;
            var precio = parseFloat(chk.getAttribute('data-precio')) || 0;
            var qty = parseInt(chk.getAttribute('data-cantidad')) || 1;
            seleccionados[idPlato] = { qty: qty, precio: precio };
        }
    });
    actualizarBarra();
    
    // Inactivos count
    var inactivosCount = document.querySelectorAll('.plato-inactivo input[type="checkbox"]:checked').length;
    if (inactivosCount > 0) {
        var resumenEl = document.getElementById('resumenPedido');
        if (resumenEl) {
            resumenEl.textContent = resumenEl.textContent + ' (incluye ' + inactivosCount + ' plato(s) no modificable(s))';
        }
    }
    
    // FASE 6.27: Estado inicial del botón
    actualizarEstadoBoton();
});
</script>
</body>
</html>