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
    String modo = esEdicion ? "editar" : "crear";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= esEdicion ? "Editar" : "Nuevo" %> Plato – Admin</title>
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
        <li><a href="${pageContext.request.contextPath}/admin">Inicio</a></li>
        <li><a href="${pageContext.request.contextPath}/admin?accion=listarPlatos" class="activo">Platos</a></li>
        <li><a href="${pageContext.request.contextPath}/admin?accion=listarClientes">Clientes</a></li>
        <li><a href="${pageContext.request.contextPath}/admin?accion=listarEmpleados">Empleados</a></li>
        <li><a href="${pageContext.request.contextPath}/logout">Cerrar Sesion</a></li>
    </ul>
    <span class="navbar-user">Admin: <%= usuario.getUsername() %></span>
</nav>

<div class="contenedor contenedor-medio" style="margin-top:25px;">
    <h2 class="titulo-seccion"><%= esEdicion ? "Editar Plato" : "Nuevo Plato" %></h2>

    <form action="${pageContext.request.contextPath}/admin" method="post" enctype="multipart/form-data" id="formPlato">
        <input type="hidden" name="accion" value="<%= esEdicion ? "actualizarPlato" : "guardarPlato" %>">
        <% if (esEdicion) { %>
            <input type="hidden" name="id" value="<%= plato.getId() %>">
            <input type="hidden" name="fotoActual" value="<%= plato.getFoto() != null ? plato.getFoto() : "" %>">
        <% } %>

        <div class="form-row">
            <div class="form-grupo">
                <label>Nombre del Plato *</label>
                <input type="text" id="nombre" name="nombre" class="form-control" required
                       value="<%= esEdicion ? plato.getNombre() : "" %>"
                       placeholder="Ej: Churrasco Especial"
                       minlength="4" maxlength="50"
                       oninput="actualizarPreview();">
                <div id="nombre-error" class="validation-message"></div>
                <small style="color:#888;font-size:0.8em;">Solo letras, tildes y n. Minimo 4, maximo 50 caracteres</small>
            </div>
            <div class="form-grupo">
                <label>Categoria *</label>
                <select id="categoria" name="idCategoria" class="form-control" required
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
                <div id="categoria-error" class="validation-message"></div>
            </div>
        </div>

        <div class="form-row">
            <div class="form-grupo">
                <label>Precio ($) *</label>
                <input type="text" id="precio" name="precio" class="form-control" required
                       value="<%= esEdicion && plato.getPrecio() != null ? plato.getPrecio() : "" %>"
                       placeholder="0.00"
                       oninput="actualizarPreview();">
                <div id="precio-error" class="validation-message"></div>
                <small style="color:#888;font-size:0.8em;">Solo numeros. Minimo $0.10, maximo $99.99</small>
            </div>
            <div class="form-grupo">
                <label>Foto del Plato</label>
                <% if (esEdicion && plato.getFoto() != null && !plato.getFoto().isEmpty()) { %>
                    <div class="foto-actual">
                        <p>&#x1F4F7; Foto actual: <strong><%= plato.getFoto() %></strong></p>
                        <img src="${pageContext.request.contextPath}/images/<%= plato.getFoto() %>"
                             alt="Foto actual" class="foto-actual-img"
                             onerror="this.style.display='none'">
                        <label class="btn-cambiar-foto">
                            <input type="file" id="foto" name="foto"
                                   accept="image/*" onchange="previewImagen(this)">
                            &#x1F4C1; Cambiar foto
                        </label>
                        <small>JPG, JPEG o PNG. Maximo 5MB</small>
                    </div>
                <% } else { %>
                    <input type="file" id="foto" name="foto" class="form-control"
                           accept="image/*" onchange="previewImagen(this)">
                    <small style="color:#888;font-size:0.8em;">JPG, JPEG o PNG. Maximo 5MB</small>
                <% } %>
            </div>
        </div>

        <%-- FASE 6.9: CAMPO ESTADO ELIMINADO --%>

        <div class="form-grupo">
            <label>Descripcion *</label>
            <textarea id="descripcion" name="descripcion" class="form-control" rows="4"
                      placeholder="Describe el plato..." minlength="10" maxlength="300"
                      oninput="actualizarPreview(); actualizarContador(this, 300)"><%= esEdicion && plato.getDescripcion() != null ? plato.getDescripcion() : "" %></textarea>
            <div id="descripcion-error" class="validation-message"></div>
            <div class="char-counter" id="charCounter">0/300 caracteres</div>
        </div>

        <!-- Vista Previa -->
        <div class="form-grupo" style="margin-top:20px;padding:20px;background:#fef9f1;border-radius:12px;border:1px solid var(--borde);">
            <h4 style="font-family:'Playfair Display',serif;color:var(--marron);margin-bottom:10px;">&#x1F4F7; Vista Previa</h4>
            <div style="display:flex;gap:20px;align-items:center;flex-wrap:wrap;">
                <img id="previewImg" src="<%= esEdicion && plato.getFoto() != null && !plato.getFoto().isEmpty() ? request.getContextPath() + "/images/" + plato.getFoto() : "" %>"
                     width="150" height="120" style="object-fit:cover;border-radius:10px;box-shadow:0 3px 10px rgba(0,0,0,0.15);"
                     onerror="this.src='${pageContext.request.contextPath}/img/LOGO_EMPRESA/Monster.jpg'">
                <div>
                    <h5 id="previewNombre" style="font-family:'Playfair Display',serif;color:var(--marron);font-size:1.2em;">
                        <%= esEdicion ? plato.getNombre() : "Nombre del plato" %>
                    </h5>
                    <span id="previewCategoria" style="color:#888;font-size:0.9em;">
                        <%= esEdicion && plato.getNombreCategoria() != null ? plato.getNombreCategoria() : "Sin categoria" %>
                    </span>
                    <div style="font-weight:700;font-size:1.3em;color:var(--marron-osc);margin-top:5px;">
                        $<span id="previewPrecio"><%= esEdicion && plato.getPrecio() != null ? plato.getPrecio() : "0.00" %></span>
                    </div>
                    <p id="previewDescripcion" style="color:#666;font-size:0.85em;margin-top:5px;">
                        <%= esEdicion && plato.getDescripcion() != null ? plato.getDescripcion() : "Descripcion del plato..." %>
                    </p>
                </div>
            </div>
        </div>

        <div style="display:flex;gap:15px;margin-top:15px;">
            <button type="submit" class="btn btn-primario" id="btnSubmit">
                <%= esEdicion ? "Actualizar Plato" : "Guardar Plato" %>
            </button>
            <a href="${pageContext.request.contextPath}/admin?accion=listarPlatos" class="btn btn-secundario">Cancelar</a>
        </div>
    </form>
