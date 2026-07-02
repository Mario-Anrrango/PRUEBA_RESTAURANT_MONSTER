// =========================================================
// TOGGLE EXTRANJERO - Alternar cédula / identificación extranjera
// Oculta/Muestra los grupos completos, no solo deshabilita inputs
// =========================================================

function toggleExtranjero() {
    var esExtranjero = document.getElementById('esExtranjero');
    if (!esExtranjero) return;
    var checked = esExtranjero.checked;

    var grupoCedula = document.getElementById('grupo-cedula');
    var grupoIdent = document.getElementById('grupo-identificacion');
    var inputCedula = document.getElementById('cedula');
    var inputIdent = document.getElementById('identificacionExtranjera');
    var msgCedula = document.getElementById('cedula-message');
    var msgIdent = document.getElementById('identificacion-message');

    if (checked) {
        // EXTRANJERO: ocultar grupo cédula, mostrar grupo identificación
        if (grupoCedula) { grupoCedula.style.display = 'none'; }
        if (grupoIdent) { grupoIdent.style.display = 'block'; }
        if (inputCedula) { inputCedula.disabled = true; inputCedula.value = ''; inputCedula.required = false; }
        if (inputIdent) { inputIdent.disabled = false; inputIdent.required = true; inputIdent.focus(); }
        // Limpiar mensajes
        if (msgCedula) { msgCedula.textContent = ''; msgCedula.className = 'validation-message'; }
        if (inputCedula) inputCedula.style.borderColor = '';
        if (inputIdent) inputIdent.style.borderColor = '';
    } else {
        // NACIONAL: mostrar grupo cédula, ocultar grupo identificación
        if (grupoCedula) { grupoCedula.style.display = 'block'; }
        if (grupoIdent) { grupoIdent.style.display = 'none'; }
        if (inputCedula) { inputCedula.disabled = false; inputCedula.required = true; inputCedula.focus(); }
        if (inputIdent) { inputIdent.disabled = true; inputIdent.value = ''; inputIdent.required = false; }
        // Limpiar mensajes
        if (msgIdent) { msgIdent.textContent = ''; msgIdent.className = 'validation-message'; }
        if (inputIdent) inputIdent.style.borderColor = '';
        if (inputCedula) inputCedula.style.borderColor = '';
    }
}
