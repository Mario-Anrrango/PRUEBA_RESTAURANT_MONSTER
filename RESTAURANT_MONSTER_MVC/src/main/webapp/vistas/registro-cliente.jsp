<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Registro de Cliente – Restaurant Master Monster</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/validaciones.css">
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script>var contextPath = '${pageContext.request.contextPath}';</script>
    </head>
    <body>
        <div style="padding:20px;">
            <div class="encabezado">
                <h1>Restaurant Master Monster</h1>
                <img src="${pageContext.request.contextPath}/img/LOGO_EMPRESA/Monster.jpg" alt="Logo" class="logo-encabezado">
            </div>

            <div class="contenedor contenedor-medio" style="margin-top:25px;">
                <h2 class="titulo-seccion">Registro de Nuevo Cliente</h2>

                <% if (request.getAttribute("error") != null) { %>
                <div class="alerta alerta-error">${error}</div>
                <% }%>

                <form action="${pageContext.request.contextPath}/registro" method="post"
                      id="formRegistro"
                      onsubmit="return validarFormularioRegistro(this)">

                    <div class="form-row">
                        <div class="form-grupo flex-half">
                            <label>Nombres *</label>
                            <input type="text" id="nombres" name="nombres" class="form-control" required
                                   placeholder="Ej: María Fernanda" minlength="4" maxlength="40"
                                   onblur="validarNombresOnBlur()">
                            <div id="nombres-message" class="validation-message"></div>
                        </div>
                        <div class="form-grupo flex-half">
                            <label>Apellidos *</label>
                            <input type="text" id="apellidos" name="apellidos" class="form-control" required
                                   placeholder="Ej: García López" minlength="4" maxlength="40"
                                   onblur="validarApellidosOnBlur()">
                            <div id="apellidos-message" class="validation-message"></div>
                        </div>
                    </div>

                    <div class="form-grupo checkbox-extranjero">
                        <input type="checkbox" id="esExtranjero" name="esExtranjero" onchange="toggleExtranjero()">
                        <label for="esExtranjero">Soy extranjero (no tengo cédula ecuatoriana)</label>
                    </div>

                    <div class="form-row">
                        <div class="form-grupo flex-half" id="grupo-cedula">
                            <label>Cédula Ecuatoriana *</label>
                            <input type="text" id="cedula" name="cedula" class="form-control" required maxlength="10"
                                   pattern="[0-9]{10}" title="10 dígitos numéricos" placeholder="0912345678"
                                   onblur="validarCedulaOnBlur()">
                            <small style="color:#888;font-size:0.8em;">10 dígitos numéricos</small>
                            <div id="cedula-message" class="validation-message"></div>
                        </div>
                        <div class="form-grupo flex-half" id="grupo-identificacion" style="display:none;">
                            <label>Identificación Extranjera *</label>
                            <input type="text" id="identificacionExtranjera" name="identificacionExtranjera"
                                   class="form-control" disabled
                                   placeholder="Pasaporte o ID extranjero" minlength="5" maxlength="20"
                                   oninput="this.value = this.value.replace(/[^a-zA-Z0-9]/g, '').trim()"
                                   onblur="validarIdentificacionOnBlur()">
                            <small style="color:#888;font-size:0.8em;">5-20 caracteres alfanuméricos</small>
                            <div id="identificacion-message" class="validation-message"></div>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-grupo flex-half">
                            <label>Teléfono *</label>
                            <input type="text" id="telefono" name="telefono" class="form-control" maxlength="10"
                                   placeholder="Ej: 0991234567" required
                                   onblur="validarTelefonoOnBlur()">
                            <div id="telefono-message" class="validation-message"></div>
                        </div>
                        <div class="form-grupo flex-half">
                            <label>Correo Electrónico *</label>
                            <input type="email" id="correo" name="correo" class="form-control" required
                                   placeholder="correo@ejemplo.com"
                                   onblur="validarCorreoOnBlur()">
                            <div id="correo-message" class="validation-message"></div>
                        </div>
                    </div>

                    <div class="form-grupo">
                        <label>Dirección *</label>
                        <textarea id="direccion" name="direccion" class="form-control" required
                                  placeholder="Av. Principal 123, Quito"
                                  minlength="10" maxlength="200"
                                  style="min-height:90px;resize:vertical;"
                                  oninput="actualizarContador(this, 200)"
                                  onblur="validarDireccionOnBlur()"></textarea>
                        <small style="color:#888;font-size:0.8em;">Mínimo 10 caracteres, máximo 200</small>
                        <div id="direccion-message" class="validation-message"></div>
                    </div>

                    <hr style="margin:20px 0;border-color:var(--borde);">
                    <h3 style="font-family:'Playfair Display',serif;color:var(--marron);margin-bottom:15px;">Datos de acceso</h3>

                    <div class="form-row">
                        <div class="form-grupo flex-half">
                            <label>Nombre de Usuario *</label>
                            <input type="text" id="username" name="username" class="form-control" required
                                   placeholder="usuario_ejemplo" minlength="4" maxlength="30"
                                   onblur="validarUsuarioOnBlur()">
                            <small style="color:#888;font-size:0.8em;">Solo letras, números y _. Sin espacios</small>
                            <div id="username-message" class="validation-message"></div>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-grupo flex-half">
                            <label>Contraseña *</label>
                            <div class="password-wrapper">
                                <input type="password" id="contrasena" name="password" class="form-control" required minlength="8"
                                       onblur="validarContrasenaOnBlur()">
                                <button type="button" class="password-toggle" data-target="contrasena"
                                        onclick="togglePasswordVisibility('contrasena')" tabindex="-1">👁️</button>
                            </div>
                            <small style="color:#888;font-size:0.8em;">Mínimo 8 caracteres, 1 mayúscula y 1 carácter especial</small>
                            <div id="contrasena-message" class="validation-message"></div>
                        </div>

                        <div class="form-grupo flex-half">
                            <label>Confirmar Contraseña *</label>
                            <input type="password" id="confirmPassword" class="form-control" required minlength="8"
                                   onblur="validarConfirmacionOnBlur()">
                            <div id="confirmPassword-message" class="validation-message"></div>
                        </div>
                    </div>

                    <div style="display:flex;gap:15px;margin-top:10px;">
                        <button type="submit" class="btn btn-primario" id="btnRegistro">Registrarme</button>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-secundario">Cancelar</a>
                    </div>
                </form>
            </div>
        </div>
        <script src="${pageContext.request.contextPath}/js/validaciones.js"></script>
        <script src="${pageContext.request.contextPath}/js/extranjero.js"></script>
        <script>
                                       document.addEventListener('DOMContentLoaded', function () {
                                           validarSoloLetras(document.getElementById('nombres'));
                                           validarSoloLetras(document.getElementById('apellidos'));
                                           validarSoloNumeros(document.getElementById('telefono'));
                                           validarSoloNumeros(document.getElementById('cedula'));
                                           validarUsuario(document.getElementById('username'));
                                       });
        </script>
    </body>
</html>
