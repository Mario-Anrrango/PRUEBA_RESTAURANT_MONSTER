// =========================================================
// VALIDACIONES EN TIEMPO REAL - Restaurant Master Monster
// =========================================================

console.log("✅ validaciones.js cargado correctamente");

// ----- Helper: mostrar error en un message div específico -----
function mostrarError(input, msgId, mensaje) {
    var msgDiv = document.getElementById(msgId);
    if (!msgDiv) return;
    msgDiv.textContent = mensaje;
    msgDiv.className = 'validation-message error';
    input.style.borderColor = '#dc3545';
}

function mostrarExito(input, msgId, mensaje) {
    var msgDiv = document.getElementById(msgId);
    if (!msgDiv) return;
    msgDiv.textContent = mensaje || '';
    msgDiv.className = 'validation-message success';
    input.style.borderColor = '#28a745';
}

function limpiarError(input, msgId) {
    var msgDiv = document.getElementById(msgId);
    if (msgDiv) {
        msgDiv.textContent = '';
        msgDiv.className = 'validation-message';
    }
    input.style.borderColor = '';
}

// ----- Solo letras (con tildes y ñ) -----
function validarSoloLetras(input) {
    input.addEventListener('input', function(e) {
        this.value = this.value.replace(/[^a-zA-ZáéíóúÁÉÍÓÚñÑ\s]/g, '');
        if (this.value.length > 50) this.value = this.value.substring(0, 50);
    });
}

// ----- Solo números -----
function validarSoloNumeros(input) {
    input.addEventListener('input', function(e) {
        this.value = this.value.replace(/[^0-9]/g, '');
    });
}

// ----- Números y punto decimal (precios) -----
function validarDecimal(input) {
    input.addEventListener('input', function(e) {
        this.value = this.value.replace(/[^0-9.]/g, '');
        var partes = this.value.split('.');
        if (partes.length > 2) this.value = partes[0] + '.' + partes[1];
        if (partes[0].length > 2) this.value = partes[0].substring(0, 2) + (partes[1] ? '.' + partes[1] : '');
        if (partes[1] && partes[1].length > 2) this.value = partes[0] + '.' + partes[1].substring(0, 2);
    });
    input.addEventListener('blur', function(e) {
        var valor = parseFloat(this.value);
        if (this.value && (isNaN(valor) || valor <= 0)) {
            mostrarError(this, 'error-' + this.id, 'Debe ser mayor a 0');
        } else if (valor > 99.99) {
            mostrarError(this, 'error-' + this.id, 'Máximo 99.99');
        } else {
            limpiarError(this, 'error-' + this.id);
        }
    });
}

// ----- Validar longitud -----
function validarLongitud(input, min, max) {
    input.addEventListener('input', function(e) {
        if (this.value.length > max) this.value = this.value.substring(0, max);
    });
}



// ----- Cédula ecuatoriana (módulo 10) -----
function validarCedulaEcuatoriana(cedula) {
    if (!cedula || cedula.length !== 10) return false;
    var coeficientes = [2, 1, 2, 1, 2, 1, 2, 1, 2];
    var suma = 0;
    for (var i = 0; i < 9; i++) {
        var producto = parseInt(cedula[i]) * coeficientes[i];
        if (producto > 9) producto -= 9;
        suma += producto;
    }
    var digitoVerificador = (10 - (suma % 10)) % 10;
    return parseInt(cedula[9]) === digitoVerificador;
}

// ----- Validar usuario -----
function validarUsuario(input) {
    input.addEventListener('input', function(e) {
        this.value = this.value.replace(/[^a-zA-Z0-9_]/g, '');
        this.value = this.value.replace(/\s/g, '');
    });
}

// =========================================================
// VALIDACIONES ON BLUR - Registro Cliente
// =========================================================

function validarNombresOnBlur() {
    var input = document.getElementById('nombres');
    var msgId = 'nombres-message';
    var valor = input.value.trim();
    if (valor.length === 0) { mostrarError(input, msgId, 'Campo obligatorio'); return false; }
    if (valor.length < 4) { mostrarError(input, msgId, 'Mínimo 4 caracteres'); return false; }
    if (/[^a-zA-ZáéíóúÁÉÍÓÚñÑ\s]/.test(valor)) { mostrarError(input, msgId, 'Solo se permiten letras'); return false; }
    mostrarExito(input, msgId, '');
    return true;
}

