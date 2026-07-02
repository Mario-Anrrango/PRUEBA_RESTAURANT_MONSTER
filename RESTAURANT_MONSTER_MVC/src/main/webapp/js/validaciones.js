// =========================================================
// VALIDACIONES EN TIEMPO REAL - Restaurant Master Monster
// =========================================================

// Validación de solo letras (con tildes y ñ)
function validarSoloLetras(input) {
    input.addEventListener('input', function(e) {
        this.value = this.value.replace(/[^a-zA-ZáéíóúÁÉÍÓÚñÑ\s]/g, '');
        if (this.value.length > 50) {
            this.value = this.value.substring(0, 50);
        }
    });
    input.addEventListener('blur', function(e) {
        if (this.value.length > 0 && this.value.length < 4) {
            mostrarError(this, 'Mínimo 4 caracteres');
        } else if (this.value.trim() === '' && this.required) {
            mostrarError(this, 'Campo obligatorio');
        } else {
            limpiarError(this);
        }
    });
}

// Validación de solo números
function validarSoloNumeros(input) {
    input.addEventListener('input', function(e) {
        this.value = this.value.replace(/[^0-9]/g, '');
    });
}

// Validación de números y punto decimal (precios)
function validarDecimal(input) {
    input.addEventListener('input', function(e) {
        this.value = this.value.replace(/[^0-9.]/g, '');
        const partes = this.value.split('.');
        if (partes.length > 2) {
            this.value = partes[0] + '.' + partes[1];
        }
        if (partes[0].length > 2) {
            this.value = partes[0].substring(0, 2) + (partes[1] ? '.' + partes[1] : '');
        }
        if (partes[1] && partes[1].length > 2) {
            this.value = partes[0] + '.' + partes[1].substring(0, 2);
        }
    });
    input.addEventListener('blur', function(e) {
        var valor = parseFloat(this.value);
        if (this.value && (isNaN(valor) || valor <= 0)) {
            mostrarError(this, 'Debe ser mayor a 0');
        } else if (valor > 99.99) {
            mostrarError(this, 'Máximo 99.99');
        } else {
            limpiarError(this);
        }
    });
}

// Validar longitud mínima y máxima
function validarLongitud(input, min, max) {
    input.addEventListener('input', function(e) {
        if (this.value.length > max) {
            this.value = this.value.substring(0, max);
        }
    });
    input.addEventListener('blur', function(e) {
        if (this.value.length > 0 && this.value.length < min) {
            mostrarError(this, 'Mínimo ' + min + ' caracteres');
        } else {
            limpiarError(this);
        }
    });
}

// Validar email
function validarEmail(input) {
    var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    input.addEventListener('blur', function(e) {
        if (this.value && !emailRegex.test(this.value)) {
            mostrarError(this, 'Correo electrónico inválido');
        } else {
            limpiarError(this);
        }
    });
}

// Validar cédula ecuatoriana (módulo 10)
function validarCedula(input) {
    input.addEventListener('input', function(e) {
        this.value = this.value.replace(/[^0-9]/g, '');
        if (this.value.length > 10) {
            this.value = this.value.substring(0, 10);
        }
    });
    input.addEventListener('blur', function(e) {
        if (this.value.length === 10 && !validarCedulaEcuatoriana(this.value)) {
            mostrarError(this, 'Cédula inválida');
        } else if (this.value.length > 0 && this.value.length < 10) {
            mostrarError(this, 'Debe tener 10 dígitos');
        } else {
            limpiarError(this);
        }
    });
}

