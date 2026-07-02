// =========================================================
// FORMULARIO PLATO - Preview y contador de caracteres
// =========================================================

function previewImagen(input) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function(e) {
            document.getElementById('previewImg').src = e.target.result;
        };
        reader.readAsDataURL(input.files[0]);
    }
}

function actualizarPreview() {
    var nombre = document.querySelector('input[name="nombre"]');
    var precio = document.querySelector('input[name="precio"]');
    var desc = document.querySelector('textarea[name="descripcion"]');
    var cat = document.querySelector('select[name="idCategoria"]');

    if (nombre) document.getElementById('previewNombre').textContent = nombre.value || 'Nombre del plato';
    if (precio) document.getElementById('previewPrecio').textContent = precio.value || '0.00';
    if (desc) document.getElementById('previewDescripcion').textContent = desc.value || 'Descripción del plato...';
    if (cat && cat.options[cat.selectedIndex]) {
        document.getElementById('previewCategoria').textContent = cat.options[cat.selectedIndex].text;
    }
}

function actualizarContador(textarea, max) {
    var counter = document.getElementById('charCounter');
    var len = textarea.value.length;
    counter.textContent = len + '/' + max + ' caracteres';
    counter.className = 'char-counter';
    if (len > max * 0.85) counter.classList.add('warning');
    if (len >= max) counter.classList.add('danger');
}

document.addEventListener('DOMContentLoaded', function() {
    var desc = document.querySelector('textarea[name="descripcion"]');
    if (desc) actualizarContador(desc, 300);
});