</div>

<script src="${pageContext.request.contextPath}/js/validaciones.js"></script>
<script src="${pageContext.request.contextPath}/js/form-plato.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Inicializar validaciones en tiempo real
    if (document.getElementById('formPlato')) {
        validarNombrePlato();
        validarPrecioPlato();
        validarCategoriaPlato();
        validarDescripcionPlato();
    }
});

document.getElementById('formPlato').addEventListener('submit', function(e) {
    e.preventDefault();

    // Validar todos los campos
    var errores = [];

    // Validar nombre
    var nombre = document.getElementById('nombre').value.trim();
    if (nombre.length < 4 || nombre.length > 50) {
        errores.push('Nombre: 4-50 caracteres');
    }
    if (!/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/.test(nombre)) {
        errores.push('Nombre: solo letras permitidas');
    }

    // Validar categoria
    var categoria = document.getElementById('categoria').value;
    if (!categoria || categoria === '') {
        errores.push('Debe seleccionar una categoria');
    }

    // Validar precio
    var precio = parseFloat(document.getElementById('precio').value);
    if (isNaN(precio) || precio < 0.10 || precio > 99.99) {
        errores.push('Precio: 0.10 a 99.99');
    }

    // Validar descripcion
    var descripcion = document.getElementById('descripcion').value.trim();
    if (descripcion.length < 10 || descripcion.length > 300) {
        errores.push('Descripcion: 10-300 caracteres');
    }

    if (errores.length > 0) {
        Swal.fire({
            icon: 'error',
            title: 'Errores de validacion',
            html: errores.join('<br>'),
            confirmButtonText: 'Corregir'
        });
        return false;
    }

    // Si no hay errores, mostrar confirmacion
    var titulo = '<%= esEdicion ? "Actualizar plato?" : "Crear nuevo plato?" %>';
    var texto = '<%= esEdicion ? "Se actualizaran los datos del plato" : "Se registrara un nuevo plato en el menu" %>';

    Swal.fire({
        title: titulo,
        text: texto,
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#28a745',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Si, <%= esEdicion ? "actualizar" : "crear" %>',
        cancelButtonText: 'Cancelar'
    }).then((result) => {
        if (result.isConfirmed) {
            e.target.submit();
        }
    });

    return false;
});
</script>
</body>
</html>
