<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.*,java.util.*,java.time.*" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"CLIENTE".equals(usuario.getPerfil())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    Cliente cliente = (Cliente) session.getAttribute("cliente");
    List<Pedido> pedidos = (List<Pedido>) request.getAttribute("pedidos");
    String filtroEstado = request.getParameter("estado");
    String filtroDesde  = request.getParameter("desde");
    String filtroHasta  = request.getParameter("hasta");
    if (filtroEstado == null) filtroEstado = "TODOS";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mis Reservas – Restaurant Master Monster</title>
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
        <li><a href="${pageContext.request.contextPath}/menu">Menú</a></li>
        <li><a href="${pageContext.request.contextPath}/reservas" class="activo">Mis Reservas</a></li>
        <li><a href="${pageContext.request.contextPath}/logout">Cerrar Sesión</a></li>
    </ul>
    <span class="navbar-user"><%= cliente != null ? cliente.getNombreCompleto() : usuario.getUsername() %></span>
</nav>

<div class="contenedor" style="margin-top:25px;">
    <!-- Mensajes SweetAlert -->
    <c:if test="${not empty sessionScope.mensaje}">
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        Swal.fire({
            icon: '${sessionScope.tipoMensaje}',
            title: '${sessionScope.mensaje}',
            timer: 3000,
            showConfirmButton: false
        });
    });
    </script>
    <c:remove var="mensaje" scope="session"/>
    <c:remove var="tipoMensaje" scope="session"/>
    </c:if>

    <h2 class="titulo-seccion">Mis Reservas / Pedidos</h2>

    <!-- Filtros -->
    <form action="${pageContext.request.contextPath}/reservas" method="get" class="busqueda-form" id="formFiltros">
        <div class="form-grupo">
            <label>Desde</label>
            <input type="date" name="desde" id="fechaDesde" class="form-control" value="<%= filtroDesde != null ? filtroDesde : "" %>">
        </div>
        <div class="form-grupo">
            <label>Hasta</label>
            <input type="date" name="hasta" id="fechaHasta" class="form-control" value="<%= filtroHasta != null ? filtroHasta : "" %>">
        </div>
        <div class="form-grupo">
            <label>Estado</label>
            <select name="estado" class="form-control">
                <option value="TODOS" <%= "TODOS".equals(filtroEstado) ? "selected" : "" %>>Todos</option>
                <option value="PENDIENTE" <%= "PENDIENTE".equals(filtroEstado) ? "selected" : "" %>>Pendiente</option>
                <option value="PAGADO" <%= "PAGADO".equals(filtroEstado) ? "selected" : "" %>>Pagado</option>
                <option value="CANCELADO" <%= "CANCELADO".equals(filtroEstado) ? "selected" : "" %>>Cancelado</option>
            </select>
        </div>
        <button type="submit" class="btn btn-primario" style="height:44px;margin-top:22px;">Filtrar</button>
        
        <%-- FASE 6.7: Botón Limpiar filtros (visible solo si hay filtros activos) --%>
        <% if ((filtroDesde != null && !filtroDesde.isEmpty()) || 
               (filtroHasta != null && !filtroHasta.isEmpty()) || 
               !"TODOS".equals(filtroEstado)) { %>
            <a href="${pageContext.request.contextPath}/reservas" 
               class="btn btn-secundario" style="height:44px;margin-top:22px;display:inline-flex;align-items:center;">
                ✕ Limpiar filtros
            </a>
        <% } %>
    </form>

    <%
        String msg = request.getParameter("msg");
        if ("cancelado".equals(msg)) { %><div class="alerta alerta-info">Pedido cancelado correctamente.</div><% }
        if ("modificado".equals(msg)) { %><div class="alerta alerta-exito">Pedido modificado correctamente.</div><% }
    %>

    <!-- Tabla de pedidos -->
    <table class="tabla">
        <thead>
            <tr>
                <th>#</th><th>Fecha</th><th>Hora</th><th>Estado</th><th>Total</th><th>Acciones</th>
            </tr>
        </thead>
        <tbody>
        <%
            if (pedidos != null && !pedidos.isEmpty()) {
                LocalDateTime ahora = LocalDateTime.now();
                for (Pedido p : pedidos) {
                    LocalDateTime creado = p.getFecha().atTime(p.getHora());
                    boolean esModificable = "PENDIENTE".equals(p.getEstado())
                        && Duration.between(creado, ahora).toHours() < 24;
        %>
            <tr>
                <td><%= p.getId() %></td>
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
                    <a href="${pageContext.request.contextPath}/factura?id=<%= p.getId() %>"
                       class="btn btn-sm btn-secundario">Ver</a>
                    <% if (esModificable) { %>
                        <a href="${pageContext.request.contextPath}/menu?modificar=<%= p.getId() %>"
                           class="btn btn-sm btn-exito">Modificar</a>
                        <a href="#" class="btn btn-sm btn-peligro"
                           onclick="confirmarCancelar('<%= p.getId() %>'); return false;">Cancelar</a>
                    <% } %>
                </td>
            </tr>
        <%  }
            } else { %>
            <tr><td colspan="6" style="text-align:center;color:#888;padding:30px;">No tienes pedidos registrados.</td></tr>
        <% } %>
        </tbody>
    </table>
    
    <%-- FASE 6.7: Paginación — siempre visible cuando hay registros --%>
    <%
        Integer tp = (Integer) request.getAttribute("totalPaginas");
        Integer pg = (Integer) request.getAttribute("pagina");
        Integer rpp = (Integer) request.getAttribute("registrosPorPagina");
        Integer tr = (Integer) request.getAttribute("totalRegistros");
        if (tp == null) tp = 1;
        if (pg == null) pg = 1;
        if (rpp == null) rpp = 5;
        if (tr == null) tr = 0;
        
        // Construir URL base para paginación (mantener filtros)
        String baseUrl = request.getContextPath() + "/reservas?pagina=";
        String paramsUrl = "&registros=" + rpp;
        if (filtroDesde != null && !filtroDesde.isEmpty()) paramsUrl += "&desde=" + filtroDesde;
        if (filtroHasta != null && !filtroHasta.isEmpty()) paramsUrl += "&hasta=" + filtroHasta;
        if (filtroEstado != null && !"TODOS".equals(filtroEstado)) paramsUrl += "&estado=" + filtroEstado;
    %>
    
    <% if (tr > 0) { %>
    <div class="paginacion-container">
        <div class="paginacion-info">
            <label>Mostrar: 
                <select class="registros-select" onchange="cambiarRegistros(this.value)">
                    <option value="5" <%= rpp == 5 ? "selected" : "" %>>5</option>
                    <option value="10" <%= rpp == 10 ? "selected" : "" %>>10</option>
                    <option value="25" <%= rpp == 25 ? "selected" : "" %>>25</option>
                    <option value="50" <%= rpp == 50 ? "selected" : "" %>>50</option>
                </select>
            </label>
            <span>Total: <%= tr %> registros</span>
        </div>
        
        <% if (tp > 1) { %>
        <div class="paginacion-botones">
            <a href="<%= baseUrl + 1 + paramsUrl %>" class="<%= pg == 1 ? "disabled" : "" %>">≪ Inicio</a>
            <a href="<%= baseUrl + (pg - 1) + paramsUrl %>" class="<%= pg == 1 ? "disabled" : "" %>">‹ Anterior</a>
            <span class="pagina-actual">Pág <%= pg %> de <%= tp %></span>
            <a href="<%= baseUrl + (pg + 1) + paramsUrl %>" class="<%= pg == tp ? "disabled" : "" %>">Siguiente ›</a>
            <a href="<%= baseUrl + tp + paramsUrl %>" class="<%= pg == tp ? "disabled" : "" %>">Fin ≫</a>
        </div>
        <% } %>
    </div>
    <% } %>
</div>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>var contextPath = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/js/confirmaciones.js"></script>
<script src="${pageContext.request.contextPath}/js/validaciones.js"></script>
<script>
function cambiarRegistros(cantidad) {
    var url = new URL(window.location.href);
    url.searchParams.set('registros', cantidad);
    url.searchParams.set('pagina', '1');
    window.location.href = url.toString();
}

// Validación de fechas (ERROR 11) - específica de esta página
document.addEventListener('DOMContentLoaded', function() {
    var inputDesde = document.getElementById('fechaDesde');
    var inputHasta = document.getElementById('fechaHasta');

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
});
</script>
</body>
</html>