function validarCedulaEcuatoriana(cedula) {
    if (cedula.length !== 10) return false;
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

// Validar contraseña segura (8+ chars, 1 mayúscula, 1 especial)
function validarContrasena(input) {
    input.addEventListener('blur', function(e) {
        var valor = this.value;
        if (valor.length === 0) { limpiarError(this); return; }
        if (valor.length < 8) {
            mostrarError(this, 'Mínimo 8 caracteres');
            return;
        }
        if (!/[A-Z]/.test(valor)) {
            mostrarError(this, 'Debe tener al menos una mayúscula');
            return;
        }
        if (!/[!@#$%^&*(),.?":{}|<>]/.test(valor)) {
            mostrarError(this, 'Debe tener al menos un carácter especial');
            return;
        }
        limpiarError(this);
    });
}

// Validar confirmación de contraseña
function validarConfirmacionContrasena(inputPassword, inputConfirm) {
    inputConfirm.addEventListener('blur', function(e) {
        if (inputPassword.value !== this.value) {
            mostrarError(this, 'Las contraseñas no coinciden');
        } else {
            limpiarError(this);
        }
    });
}

// Validar usuario (solo letras, números y _)
function validarUsuario(input) {
    input.addEventListener('input', function(e) {
        this.value = this.value.replace(/[^a-zA-Z0-9_]/g, '');
        this.value = this.value.replace(/\s/g, '');
    });
    input.addEventListener('blur', function(e) {
        if (this.value.length > 0 && this.value.length < 4) {
            mostrarError(this, 'Mínimo 4 caracteres');
        } else {
            limpiarError(this);
        }
    });
}

// Validar nombre de plato (solo letras, 4-50)
function validarNombrePlato(input) {
    input.addEventListener('input', function(e) {
        this.value = this.value.replace(/[^a-zA-ZáéíóúÁÉÍÓÚñÑ\s]/g, '');
        if (this.value.length > 50) {
            this.value = this.value.substring(0, 50);
        }
    });
    input.addEventListener('blur', function(e) {
        if (this.value.length < 4) {
            mostrarError(this, 'Mínimo 4 caracteres');
        } else if (this.value.trim() === '') {
            mostrarError(this, 'Campo obligatorio');
        } else {
            limpiarError(this);
        }
    });
}

// Mostrar error debajo del input
function mostrarError(input, mensaje) {
    var errorDiv = input.nextElementSibling;
    if (!errorDiv || !errorDiv.classList.contains('error-message')) {
        errorDiv = document.createElement('div');
        errorDiv.className = 'error-message';
        errorDiv.style.color = '#c0392b';
        errorDiv.style.fontSize = '12px';
        errorDiv.style.marginTop = '4px';
        input.parentNode.insertBefore(errorDiv, input.nextSibling);
    }
    errorDiv.textContent = mensaje;
    input.style.borderColor = '#c0392b';
}

// Limpiar error
function limpiarError(input) {
    var errorDiv = input.nextElementSibling;
    if (errorDiv && errorDiv.classList.contains('error-message')) {
        errorDiv.remove();
    }
    input.style.borderColor = '';
}

// Validar que no esté vacío
function validarObligatorio(input) {
    input.addEventListener('blur', function(e) {
        if (this.value.trim() === '') {
            mostrarError(this, 'Campo obligatorio');
        } else {
            limpiarError(this);
        }
    });
}

// Alternar entre cédula nacional e identificación extranjera
function alternarIdentificacion(checkbox, cedulaInput, extranjeroInput) {
    checkbox.addEventListener('change', function() {
        if (this.checked) {
            cedulaInput.disabled = true;
            cedulaInput.value = '';
            cedulaInput.required = false;
            extranjeroInput.disabled = false;
            extranjeroInput.required = true;
            extranjeroInput.parentElement.style.display = 'block';
        } else {
            cedulaInput.disabled = false;
            cedulaInput.required = true;
            extranjeroInput.disabled = true;
            extranjeroInput.value = '';
            extranjeroInput.required = false;
            extranjeroInput.parentElement.style.display = 'none';
        }
    });
}

// Actualizar contador de caracteres
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

// Exportar funciones
window.validarSoloLetras = validarSoloLetras;
window.validarSoloNumeros = validarSoloNumeros;
window.validarDecimal = validarDecimal;
window.validarLongitud = validarLongitud;
window.validarEmail = validarEmail;
window.validarCedula = validarCedula;
window.validarContrasena = validarContrasena;
window.validarConfirmacionContrasena = validarConfirmacionContrasena;
window.validarUsuario = validarUsuario;
window.validarNombrePlato = validarNombrePlato;
window.validarObligatorio = validarObligatorio;
window.mostrarError = mostrarError;
window.limpiarError = limpiarError;
window.alternarIdentificacion = alternarIdentificacion;
window.actualizarContador = actualizarContador;
