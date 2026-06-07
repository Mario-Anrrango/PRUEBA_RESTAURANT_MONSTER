<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.*,java.util.*" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"ADMIN".equals(usuario.getPerfil())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    Plato plato = (Plato) request.getAttribute("plato");
    List<Categoria> categorias = (List<Categoria>) request.getAttribute("categorias");
    boolean esEdicion = (plato != null && plato.getId() > 0);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= esEdicion ? "Editar" : "Nuevo" %> Plato – Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body>
<div class="encabezado">
    <h1>Restaurant Master Monster</h1>
    <img src="${pageContext.request.contextPath}/img/LOGO_EMPRESA/Monster.jpg" alt="Logo" class="logo-encabezado">
</div>
<nav class="navbar">
    <ul class="navbar-links">
        <li><a href="${pageContext.request.contextPath}/admin">Inicio</a></li>
        <li><a href="${pageContext.request.contextPath}/admin?accion=listarPlatos" class="activo">Platos</a></li>
        <li><a href="${pageContext.request.contextPath}/admin?accion=listarClientes">Clientes</a></li>
        <li><a href="${pageContext.request.contextPath}/admin?accion=listarEmpleados">Empleados</a></li>
        <li><a href="${pageContext.request.contextPath}/logout">Cerrar Sesión</a></li>
    </ul>
    <span class="navbar-user">Admin: <%= usuario.getUsername() %></span>
</nav>

<div class="contenedor contenedor-medio" style="margin-top:25px;">
    <h2 class="titulo-seccion"><%= esEdicion ? "Editar Plato" : "Nuevo Plato" %></h2>

    <form action="${pageContext.request.contextPath}/admin" method="post">
        <input type="hidden" name="accion" value="guardarPlato">
        <% if (esEdicion) { %>
            <input type="hidden" name="id" value="<%= plato.getId() %>">
        <% } %>

        <div class="form-row">
            <div class="form-grupo">
                <label>Nombre del Plato *</label>
                <input type="text" name="nombre" class="form-control" required
                       value="<%= esEdicion ? plato.getNombre() : "" %>"
                       placeholder="Ej: Churrasco Especial">
            </div>
            <div class="form-grupo">
                <label>Categoría *</label>
                <select name="idCategoria" class="form-control" required>
                    <option value="">-- Seleccionar --</option>
                    <% if (categorias != null) {
                        for (Categoria c : categorias) { %>
                    <option value="<%= c.getId() %>"
                        <%= (esEdicion && plato.getIdCategoria() == c.getId()) ? "selected" : "" %>>
                        <%= c.getNombre() %>
                    </option>
                    <% } } %>
                </select>
            </div>
        </div>

        <div class="form-row">
            <div class="form-grupo">
                <label>Precio ($) *</label>
                <input type="number" name="precio" class="form-control" required
                       step="0.01" min="0.01"
                       value="<%= esEdicion ? plato.getPrecio() : "" %>"
                       placeholder="0.00">
            </div>
            <div class="form-grupo">
                <label>Ruta de la Foto</label>
                <input type="text" name="foto" class="form-control"
                       value="<%= esEdicion && plato.getFoto() != null ? plato.getFoto() : "" %>"
                       placeholder="img/PLATO_FUERTE/mi-plato.jpg">
            </div>
        </div>

        <% if (esEdicion) { %>
        <div class="form-grupo">
            <label>Estado</label>
            <select name="activo_campo" class="form-control" id="activoSelect">
                <option value="1" <%= plato.getActivo()==1?"selected":"" %>>Activo</option>
                <option value="0" <%= plato.getActivo()==0?"selected":"" %>>Inactivo</option>
            </select>
        </div>
        <% } %>

        <div class="form-grupo">
            <label>Descripción</label>
            <textarea name="descripcion" class="form-control" rows="4"
                      placeholder="Describe el plato..."><%= esEdicion && plato.getDescripcion() != null ? plato.getDescripcion() : "" %></textarea>
        </div>

        <!-- Vista previa de imagen -->
        <% if (esEdicion && plato.getFoto() != null && !plato.getFoto().isEmpty()) { %>
        <div class="form-grupo">
            <label>Vista previa</label><br>
            <img src="${pageContext.request.contextPath}/<%= plato.getFoto() %>"
                 width="200" style="border-radius:10px;box-shadow:0 3px 10px rgba(0,0,0,0.15);"
                 onerror="this.style.display='none'">
        </div>
        <% } %>

        <div style="display:flex;gap:15px;margin-top:15px;">
            <button type="submit" class="btn btn-primario"><%= esEdicion ? "Actualizar Plato" : "Guardar Plato" %></button>
            <a href="${pageContext.request.contextPath}/admin?accion=listarPlatos" class="btn btn-secundario">Cancelar</a>
        </div>
    </form>
</div>
</body>
</html>
