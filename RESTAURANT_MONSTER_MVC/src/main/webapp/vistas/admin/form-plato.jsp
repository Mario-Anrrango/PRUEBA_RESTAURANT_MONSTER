<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.*,java.util.*" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"ADMIN".equals(usuario.getPerfil())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    Plato plato = (Plato) request.getAttribute("plato");
    List<Categoria> categorias = (List<Categoria>) request.getAttribute("categorias");
    boolean esEdicion = (plato != null && plato.getId() != null && !plato.getId().isEmpty());
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= esEdicion ? "Editar" : "Nuevo" %> Plato – Admin</title>
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

    <form action="${pageContext.request.contextPath}/admin" method="post" enctype="multipart/form-data">
        <input type="hidden" name="accion" value="<%= esEdicion ? "actualizarPlato" : "guardarPlato" %>">
        <% if (esEdicion) { %>
            <input type="hidden" name="id" value="<%= plato.getId() %>">
        <% } %>

        <div class="form-row">
            <div class="form-grupo">
                <label>Nombre del Plato *</label>
                <input type="text" name="nombre" class="form-control" required
                       value="<%= esEdicion ? plato.getNombre() : "" %>"
                       placeholder="Ej: Churrasco Especial"
                       minlength="4" maxlength="50"
                       oninput="document.getElementById('previewNombre').textContent=this.value||'Nombre del plato'">
                <small style="color:#888;font-size:0.8em;">Solo letras, tildes y ñ. Mínimo 4, máximo 50 caracteres</small>
            </div>
            <div class="form-grupo">
                <label>Categoría *</label>
                <select name="idCategoria" class="form-control" required
                        onchange="actualizarPreview()">
                    <option value="">-- Seleccionar --</option>
                    <% if (categorias != null) {
                        for (Categoria c : categorias) { %>
                    <option value="<%= c.getId() %>"
                        <%= (esEdicion && plato.getIdCategoria() != null && plato.getIdCategoria().equals(c.getId())) ? "selected" : "" %>>
                        <%= c.getNombre() %>
                    </option>
                    <% } } %>
                </select>
            </div>
        </div>

        <div class="form-row">
            <div class="form-grupo">
                <label>Precio ($) *</label>
                <input type="text" name="precio" class="form-control" required
                       value="<%= esEdicion && plato.getPrecio() != null ? plato.getPrecio() : "" %>"
                       placeholder="0.00"
                       oninput="this.value=this.value.replace(/[^0-9.,]/g,''); actualizarPreview();">
                <small style="color:#888;font-size:0.8em;">Solo números. Formato: 0.00 a 99.99</small>
            </div>
            <div class="form-grupo">
                <label>Foto del Plato</label>
                <input type="file" name="foto" class="form-control" accept="image/*"
                       onchange="previewImagen(this)">
                <small style="color:#888;font-size:0.8em;">JPG, JPEG o PNG. Máximo 5MB</small>
            </div>
        </div>

        <% if (esEdicion) { %>
        <div class="form-grupo">
            <label>Estado</label>
            <select name="activo_campo" class="form-control">
                <option value="1" <%= plato.isActivo()?"selected":"" %>>Activo</option>
                <option value="0" <%= !plato.isActivo()?"selected":"" %>>Inactivo</option>
            </select>
        </div>
        <% } %>

        <div class="form-grupo">
            <label>Descripción *</label>
            <textarea name="descripcion" class="form-control" rows="4"
                      placeholder="Describe el plato..." minlength="10" maxlength="300"
                      oninput="actualizarPreview(); actualizarContador(this, 300)"><%= esEdicion && plato.getDescripcion() != null ? plato.getDescripcion() : "" %></textarea>
            <div class="char-counter" id="charCounter">0/300 caracteres</div>
        </div>

        <!-- Vista Previa -->
        <div class="form-grupo" style="margin-top:20px;padding:20px;background:#fef9f1;border-radius:12px;border:1px solid var(--borde);">
            <h4 style="font-family:'Playfair Display',serif;color:var(--marron);margin-bottom:10px;">📷 Vista Previa</h4>
            <div style="display:flex;gap:20px;align-items:center;flex-wrap:wrap;">
                <img id="previewImg" src="<%= esEdicion && plato.getFoto() != null && !plato.getFoto().isEmpty() ? request.getContextPath() + "/" + plato.getFoto() : "" %>"
                     width="150" height="120" style="object-fit:cover;border-radius:10px;box-shadow:0 3px 10px rgba(0,0,0,0.15);"
                     onerror="this.src='${pageContext.request.contextPath}/img/LOGO_EMPRESA/Monster.jpg'">
                <div>
                    <h5 id="previewNombre" style="font-family:'Playfair Display',serif;color:var(--marron);font-size:1.2em;">
                        <%= esEdicion ? plato.getNombre() : "Nombre del plato" %>
                    </h5>
                    <span id="previewCategoria" style="color:#888;font-size:0.9em;">
                        <%= esEdicion && plato.getIdCategoria() != null ? "Categoría seleccionada" : "Sin categoría" %>
                    </span>
                    <div style="font-weight:700;font-size:1.3em;color:var(--marron-osc);margin-top:5px;">
                        $<span id="previewPrecio"><%= esEdicion && plato.getPrecio() != null ? plato.getPrecio() : "0.00" %></span>
                    </div>
                    <p id="previewDescripcion" style="color:#666;font-size:0.85em;margin-top:5px;">
                        <%= esEdicion && plato.getDescripcion() != null ? plato.getDescripcion() : "Descripción del plato..." %>
                    </p>
                </div>
            </div>
        </div>

        <div style="display:flex;gap:15px;margin-top:15px;">
            <button type="submit" class="btn btn-primario"><%= esEdicion ? "Actualizar Plato" : "Guardar Plato" %></button>
            <a href="${pageContext.request.contextPath}/admin?accion=listarPlatos" class="btn btn-secundario">Cancelar</a>
        </div>
    </form>
</div>

<script src="${pageContext.request.contextPath}/js/validaciones.js"></script>
<script src="${pageContext.request.contextPath}/js/form-plato.js"></script>
</body>
</html>