function validarApellidosOnBlur() {
    var input = document.getElementById('apellidos');
    var msgId = 'apellidos-message';
    var valor = input.value.trim();
    if (valor.length === 0) { mostrarError(input, msgId, 'Campo obligatorio'); return false; }
    if (valor.length < 4) { mostrarError(input, msgId, 'Mínimo 4 caracteres'); return false; }
    if (/[^a-zA-ZáéíóúÁÉÍÓÚñÑ\s]/.test(valor)) { mostrarError(input, msgId, 'Solo se permiten letras'); return false; }
    mostrarExito(input, msgId, '');
    return true;
}

function validarCedulaOnBlur() {
    var input = document.getElementById('cedula');
    var msgId = 'cedula-message';
    if (input.disabled) { limpiarError(input, msgId); return true; }
    var valor = input.value.trim();

    if (valor.length === 0) { mostrarError(input, msgId, 'Campo obligatorio'); return false; }
    if (valor.length < 10) { mostrarError(input, msgId, 'La cédula debe tener 10 dígitos'); return false; }
    if (valor.length > 10) { mostrarError(input, msgId, 'La cédula debe tener exactamente 10 dígitos'); return false; }
    if (!validarCedulaEcuatoriana(valor)) { mostrarError(input, msgId, 'Cédula inválida'); return false; }

    // AJAX - verificar si existe en BD
    var xhr = new XMLHttpRequest();
    xhr.open('GET', contextPath + '/registro?accion=validarCedula&cedula=' + encodeURIComponent(valor), true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            if (xhr.status === 200) {
                try {
                    var respuesta = JSON.parse(xhr.responseText);
                    if (respuesta.valid) {
                        mostrarExito(input, msgId, 'Cédula válida');
                    } else {
                        mostrarError(input, msgId, respuesta.message);
                    }
                } catch(e) {
                    mostrarError(input, msgId, 'Error al validar');
                }
            } else {
                mostrarError(input, msgId, 'Error de conexión');
            }
        }
    };
    xhr.send();
    return true;
}

function validarIdentificacionOnBlur() {
    var input = document.getElementById('identificacionExtranjera');
    var msgId = 'identificacion-message';
    if (input.disabled) { limpiarError(input, msgId); return true; }
    var valor = input.value.trim();

    if (valor.length === 0) { mostrarError(input, msgId, 'Campo obligatorio'); return false; }
    if (valor.length < 5) { mostrarError(input, msgId, 'Mínimo 5 caracteres'); return false; }
    if (valor.length > 20) { mostrarError(input, msgId, 'Máximo 20 caracteres'); return false; }

    // AJAX
    var xhr = new XMLHttpRequest();
    xhr.open('GET', contextPath + '/registro?accion=validarIdentificacion&id=' + encodeURIComponent(valor), true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            try {
                var respuesta = JSON.parse(xhr.responseText);
                if (respuesta.valid) {
                    mostrarExito(input, msgId, '');
                } else {
                    mostrarError(input, msgId, respuesta.message);
                }
            } catch(e) {}
        }
    };
    xhr.send();
    return true;
}

function validarTelefonoOnBlur() {
    var input = document.getElementById('telefono');
    var msgId = 'telefono-message';
    var valor = input.value.trim();
    if (valor.length === 0) { mostrarError(input, msgId, 'Campo obligatorio'); return false; }
    if (!/^\d+$/.test(valor)) { mostrarError(input, msgId, 'Solo se permiten números'); return false; }
    if (valor.length !== 10) { mostrarError(input, msgId, 'Debe tener exactamente 10 dígitos'); return false; }
    mostrarExito(input, msgId, '');
    return true;
}

function validarCorreoOnBlur() {
    var input = document.getElementById('correo');
    var msgId = 'correo-message';
    var valor = input.value.trim();

    if (valor.length === 0) { mostrarError(input, msgId, 'El correo es obligatorio'); return false; }

    // Validar que haya EXACTAMENTE un @
    var partes = valor.split('@');
    if (partes.length !== 2) {
        mostrarError(input, msgId, 'El correo debe contener exactamente un @');
        return false;
    }

    var usuario = partes[0];
    var dominio = partes[1];

    // No puede comenzar con @
    if (valor.startsWith('@')) {
        mostrarError(input, msgId, 'El correo no puede comenzar con @');
        return false;
    }

    // No puede terminar con @
    if (valor.endsWith('@')) {
        mostrarError(input, msgId, 'El correo no puede terminar con @');
        return false;
    }

    // Mínimo 4 caracteres antes del @
    if (usuario.length < 4) {
        mostrarError(input, msgId, 'Debe tener mínimo 4 caracteres antes del @');
        return false;
    }

    // Debe haber al menos un punto después del @
    if (!dominio.includes('.')) {
        mostrarError(input, msgId, 'El dominio debe contener al menos un punto (ej: gmail.com)');
        return false;
    }

    // No puede terminar en punto
    if (valor.endsWith('.')) {
        mostrarError(input, msgId, 'El correo no puede terminar en punto');
        return false;
    }

    // Punto justo después de @ no está permitido
    if (dominio.startsWith('.')) {
        mostrarError(input, msgId, 'El dominio no puede comenzar con punto');
        return false;
    }

    // Regex final para formato válido
    var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(valor)) {
        mostrarError(input, msgId, 'Formato de correo inválido');
        return false;
    }

    // AJAX - verificar si ya existe en BD
    var xhr = new XMLHttpRequest();
    xhr.open('GET', contextPath + '/registro?accion=validarCorreo&correo=' + encodeURIComponent(valor), true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            try {
                var respuesta = JSON.parse(xhr.responseText);
                if (!respuesta.valid) {
                    mostrarError(input, msgId, respuesta.message);
                } else {
                    mostrarExito(input, msgId, 'Correo válido');
                }
            } catch(e) {}
        }
    };
    xhr.send();
    return true;
}

