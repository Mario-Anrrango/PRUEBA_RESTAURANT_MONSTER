<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="ec.edu.monster.restaurante.modelo.Usuario" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null || !"ADMIN".equals(usuario.getPerfil())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
%>
<!-- Modal Reset Password -->
<div id="modalResetPassword" class="modal" style="display:none;position:fixed;z-index:9999;left:0;top:0;width:100%;height:100%;background:rgba(0,0,0,0.5);align-items:center;justify-content:center;">
    <div style="background:white;border-radius:16px;padding:30px;max-width:450px;width:90%;box-shadow:0 10px 40px rgba(0,0,0,0.3);">
        <h3 style="font-family:'Playfair Display',serif;color:#8b4513;margin-bottom:15px;">Resetear Contraseña</h3>
        <p style="color:#666;margin-bottom:15px;font-size:0.9em;">
            Ingresa la nueva contraseña para este usuario.
        </p>
        <form id="formResetPassword" action="${pageContext.request.contextPath}/admin" method="post">
            <input type="hidden" name="accion" value="resetPassword">
            <input type="hidden" name="id" id="resetUserId">
            <input type="hidden" name="perfil" id="resetUserPerfil">

            <div class="form-grupo">
                <label>Nueva Contraseña *</label>
                <input type="password" name="newPassword" id="newPassword" class="form-control" required minlength="8">
                <small style="color:#888;font-size:0.8em;">Mínimo 8 caracteres, 1 mayúscula y 1 carácter especial</small>
            </div>
            <div class="form-grupo">
                <label>Confirmar Contraseña *</label>
                <input type="password" id="confirmPassword" class="form-control" required minlength="8">
                <div id="passwordError" style="color:#c0392b;font-size:12px;display:none;">Las contraseñas no coinciden</div>
            </div>
            <div style="display:flex;gap:10px;margin-top:10px;">
                <button type="submit" class="btn btn-primario" onclick="return validarResetPassword()">Guardar</button>
                <button type="button" class="btn btn-secundario" onclick="cerrarModal()">Cancelar</button>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="${pageContext.request.contextPath}/js/modal.js"></script>
