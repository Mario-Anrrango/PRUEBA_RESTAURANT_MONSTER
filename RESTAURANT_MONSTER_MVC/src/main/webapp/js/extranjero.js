// =========================================================
// TOGGLE EXTRANJERO - Alternar cédula / identificación extranjera
// =========================================================

function toggleExtranjero() {
    var checked = document.getElementById('esExtranjero').checked;
    var cedulaInput = document.getElementById('cedulaInput');
    var extranjeroInput = document.getElementById('extranjeroInput');
    var extranjeroGroup = document.getElementById('extranjeroGroup');

    if (cedulaInput) {
        cedulaInput.disabled = checked;
        cedulaInput.required = !checked;
        if (checked) cedulaInput.value = '';
    }
    if (extranjeroInput) {
        extranjeroInput.disabled = !checked;
        extranjeroInput.required = checked;
        if (!checked) extranjeroInput.value = '';
    }
    if (extranjeroGroup) {
        extranjeroGroup.style.display = checked ? '' : 'none';
    }
}