function validarDireccionOnBlur() {
    var input = document.getElementById('direccion');
    var msgId = 'direccion-message';
    var valor = input.value.trim();
    if (valor.length === 0) { mostrarError(input, msgId, 'Campo obligatorio'); return false; }
    if (valor.length < 10) { mostrarError(input, msgId, 'Mínimo 10 caracteres'); return false; }
    if (valor.length > 200) { mostrarError(input, msgId, 'Máximo 200 caracteres'); return false; }
    mostrarExito(input, msgId, '');
    return true;
}

function validarUsuarioOnBlur() {
    var input = document.getElementById('username');
    var msgId = 'username-message';
    var valor = input.value.trim();
    if (valor.length === 0) { mostrarError(input, msgId, 'Campo obligatorio'); return false; }
    if (valor.length < 4) { mostrarError(input, msgId, 'Mínimo 4 caracteres'); return false; }
    if (valor.includes(' ')) { mostrarError(input, msgId, 'No se permiten espacios'); return false; }

    // AJAX
    var xhr = new XMLHttpRequest();
    xhr.open('GET', contextPath + '/registro?accion=validarUsuario&usuario=' + encodeURIComponent(valor), true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            try {
                var respuesta = JSON.parse(xhr.responseText);
                if (!respuesta.valid) {
                    mostrarError(input, msgId, respuesta.message);
                } else {
                    mostrarExito(input, msgId, '');
                }
            } catch(e) {}
        }
    };
    xhr.send();
    return true;
}

