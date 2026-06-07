/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */


function validarFormulario(evento) {
    const cedula = document.getElementById('cedula').value.trim();
    const telefono = document.getElementById('telefono').value.trim();
    const correo = document.getElementById('correo').value.trim();

    if (!validarCedulaEcuatoriana(cedula)) {
        alert('Error: Por favor, ingrese una cédula ecuatoriana válida.');
        evento.preventDefault();
        return false;
    }

    const regexTelefono = /^0\d{9}$/;
    if (!regexTelefono.test(telefono)) {
        alert('Error: El número de teléfono debe tener 10 dígitos y empezar con 0.');
        evento.preventDefault();
        return false;
    }

    const regexCorreo = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!regexCorreo.test(correo)) {
        alert('Error: Por favor, ingrese un formato de correo electrónico válido.');
        evento.preventDefault();
        return false;
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