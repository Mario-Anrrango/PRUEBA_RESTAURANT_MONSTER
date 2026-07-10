<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.*,java.util.*" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"EMPLEADO".equals(usuario.getPerfil())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    Cliente clienteEncontrado = (Cliente) request.getAttribute("clienteEncontrado");
    List<Pedido> historial     = (List<Pedido>) request.getAttribute("historialPedidos");
    // FASE 6.24: Paginación
    Integer totalPaginas = (Integer) request.getAttribute("totalPaginas");
    Integer paginaActual = (Integer) request.getAttribute("pagina");
    Long totalRegistros = (Long) request.getAttribute("totalRegistros");
    Integer registrosPorPagina = (Integer) request.getAttribute("registrosPorPagina");
    String fechaDesde = (String) request.getAttribute("fechaDesde");
    String fechaHasta = (String) request.getAttribute("fechaHasta");
    String estadoFiltro = (String) request.getAttribute("estadoFiltro");
    if (totalPaginas == null) totalPaginas = 0;
    if (paginaActual == null) paginaActual = 1;
    if (registrosPorPagina == null) registrosPorPagina = 5;
    if (totalRegistros == null) totalRegistros = 0L;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Buscar Cliente – Empleado</title>
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
        <li><a href="${pageContext.request.contextPath}/empleado">Inicio</a></li>
        <li><a href="${pageContext.request.contextPath}/empleado?accion=formCliente">Registrar Cliente</a></li>
        <li><a href="${pageContext.request.contextPath}/empleado?accion=buscarCliente" class="activo">Buscar Cliente</a></li>
        <li><a href="${pageContext.request.contextPath}/logout">Cerrar Sesión</a></li>
    </ul>
    <span class="navbar-user">Mesero: <%= usuario.getUsername() %></span>
</nav>

