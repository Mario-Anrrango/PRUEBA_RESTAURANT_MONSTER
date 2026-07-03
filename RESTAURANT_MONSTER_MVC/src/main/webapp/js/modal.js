// =========================================================
// MODAL - Resetear Contraseña
// =========================================================

function abrirModalReset(id, perfil) {
    document.getElementById('resetUserId').value = id;
    document.getElementById('resetUserPerfil').value = perfil;
    document.getElementById('modalResetPassword').classList.add('visible');
    document.getElementById('newPassword').value = '';
    document.getElementById('confirmPassword').value = '';
    document.getElementById('passwordError').style.display = 'none';
}

function cerrarModal() {
    document.getElementById('modalResetPassword').classList.remove('visible');
}

function validarResetPassword() {
    var pwd = document.getElementById('newPassword').value;
    var conf = document.getElementById('confirmPassword').value;
    if (pwd !== conf) {
        document.getElementById('passwordError').style.display = 'block';
        return false;
    }
    if (pwd.length < 8) {
        Swal.fire({
            icon: 'error',
            title: 'Contraseña inválida',
            text: 'La contraseña debe tener al menos 8 caracteres',
            confirmButtonText: 'Entendido'
        });
        return false;
    }
    if (!/[A-Z]/.test(pwd)) {
        Swal.fire({
            icon: 'error',
            title: 'Contraseña inválida',
            text: 'Debe tener al menos una mayúscula',
            confirmButtonText: 'Entendido'
        });
        return false;
    }
    if (!/[!@#$%^&*(),.?":{}|<>]/.test(pwd)) {
        Swal.fire({
            icon: 'error',
            title: 'Contraseña inválida',
            text: 'Debe tener al menos un carácter especial',
            confirmButtonText: 'Entendido'
        });
        return false;
    }
    return true;
}

// Inicializar validación en tiempo real al cargar
document.addEventListener('DOMContentLoaded', function() {
    var pwdInput = document.getElementById('newPassword');
    var confInput = document.getElementById('confirmPassword');
    if (pwdInput) {
        pwdInput.addEventListener('input', function() {
            if (confInput.value && this.value !== confInput.value) {
                document.getElementById('passwordError').style.display = 'block';
            } else {
                document.getElementById('passwordError').style.display = 'none';
            }
        });
    }
    if (confInput) {
        confInput.addEventListener('input', function() {
            if (pwdInput.value && this.value !== pwdInput.value) {
                document.getElementById('passwordError').style.display = 'block';
            } else {
                document.getElementById('passwordError').style.display = 'none';
            }
        });
    }
});

// Cerrar modal al hacer clic fuera
window.onclick = function(event) {
    var modal = document.getElementById('modalResetPassword');
    if (event.target === modal) cerrarModal();
};