function validarContrasenaOnBlur() {
    var input = document.getElementById('contrasena');
    var msgId = 'contrasena-message';
    var valor = input.value;
    if (valor.length === 0) { mostrarError(input, msgId, 'Campo obligatorio'); return false; }
    if (valor.length < 8) { mostrarError(input, msgId, 'Mínimo 8 caracteres'); return false; }
    if (!/[A-Z]/.test(valor)) { mostrarError(input, msgId, 'Debe tener al menos una mayúscula'); return false; }
    if (!/[!@#$%^&*(),.?":{}|<>]/.test(valor)) { mostrarError(input, msgId, 'Debe tener al menos un carácter especial'); return false; }
    mostrarExito(input, msgId, '');
    return true;
}

function validarConfirmacionOnBlur() {
    var password = document.getElementById('contrasena');
    var confirm = document.getElementById('confirmPassword');
    var msgId = 'confirmPassword-message';
    var valor = confirm.value;
    if (valor.length === 0) { mostrarError(confirm, msgId, 'Campo obligatorio'); return false; }
    if (password.value !== valor) { mostrarError(confirm, msgId, 'Las contraseñas no coinciden'); return false; }
    mostrarExito(confirm, msgId, '');
    return true;
}

// ----- Toggle password visibility -----
function togglePasswordVisibility(inputId) {
    var input = document.getElementById(inputId);
    if (!input) return;
    var btn = document.querySelector('.password-toggle[data-target="' + inputId + '"]');
    if (input.type === 'password') {
        input.type = 'text';
        if (btn) btn.textContent = '🙈';
    } else {
        input.type = 'password';
        if (btn) btn.textContent = '👁️';
    }
}

// ----- Contador de caracteres -----
function actualizarContador(textarea, maximo) {
    var counter = document.getElementById('charCounter');
    if (!counter) {
        counter = document.createElement('div');
        counter.id = 'charCounter';
        counter.className = 'char-counter';
        textarea.parentNode.appendChild(counter);
    }
    var len = textarea.value.length;
    counter.textContent = len + '/' + maximo + ' caracteres';
    counter.className = 'char-counter';
    if (len > maximo * 0.85) counter.classList.add('warning');
    if (len >= maximo) counter.classList.add('danger');
}

// ----- Alternar identificación (para admin/empleado forms) -----
function alternarIdentificacion(checkbox, cedulaInput, extranjeroInput) {
    checkbox.addEventListener('change', function() {
        if (this.checked) {
            cedulaInput.disabled = true; cedulaInput.value = ''; cedulaInput.required = false;
            extranjeroInput.disabled = false; extranjeroInput.required = true;
            extranjeroInput.parentElement.style.display = 'block';
            document.getElementById('grupo-cedula').style.display = 'none';
        } else {
            cedulaInput.disabled = false; cedulaInput.required = true;
            extranjeroInput.disabled = true; extranjeroInput.value = ''; extranjeroInput.required = false;
            extranjeroInput.parentElement.style.display = 'none';
            document.getElementById('grupo-cedula').style.display = 'block';
        }
    });
}

// =========================================================
// VALIDACIÓN PREVIA AL ENVÍO
// =========================================================

function validarFormularioRegistro(form) {
    // Ejecutar validaciones on blur para todos los campos
    validarNombresOnBlur();
    validarApellidosOnBlur();
    validarCedulaOnBlur();
    validarTelefonoOnBlur();
    validarCorreoOnBlur();
    validarDireccionOnBlur();
    validarUsuarioOnBlur();
    validarContrasenaOnBlur();
    validarConfirmacionOnBlur();

    // Recolectar errores
    var errores = [];
    var msgDivs = form.querySelectorAll('.validation-message.error');
    for (var i = 0; i < msgDivs.length; i++) {
        var label = msgDivs[i].previousElementSibling;
        while (label && label.tagName !== 'LABEL') label = label.previousElementSibling;
        var nombreCampo = label ? label.textContent.replace(' *', '') : 'Un campo';
        errores.push(nombreCampo + ': ' + msgDivs[i].textContent);
    }

    var btn = document.getElementById('btnRegistro');
    if (errores.length > 0) {
        if (btn) { btn.disabled = false; btn.textContent = 'Registrarme'; }
        var lista = errores.map(function(e) { return '<li>' + e + '</li>'; }).join('');
        Swal.fire({
            icon: 'error',
            title: 'Errores en el formulario',
            html: '<ul style="text-align:left;font-size:0.9em;margin:0;padding-left:20px;">' + lista + '</ul>',
            confirmButtonColor: '#8b4513',
            confirmButtonText: 'Corregir'
        });
        return false;
    }

    // SweetAlert de confirmación antes de enviar
    Swal.fire({
        title: '¿Confirmar registro?',
        text: 'Está a punto de registrarse como nuevo cliente',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#28a745',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Sí, registrarme',
        cancelButtonText: 'Cancelar',
        allowOutsideClick: false
    }).then(function(result) {
        if (result.isConfirmed) {
            var btn2 = document.getElementById('btnRegistro');
            if (btn2) { btn2.disabled = true; btn2.textContent = 'Registrando...'; }
            form.submit();
        }
    });

    return false; // Siempre return false - el submit se hace en el then(swal)
}

// =========================================================
// EXPORTAR
// =========================================================
window.mostrarError = mostrarError;
window.mostrarExito = mostrarExito;
window.limpiarError = limpiarError;
window.validarSoloLetras = validarSoloLetras;
window.validarSoloNumeros = validarSoloNumeros;
window.validarDecimal = validarDecimal;
window.validarLongitud = validarLongitud;

window.validarCedulaEcuatoriana = validarCedulaEcuatoriana;
window.validarUsuario = validarUsuario;
window.validarNombresOnBlur = validarNombresOnBlur;
window.validarApellidosOnBlur = validarApellidosOnBlur;
window.validarCedulaOnBlur = validarCedulaOnBlur;
window.validarIdentificacionOnBlur = validarIdentificacionOnBlur;
window.validarTelefonoOnBlur = validarTelefonoOnBlur;
window.validarCorreoOnBlur = validarCorreoOnBlur;
window.validarDireccionOnBlur = validarDireccionOnBlur;
window.validarUsuarioOnBlur = validarUsuarioOnBlur;
window.validarContrasenaOnBlur = validarContrasenaOnBlur;
window.validarConfirmacionOnBlur = validarConfirmacionOnBlur;
window.togglePasswordVisibility = togglePasswordVisibility;
window.actualizarContador = actualizarContador;
window.alternarIdentificacion = alternarIdentificacion;
window.validarFormularioRegistro = validarFormularioRegistro;

console.log("✅ Todas las funciones exportadas");