<div class="contenedor" style="margin-top:25px;">
    <!-- SweetAlert de mensajes de sesión -->
    <% if (session.getAttribute("mensaje") != null) {
        String tipo = (String) session.getAttribute("tipoMensaje");
        String titulo = "success".equals(tipo) ? "Éxito" : "error".equals(tipo) ? "Error" : "Aviso";
    %>
        <script>
            Swal.fire({
                icon: '<%= tipo %>',
                title: '<%= titulo %>',
                text: '<%= session.getAttribute("mensaje") %>',
                timer: 3000,
                showConfirmButton: false
            });
        </script>
    <% session.removeAttribute("mensaje"); session.removeAttribute("tipoMensaje"); } %>

    <h2 class="titulo-seccion">Buscar Cliente por Cédula o Identificación Extranjera</h2>

    <form action="${pageContext.request.contextPath}/empleado" method="post" class="busqueda-form">
        <input type="hidden" name="accion" value="buscarCedula">
        <div class="form-grupo">
            <label>Número de Cédula (10 dígitos) o Identificación Extranjera</label>
            <input type="text" name="cedula" class="form-control"
                   placeholder="Ingrese cédula o identificación"
                   oninput="this.value = this.value.replace(/[^a-zA-Z0-9]/g, '').trim()"
                   required autofocus>
        </div>
        <button type="submit" class="btn btn-primario" style="height:44px;margin-top:22px;">Buscar</button>
    </form>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alerta alerta-error">${error}</div>
    <% } %>

    <% if (clienteEncontrado != null) { %>
    <div style="background:#fef9f1;border:1px solid var(--borde);border-radius:12px;padding:20px;margin-top:10px;">
        <h3 style="font-family:'Playfair Display',serif;color:var(--marron);margin-bottom:15px;">Cliente Encontrado</h3>
        <table class="tabla" style="margin-top:0;">
            <tbody>
                <tr>
                    <td><strong>Nombre:</strong></td><td><%= clienteEncontrado.getNombreCompleto() %></td>
                    <td><strong>Cédula:</strong></td>
                    <td>
                        <% if (clienteEncontrado.isEsExtranjero() || (clienteEncontrado.getIdentificacionExtranjera() != null && !clienteEncontrado.getIdentificacionExtranjera().isEmpty())) { %>
                            <span class="badge-extranjero" title="Identificación Extranjera">&#x1F516; <%= clienteEncontrado.getIdentificacionExtranjera() %></span>
                        <% } else { %>
                            <span class="badge-ecuatoriano" title="Cédula Ecuatoriana">&#x1F194; <%= clienteEncontrado.getCedula() %></span>
                        <% } %>
                    </td>
                </tr>
                <tr>
                    <td><strong>Teléfono:</strong></td><td><%= clienteEncontrado.getTelefono() != null ? clienteEncontrado.getTelefono() : "-" %></td>
                    <td><strong>Correo:</strong></td><td><%= clienteEncontrado.getCorreo() != null ? clienteEncontrado.getCorreo() : "-" %></td>
                </tr>
                <tr><td colspan="4"><strong>Dirección:</strong> <%= clienteEncontrado.getDireccion() != null ? clienteEncontrado.getDireccion() : "-" %></td></tr>
            </tbody>
        </table>

        <div style="margin-top:20px;display:flex;gap:15px;flex-wrap:wrap;">
            <a href="${pageContext.request.contextPath}/empleado/tomar-pedido?idCliente=<%= clienteEncontrado.getId() %>"
               class="btn btn-exito">&#x1F37D;&#xFE0F; Tomar Pedido Ahora</a>
            <a href="${pageContext.request.contextPath}/empleado?accion=formCliente&id=<%= clienteEncontrado.getId() %>"
               class="btn btn-secundario">&#x270F;&#xFE0F; Editar Datos</a>
        </div>

        <!-- Historial con paginación -->
        <h4 style="font-family:'Playfair Display',serif;color:var(--marron);margin:20px 0 10px;">
            Historial de Pedidos
            <% if (totalRegistros > 0) { %>
                <span style="font-size:0.8em;color:#888;font-weight:400;">(<%= totalRegistros %> pedido(s))</span>
            <% } %>
        </h4>

        <!-- FASE 6.24: Filtros -->
        <form method="get" action="${pageContext.request.contextPath}/empleado" style="display:flex;gap:10px;flex-wrap:wrap;align-items:flex-end;margin-bottom:10px;">
            <input type="hidden" name="accion" value="<%= clienteEncontrado != null ? "buscarPorId" : "buscarCliente" %>">
            <% if (clienteEncontrado != null) { %>
                <input type="hidden" name="id" value="<%= clienteEncontrado.getId() %>">
            <% } %>
            <div class="form-grupo" style="flex:0 0 auto;">
                <label style="font-size:0.8em;">Desde</label>
                <input type="date" name="fechaDesde" id="fechaDesde" class="form-control" style="width:150px;"
                       value="<%= fechaDesde != null ? fechaDesde : "" %>">
            </div>
            <div class="form-grupo" style="flex:0 0 auto;">
                <label style="font-size:0.8em;">Hasta</label>
                <input type="date" name="fechaHasta" id="fechaHasta" class="form-control" style="width:150px;"
                       value="<%= fechaHasta != null ? fechaHasta : "" %>">
            </div>
            <div class="form-grupo" style="flex:0 0 auto;">
                <label style="font-size:0.8em;">Estado</label>
                <select name="estado" class="form-control" style="width:130px;">
                    <option value="">Todos</option>
                    <option value="PENDIENTE" <%= "PENDIENTE".equals(estadoFiltro) ? "selected" : "" %>>PENDIENTE</option>
                    <option value="PAGADO" <%= "PAGADO".equals(estadoFiltro) ? "selected" : "" %>>PAGADO</option>
                    <option value="CANCELADO" <%= "CANCELADO".equals(estadoFiltro) ? "selected" : "" %>>CANCELADO</option>
                </select>
            </div>
            <button type="submit" class="btn btn-sm btn-primario" style="height:40px;">Filtrar</button>
            <% if ((fechaDesde != null && !fechaDesde.isEmpty()) || (fechaHasta != null && !fechaHasta.isEmpty()) || (estadoFiltro != null && !estadoFiltro.isEmpty())) { %>
                <a href="${pageContext.request.contextPath}/empleado?accion=buscarPorId&id=<%= clienteEncontrado.getId() %>" class="btn btn-sm btn-secundario" style="height:40px;display:flex;align-items:center;">✕ Limpiar filtros</a>
            <% } %>
        </form>

        <% if (historial != null && !historial.isEmpty()) { %>
        <table class="tabla">
            <thead>
                <tr><th>#</th><th>Fecha</th><th>Hora</th><th>Estado</th><th>Total</th><th>Acciones</th></tr>
            </thead>
            <tbody>
            <% for (Pedido p : historial) { %>
                <tr>
                    <td><%= p.getId().length() > 8 ? p.getId().substring(0, 8) : p.getId() %></td>
                    <td><%= p.getFecha() %></td>
                    <td><%= p.getHora() %></td>
                    <td>
                        <span style="padding:3px 10px;border-radius:12px;font-size:0.85em;font-weight:600;
                            background:<%= "PAGADO".equals(p.getEstado()) ? "#e8f8f2" : "PENDIENTE".equals(p.getEstado()) ? "#fef9e7" : "#fde8e8" %>;
                            color:<%= "PAGADO".equals(p.getEstado()) ? "#1e8449" : "PENDIENTE".equals(p.getEstado()) ? "#7d6608" : "#7b241c" %>;">
                            <%= p.getEstado() %>
                        </span>
                    </td>
                    <td>$<%= String.format("%.2f", p.getTotal().doubleValue()) %></td>
                    <td>
                        <% if ("PENDIENTE".equals(p.getEstado())) { %>
                            <button class="btn btn-sm btn-exito" onclick="editarPedido('<%= clienteEncontrado.getId() %>', '<%= p.getId() %>')">&#x270F;&#xFE0F; Editar</button>
                            <button class="btn btn-sm btn-peligro" onclick="cancelarPedido('<%= p.getId() %>')">&#x274C; Cancelar</button>
                        <% } else { %>
                            <button class="btn btn-sm btn-secundario" onclick="verFactura('<%= p.getId() %>')">&#x1F4C4; Ver</button>
                        <% } %>
                    </td>
                </tr>
            <% } %>
            </tbody>
        </table>

        <!-- FASE 6.24: Paginación -->
        <% if (totalPaginas > 0) { %>
        <%
            String paramId = clienteEncontrado != null ? "&id=" + clienteEncontrado.getId() : "";
            String paramFechaDesde = (fechaDesde != null && !fechaDesde.isEmpty()) ? "&fechaDesde=" + fechaDesde : "";
            String paramFechaHasta = (fechaHasta != null && !fechaHasta.isEmpty()) ? "&fechaHasta=" + fechaHasta : "";
            String paramEstado = (estadoFiltro != null && !estadoFiltro.isEmpty()) ? "&estado=" + estadoFiltro : "";
            String baseUrl = request.getContextPath() + "/empleado?accion=buscarPorId" + paramId;
            String filterParams = paramFechaDesde + paramFechaHasta + paramEstado;
        %>
        <div class="paginacion" style="display:flex;justify-content:space-between;align-items:center;margin-top:15px;flex-wrap:wrap;gap:10px;">
            <div>
                <label style="color:#888;font-size:0.9em;">Mostrar:
                    <select onchange="window.location.href='<%= baseUrl %>&registros='+this.value+'&pagina=1<%= filterParams %>'" style="border:1px solid #d4b68a;border-radius:5px;padding:3px;margin-left:5px;">
                        <option value="5" <%= registrosPorPagina == 5 ? "selected" : "" %>>5</option>
                        <option value="10" <%= registrosPorPagina == 10 ? "selected" : "" %>>10</option>
                        <option value="25" <%= registrosPorPagina == 25 ? "selected" : "" %>>25</option>
                        <option value="50" <%= registrosPorPagina == 50 ? "selected" : "" %>>50</option>
                    </select>
                </label>
                <span style="color:#888;font-size:0.9em;margin-left:10px;">Total: <%= totalRegistros %> registros</span>
            </div>
            <div style="display:flex;gap:5px;align-items:center;">
                <a href="<%= baseUrl %>&pagina=1&registros=<%= registrosPorPagina %><%= filterParams %>"
                   class="btn btn-sm <%= paginaActual == 1 ? "btn-secundario disabled" : "btn-secundario" %>"
                   <%= paginaActual == 1 ? "style='pointer-events:none;opacity:0.5;'" : "" %>>&#xAB;&#xAB;</a>
                <a href="<%= baseUrl %>&pagina=<%= paginaActual - 1 %>&registros=<%= registrosPorPagina %><%= filterParams %>"
                   class="btn btn-sm <%= paginaActual <= 1 ? "btn-secundario disabled" : "btn-secundario" %>"
                   <%= paginaActual <= 1 ? "style='pointer-events:none;opacity:0.5;'" : "" %>>&#xAB;</a>
                <span style="padding:5px 10px;color:#666;">Pág <%= paginaActual %> de <%= totalPaginas %></span>
                <a href="<%= baseUrl %>&pagina=<%= paginaActual + 1 %>&registros=<%= registrosPorPagina %><%= filterParams %>"
                   class="btn btn-sm <%= paginaActual >= totalPaginas ? "btn-secundario disabled" : "btn-secundario" %>"
                   <%= paginaActual >= totalPaginas ? "style='pointer-events:none;opacity:0.5;'" : "" %>>&#xBB;</a>
                <a href="<%= baseUrl %>&pagina=<%= totalPaginas %>&registros=<%= registrosPorPagina %><%= filterParams %>"
                   class="btn btn-sm <%= paginaActual >= totalPaginas ? "btn-secundario disabled" : "btn-secundario" %>"
                   <%= paginaActual >= totalPaginas ? "style='pointer-events:none;opacity:0.5;'" : "" %>>&#xBB;&#xBB;</a>
            </div>
        </div>
        <% } %>
        <% } else { %>
            <p style="margin-top:15px;color:#666;">Este cliente aún no tiene pedidos registrados.</p>
        <% } %>
    </div>
    <% } %>
