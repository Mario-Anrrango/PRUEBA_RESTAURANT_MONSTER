/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */


function validarFormulario(evento) {
    const cedulaEl = document.getElementById('cedula');
    if (cedulaEl) {
        if (!validarCedulaEcuatoriana(cedulaEl.value.trim())) {
            alert('Error: Por favor, ingrese una cédula ecuatoriana válida.');
            evento.preventDefault();
            return false;
        }
    }

    const telefonoEl = document.getElementById('telefono');
    if (telefonoEl && telefonoEl.value.trim()) {
        const regexTelefono = /^0\d{9}$/;
        if (!regexTelefono.test(telefonoEl.value.trim())) {
            alert('Error: El teléfono debe tener 10 dígitos y empezar con 0.');
            evento.preventDefault();
            return false;
        }
    }

    const correoEl = document.getElementById('correo');
    if (correoEl && correoEl.value.trim()) {
        const regexCorreo = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!regexCorreo.test(correoEl.value.trim())) {
            alert('Error: Por favor, ingrese un correo electrónico válido.');
            evento.preventDefault();
            return false;
        }
    }

    return true;
}

function validarCedulaEcuatoriana(cedula) {
    if (cedula.length !== 10 || !/^\d+$/.test(cedula)) return false;

    const digitoRegion = parseInt(cedula.substring(0, 2), 10);
    if (digitoRegion < 1 || digitoRegion > 24) return false;

    const tercerDigito = parseInt(cedula.substring(2, 3), 10);
    if (tercerDigito < 0 || tercerDigito > 5) return false;

    let suma = 0;
    for (let i = 0; i < 9; i++) {
        let valor = parseInt(cedula.charAt(i), 10);
        if (i % 2 === 0) {
            valor = valor * 2;
            if (valor > 9) valor -= 9;
        }
        suma += valor;
    }

    const digitoVerificadorEsperado = parseInt(cedula.charAt(9), 10);
    let decenaSuperior = Math.ceil(suma / 10) * 10;
    let resultado = decenaSuperior - suma;
    if (resultado === 10) resultado = 0;

    return resultado === digitoVerificadorEsperado;
}

function permitirSoloLetras(input) {
    input.value = input.value.replace(/[^a-zA-ZáéíóúÁÉÍÓÚñÑ\s]/g, '');
}

function bloquearTecladoNumerico(evento) {
    const tecla = evento.key;

    if (tecla.length === 1) {
        const regexLetras = /^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/;
        
        if (!regexLetras.test(tecla)) {
            evento.preventDefault();
        }
    }
}

function bloquearTecladoAlfabetico(evento) {
    // Obtenemos la tecla presionada
    const tecla = evento.key;

    // Evaluamos solo los caracteres imprimibles (dejamos pasar Backspace, Tab, etc.)
    if (tecla.length === 1) {
        // La expresión regular solo permite números del 0 al 9
        const regexNumeros = /^[0-9]+$/;
        
        if (!regexNumeros.test(tecla)) {
            // Si teclean una letra, espacio o símbolo, bloqueamos el teclado
            evento.preventDefault();
        }
    }
}

function bloquearCaracteresCorreo(evento) {
    // Obtenemos la tecla presionada
    const tecla = evento.key;

    if (tecla.length === 1) {
        // La expresión regular permite: letras (sin tildes), números, arroba, punto, guion medio y guion bajo
        const regexCorreo = /^[a-zA-Z0-9@.\-_]+$/;

        if (!regexCorreo.test(tecla)) {
            // Si intentan teclear un espacio, una tilde o un símbolo inválido, lo bloqueamos
            evento.preventDefault();
        }
    }
}

function permitirSoloNumeros(input, maxLen) {
    input.value = input.value.replace(/\D/g, '');
    if (maxLen && input.value.length > maxLen) {
        input.value = input.value.slice(0, maxLen);
    }
}