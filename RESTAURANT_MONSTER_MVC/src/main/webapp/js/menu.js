// =========================================================
// MENÚ - Selección de platos y control de cantidades
// =========================================================

var seleccionados = {};

function toggleCantidad(idPlato, checked, precio) {
    var contador = document.getElementById('contador_' + idPlato);
    var card     = document.getElementById('card_' + idPlato);

    if (checked) {
        contador.style.display = 'flex';
        card.classList.add('seleccionado');
        seleccionados[idPlato] = {
            qty: parseInt(document.getElementById('num_' + idPlato).textContent),
            precio: precio
        };
    } else {
        contador.style.display = 'none';
        card.classList.remove('seleccionado');
        delete seleccionados[idPlato];
    }
    actualizarBarra();
}

function cambiarCantidad(idPlato, delta, precio) {
    var numEl = document.getElementById('num_' + idPlato);
    var qtyEl = document.getElementById('qty_' + idPlato);
    var val = parseInt(numEl.textContent) + delta;
    if (val < 1) val = 1;
    numEl.textContent = val;
    qtyEl.value = val;
    if (seleccionados[idPlato]) seleccionados[idPlato].qty = val;
    actualizarBarra();
}

function actualizarBarra() {
    var ids  = Object.keys(seleccionados);
    var btn  = document.getElementById('btnEnviar');
    var res  = document.getElementById('resumenPedido');
    var tot  = document.getElementById('totalBarra');

    if (ids.length === 0) {
        res.textContent = 'No has seleccionado ningún plato';
        tot.textContent = '$0.00';
        if (btn) btn.disabled = true;
        return;
    }
    var total = 0, items = 0;
    ids.forEach(function(id) {
        total += seleccionados[id].qty * seleccionados[id].precio;
        items += seleccionados[id].qty;
    });
    res.textContent = ids.length + ' plato(s) – ' + items + ' unidad(es)';
    tot.textContent = '$' + total.toFixed(2) + ' (sin impuestos)';
    if (btn) btn.disabled = false;
}