</div>

<script>
    var contextPath = '${pageContext.request.contextPath}';

    // FASE 6.20: Editar pedido
    function editarPedido(clienteId, pedidoId) {
        Swal.fire({
            title: '&#x270F;&#xFE0F; Editar pedido',
            text: 'Se abrirá el menú para modificar el pedido',
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#27ae60',
            cancelButtonColor: '#6c757d',
            confirmButtonText: 'Sí, editar',
            cancelButtonText: 'Cancelar'
        }).then(function(result) {
            if (result.isConfirmed) {
                window.location.href = contextPath + '/empleado/tomar-pedido?idCliente=' + clienteId + '&modificar=' + pedidoId;
            }
        });
    }

    // FASE 6.20: Cancelar pedido
    function cancelarPedido(pedidoId) {
        Swal.fire({
            title: '&#x274C; Cancelar este pedido',
            text: 'Esta acción no se puede deshacer',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#dc3545',
            cancelButtonColor: '#6c757d',
            confirmButtonText: 'Sí, cancelar',
            cancelButtonText: 'Volver',
            allowOutsideClick: false
        }).then(function(result) {
            if (result.isConfirmed) {
                window.location.href = contextPath + '/empleado?accion=cancelarPedido&id=' + pedidoId;
            }
        });
    }

    // FASE 6.20: Ver factura
    function verFactura(pedidoId) {
        window.location.href = contextPath + '/factura?id=' + pedidoId;
    }

    // FASE 6.29: Validación fecha Hasta >= Desde (replicado de cliente)
    document.addEventListener('DOMContentLoaded', function() {
        var inputDesde = document.getElementById('fechaDesde');
        var inputHasta = document.getElementById('fechaHasta');

        if (inputDesde && inputHasta) {
            inputDesde.addEventListener('change', function() {
                if (inputHasta.value && inputHasta.value < this.value) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Fecha inválida',
                        text: 'La fecha "hasta" no puede ser anterior a "desde"',
                        confirmButtonText: 'Entendido'
                    });
                    inputHasta.value = this.value;
                }
                if (this.value) {
                    inputHasta.min = this.value;
                }
            });

            inputHasta.addEventListener('change', function() {
                if (inputDesde.value && this.value < inputDesde.value) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Fecha inválida',
                        text: 'La fecha "hasta" no puede ser anterior a "desde"',
                        confirmButtonText: 'Entendido'
                    });
                    this.value = inputDesde.value;
                }
            });
        }
    });
</script>
<script src="${pageContext.request.contextPath}/js/validaciones.js"></script>
</body>
</html>