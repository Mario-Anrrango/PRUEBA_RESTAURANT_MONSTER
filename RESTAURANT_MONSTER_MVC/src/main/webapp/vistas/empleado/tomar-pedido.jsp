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
    
    // FASE 6.19: Editar pedido
    String modificarId = (String) request.getAttribute("modificarId");
    boolean modoEdicion = request.getAttribute("modoEdicion") != null && (Boolean) request.getAttribute("modoEdicion");
    List<DetallePedido> detallesPedido = (List<DetallePedido>) request.getAttribute("detallesPedido");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= modoEdicion ? "Editar Pedido" : "Tomar Pedido" %> – Empleado</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/validaciones.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        .encabezado-edicion { background:#fef9e7; border:1px solid #f1c40f; border-radius:12px; padding:15px 20px; margin-bottom:20px; }
        .encabezado-edicion h3 { color:#7d6608; margin:0 0 5px 0; font-family:'Playfair Display',serif; }
        .encabezado-edicion p { margin:0; color:#856404; font-size:0.9em; }
        .plato-card.seleccionado { border-color: #27ae60; background-color: #f0fff4; }
    </style>
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
        <%= modoEdicion ? "✏️ Editando pedido para" : "Tomando pedido para" %>:
        <strong><%= clienteSeleccionado.getNombreCompleto() %></strong>
        | Cédula: <strong><%= clienteSeleccionado.getCedula() != null ? clienteSeleccionado.getCedula() : clienteSeleccionado.getIdentificacionExtranjera() %></strong>
    </div>

    <% if (modoEdicion) { %>
    <div class="encabezado-edicion">
        <h3>✏️ Modo Edición — Pedido #<%= modificarId.length() > 8 ? modificarId.substring(0, 8) : modificarId %></h3>
        <p>Los checkboxes ya están marcados con los platos del pedido actual. Modifica las cantidades y/o agrega/quita platos, luego confirma.</p>
    </div>
    <% } %>

    <% if (request.getParameter("error") != null) { %>
        <div class="alerta alerta-error">Debe seleccionar al menos un plato.</div>
    <% } %>

    <form action="${pageContext.request.contextPath}/empleado/tomar-pedido" method="post" id="formPedido" onsubmit="return confirmarPedido(event)">
        <input type="hidden" name="idCliente" value="<%= clienteSeleccionado.getId() %>">

        <% if (categorias != null) {
            for (Categoria cat : categorias) {
                List<Plato> platos = platosPorCategoria.get(cat.getId());
                if (platos == null || platos.isEmpty()) continue;
        %>
        <div class="titulo-categoria"><%= cat.getNombre() %></div>
        <div class="menu-grid" style="background:white;padding:20px;border-radius:0 0 12px 12px;
             box-shadow:0 4px 12px rgba(0,0,0,0.08);margin-bottom:10px;">
            <% for (Plato p : platos) {
                // FASE 6.19: Verificar si este plato está en el pedido existente
                boolean seleccionado = false;
                int cantidad = 1;
                boolean activoEnBD = true;
                if (modoEdicion && detallesPedido != null) {
                    for (DetallePedido det : detallesPedido) {
                        if (det.getIdPlato() != null && det.getIdPlato().equals(p.getId())) {
                            seleccionado = true;
                            cantidad = det.getCantidad();
                            activoEnBD = det.isActivoEnBD();
                            break;
                        }
                    }
                }
                String claseCard = activoEnBD ? "plato-card" : "plato-card plato-inactivo";
                String claseImg = activoEnBD ? "" : "img-inactiva";
                boolean platoInactivo = !activoEnBD;
            %>
            <div class="<%= claseCard %> <%= modoEdicion && seleccionado && activoEnBD ? "editando" : "" %> <%= seleccionado && activoEnBD ? "seleccionado" : "" %>" id="card_<%= p.getId() %>">
                <img src="${pageContext.request.contextPath}/images/<%= p.getFoto() %>"
                     alt="<%= p.getNombre() %>"
                     class="<%= claseImg %>"
                     onerror="this.src='${pageContext.request.contextPath}/img/LOGO_EMPRESA/Monster.jpg'">
                <div class="plato-card-body">
                    <h4><%= p.getNombre() %></h4>
                    <p><%= p.getDescripcion() %></p>
                    <span class="plato-precio">$<%= p.getPrecio() != null ? String.format("%.2f", p.getPrecio().doubleValue()) : "0.00" %></span>
                </div>
                <div class="plato-footer" id="footer_<%= p.getId() %>">
                <% if (!platoInactivo) { %>
                    <label style="display:flex;align-items:center;gap:8px;cursor:pointer;">
                        <input type="checkbox" class="checkbox-plato"
                               name="platos" value="<%= p.getId() %>" id="chk_<%= p.getId() %>"
                               <%= seleccionado ? "checked" : "" %>
                               onchange="toggleCantidad('<%= p.getId() %>', this.checked, <%= p.getPrecio() != null ? p.getPrecio().doubleValue() : 0 %>); actualizarEstadoBoton()">
                        <span style="font-size:0.9em;color:#555;">Seleccionar</span>
                    </label>
                    <div class="contador-cantidad" id="contador_<%= p.getId() %>"
                         style="display:<%= seleccionado ? "flex" : "none" %>;">
                        <button type="button" onclick="cambiarCantidad('<%= p.getId() %>', -1, <%= p.getPrecio() != null ? p.getPrecio().doubleValue() : 0 %>)">−</button>
                        <span class="cantidad-display" id="num_<%= p.getId() %>"><%= cantidad %></span>
                        <button type="button" onclick="cambiarCantidad('<%= p.getId() %>', +1, <%= p.getPrecio() != null ? p.getPrecio().doubleValue() : 0 %>)">+</button>
                        <input type="hidden" name="cantidad_<%= p.getId() %>" id="qty_<%= p.getId() %>" value="<%= cantidad %>">
                    </div>
                <% } else { %>
                    <!-- FASE 6.21: PLATO INACTIVO - solo info, sin checkbox -->
                    <input type="checkbox"
                           value="<%= p.getId() %>" id="chk_<%= p.getId() %>"
                           disabled <%= seleccionado ? "checked" : "" %>
                           data-precio="<%= p.getPrecio() != null ? p.getPrecio().doubleValue() : 0 %>"
                           data-cantidad="<%= cantidad %>">
                    <label class="label-inactivo">
                        <span class="badge-no-disponible">No disponible</span>
                    </label>
                    <div class="cantidad-inactiva" id="contador_<%= p.getId() %>">
                        Cantidad: <strong><%= cantidad %></strong><br>
                        <small>Subtotal: $<%= String.format("%.2f", (p.getPrecio() != null ? p.getPrecio().multiply(new java.math.BigDecimal(cantidad)) : java.math.BigDecimal.ZERO).doubleValue()) %></small>
                        <input type="hidden" name="platos_inactivos" value="<%= p.getId() %>">
                        <input type="hidden" name="cantidad_<%= p.getId() %>" value="<%= cantidad %>">
                    </div>
                <% } %>
                </div>
            </div>
            <% } %>
        </div>
        <% } } %>

        <%-- FASE 6.23: Platos inactivos se renderizan visualmente en el grid --%>
        <%
        // FASE 6.21: SweetAlert si hay platos inactivos
        Boolean hayInactivos = (Boolean) request.getAttribute("hayPlatosInactivos");
        if (hayInactivos != null && hayInactivos && modificarId != null) { %>
        <script>
            Swal.fire({
                icon: 'warning',
                title: 'Productos no disponibles',
                html: 'Algunos productos de su pedido ya no están disponibles o no son modificables.<br><br>' +
                      'Puede:<br>' +
                      '• Mantener su pedido actual (los productos se conservarán)<br>' +
                      '• Modificar solo los productos disponibles<br>' +
                      '• Cancelar el pedido completo',
                showCancelButton: true,
                confirmButtonColor: '#27ae60',
                cancelButtonColor: '#dc3545',
                confirmButtonText: 'Continuar modificando',
                cancelButtonText: 'Cancelar pedido'
            }).then(function(result) {
                if (result.dismiss === Swal.DismissReason.cancel) {
                    window.location.href = contextPath + '/empleado?accion=cancelarPedido&id=<%= modificarId %>';
                }
            });
        </script>
        <% } %>

        <div class="barra-pedido">
            <div>
                <span id="resumenPedido">
                    <% if (modoEdicion && detallesPedido != null) {
                        int totalPlatos = 0;
                        int totalUnidades = 0;
                        for (DetallePedido det : detallesPedido) {
                            totalPlatos++;
                            totalUnidades += det.getCantidad();
                        }
                        out.print(totalPlatos + " plato(s) – " + totalUnidades + " unidad(es)");
                    } else {
                        out.print("No has seleccionado ningún plato");
                    } %>
                </span>
            </div>
            <div style="display:flex;align-items:center;gap:15px;">
                <span class="total-barra" id="totalBarra">$0.00</span>
                <button type="button" class="btn btn-secundario btn-sm" onclick="volverABuscar()">← Volver al cliente</button>
                <button type="submit" id="btnEnviar" class="btn btn-exito"
                        style="background:#27ae60;color:white;border-radius:25px;padding:10px 24px;"
                        title="Seleccione al menos un plato">
                    <%= modoEdicion ? "Actualizar Pedido" : "Confirmar Pedido" %>
                </button>
            </div>
        </div>
    </form>
</div>

<script>
    var contextPath = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/js/menu.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        // FASE 6.19: Inicializar seleccionados y total en modo edición
        <% if (modoEdicion && detallesPedido != null) { %>
        console.log("=== MODO EDICIÓN INICIALIZADO ===");
        // menu.js usa el objeto global 'seleccionados'
        <% for (DetallePedido det : detallesPedido) {
            if (det.isActivoEnBD()) { %>
                seleccionados['<%= det.getIdPlato() %>'] = {
                    qty: <%= det.getCantidad() %>,
                    precio: <%= det.getPrecioUnitario() != null ? det.getPrecioUnitario().doubleValue() : 0 %>
                };
        <%  }
        } %>
        // FASE 6.23: Agregar platos INACTIVOS al total
        <% for (DetallePedido det : detallesPedido) {
            if (!det.isActivoEnBD()) { %>
                seleccionados['<%= det.getIdPlato() %>'] = {
                    qty: <%= det.getCantidad() %>,
                    precio: <%= det.getPrecioUnitario() != null ? det.getPrecioUnitario().doubleValue() : 0 %>
                };
        <%  }
        } %>
        console.log("Platos precargados:", Object.keys(seleccionados).length);
        actualizarBarra();
        <% } %>
        actualizarEstadoBoton();
    });
    
    // FASE 6.20: SweetAlert de confirmación antes de enviar pedido
    function confirmarPedido(event) {
        event.preventDefault();
        
        // FASE 6.25: Validar al menos 1 plato seleccionado
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
        
        var modoEdit = <%= modoEdicion %>;
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
    
    // FASE 6.20: Volver al cliente con SweetAlert de confirmación
    function volverABuscar() {
        var idCliente = '<%= clienteSeleccionado != null ? clienteSeleccionado.getId() : "" %>';
        var modoEdit = <%= modoEdicion %>;
        var texto = modoEdit ? 'Los cambios realizados no se guardarán' : 'Volverá a la búsqueda de clientes';
        
        Swal.fire({
            title: '¿Salir sin guardar?',
            text: texto,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#dc3545',
            cancelButtonColor: '#6c757d',
            confirmButtonText: 'Sí, salir',
            cancelButtonText: 'Continuar editando',
            allowOutsideClick: false
        }).then(function(result) {
            if (result.isConfirmed) {
                if (idCliente) {
                    window.location.href = contextPath + '/empleado?accion=buscarPorId&id=' + idCliente;
                } else {
                    window.location.href = contextPath + '/empleado?accion=buscarCliente';
                }
            }
        });
    }
</script>
</body>
</html>
