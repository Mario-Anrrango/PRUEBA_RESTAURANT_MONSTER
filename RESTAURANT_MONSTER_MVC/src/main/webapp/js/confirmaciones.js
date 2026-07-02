// =========================================================
// CONFIRMACIONES CON SWEETALERT - Restaurant Master Monster
// =========================================================

/* ---- PLATOS ---- */

function confirmarActivarPlato(id, nombre) {
    Swal.fire({
        title: '¿Activar plato?',
        text: 'El plato "' + nombre + '" estará visible para los clientes',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#28a745',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Sí, activar',
        cancelButtonText: 'Cancelar'
    }).then((result) => {
        if (result.isConfirmed) {
            window.location.href = contextPath + '/admin?accion=activarPlato&id=' + id + '&activo=true';
        }
    });
}

function confirmarDesactivarPlato(id, nombre) {
    Swal.fire({
        title: '¿Desactivar plato?',
        text: 'El plato "' + nombre + '" no estará disponible para los clientes',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#dc3545',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Sí, desactivar',
        cancelButtonText: 'Cancelar'
    }).then((result) => {
        if (result.isConfirmed) {
            window.location.href = contextPath + '/admin?accion=eliminarPlato&id=' + id;
        }
    });
}

function confirmarEditarPlato(nombre) {
    return true;
}

/* ---- CLIENTES ---- */

function confirmarEditarCliente(id) {
    window.location.href = contextPath + '/admin?accion=editarCliente&id=' + id;
}

function confirmarActivarCliente(id, nombre) {
    Swal.fire({
        title: '¿Activar cliente?',
        text: nombre + ' podrá acceder al sistema nuevamente',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#28a745',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Sí, activar',
        cancelButtonText: 'Cancelar'
    }).then((result) => {
        if (result.isConfirmed) {
            window.location.href = contextPath + '/admin?accion=activarCliente&id=' + id;
        }
    });
}

function confirmarDesactivarCliente(id, nombre) {
    Swal.fire({
        title: '¿Desactivar cliente?',
        text: nombre + ' no podrá acceder al sistema',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#dc3545',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Sí, desactivar',
        cancelButtonText: 'Cancelar'
    }).then((result) => {
        if (result.isConfirmed) {
            window.location.href = contextPath + '/admin?accion=desactivarCliente&id=' + id;
        }
    });
}

function confirmarResetPassword(idUsuario, nombre, perfil) {
    Swal.fire({
        title: '¿Resetear contraseña?',
        text: 'Se cambiará la contraseña de ' + nombre,
        icon: 'question',
        input: 'password',
        inputLabel: 'Nueva contraseña',
        inputPlaceholder: 'Ingrese la nueva contraseña',
        inputAttributes: { minlength: 8 },
        showCancelButton: true,
        confirmButtonColor: '#e67e22',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Sí, resetear',
        cancelButtonText: 'Cancelar',
        preConfirm: (password) => {
            if (!password || password.length < 8) {
                Swal.showValidationMessage('La contraseña debe tener al menos 8 caracteres');
            }
        }
    }).then((result) => {
        if (result.isConfirmed && result.value) {
            var form = document.createElement('form');
            form.method = 'POST';
            form.action = contextPath + '/admin';
            form.innerHTML = '<input type="hidden" name="accion" value="resetPassword">' +
                '<input type="hidden" name="id" value="' + idUsuario + '">' +
                '<input type="hidden" name="perfil" value="' + perfil + '">' +
                '<input type="hidden" name="newPassword" value="' + result.value + '">';
            document.body.appendChild(form);
            form.submit();
        }
    });
}

/* ---- EMPLEADOS ---- */

function confirmarEditarEmpleado(id) {
    window.location.href = contextPath + '/admin?accion=editarEmpleado&id=' + id;
}

function confirmarActivarEmpleado(id, nombre) {
    Swal.fire({
        title: '¿Activar empleado?',
        text: nombre + ' podrá acceder al sistema',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#28a745',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Sí, activar',
        cancelButtonText: 'Cancelar'
    }).then((result) => {
        if (result.isConfirmed) {
            window.location.href = contextPath + '/admin?accion=activarEmpleado&id=' + id;
        }
    });
}

function confirmarDesactivarEmpleado(id, nombre) {
    Swal.fire({
        title: '¿Desactivar empleado?',
        text: nombre + ' no podrá acceder al sistema',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#dc3545',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Sí, desactivar',
        cancelButtonText: 'Cancelar'
    }).then((result) => {
        if (result.isConfirmed) {
            window.location.href = contextPath + '/admin?accion=desactivarEmpleado&id=' + id;
        }
    });
}

/* ---- PEDIDOS ---- */

function confirmarPago() {
    Swal.fire({
        title: '¿Confirmar pago?',
        text: 'El pedido se marcará como pagado',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#27ae60',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Sí, pagar',
        cancelButtonText: 'Cancelar'
    }).then((result) => {
        if (result.isConfirmed) {
            document.getElementById('formPagar').submit();
        }
    });
}

function confirmarCancelar(idPedido) {
    Swal.fire({
        title: '¿Cancelar este pedido?',
        text: 'Esta acción no se puede deshacer',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#dc3545',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Sí, cancelar',
        cancelButtonText: 'Volver'
    }).then((result) => {
        if (result.isConfirmed) {
            window.location.href = contextPath + '/reservas?accion=cancelar&id=' + idPedido;
        }
    });
}
