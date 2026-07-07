package ec.edu.monster.restaurante.controlador;

import ec.edu.monster.restaurante.dao.*;
import ec.edu.monster.restaurante.modelo.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.*;

@WebServlet("/empleado/tomar-pedido")
public class TomarPedidoServlet extends HttpServlet {

    private static final BigDecimal IVA_PCT      = new BigDecimal("0.15");
    private static final BigDecimal SERVICIO_PCT = new BigDecimal("0.10");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null || !"EMPLEADO".equals(usuario.getPerfil())) {
            resp.sendRedirect(req.getContextPath() + "/login"); return;
        }

        String idCliente = req.getParameter("idCliente");
        if (idCliente == null) { resp.sendRedirect(req.getContextPath() + "/empleado"); return; }
        Cliente cliente = new ClienteDAO().buscarPorId(idCliente);
        if (cliente == null) { resp.sendRedirect(req.getContextPath() + "/empleado"); return; }

        // FASE 6.19: Manejar modificación de pedido existente
        String modificarId = req.getParameter("modificar");
        List<DetallePedido> detallesPedido = null;
        boolean modoEdicion = false;
        
        if (modificarId != null && !modificarId.isEmpty()) {
            PedidoDAO pedidoDAO = new PedidoDAO();
            Pedido pedido = pedidoDAO.buscarPorId(modificarId);
            
            if (pedido != null && "PENDIENTE".equals(pedido.getEstado())) {
                detallesPedido = pedido.getDetalles();
                modoEdicion = true;
                // Guardar en sesión para que doPost() lo use al actualizar
                session.setAttribute("pedidoModificando", pedido);
                req.setAttribute("detallesPedido", detallesPedido);
                req.setAttribute("modoEdicion", true);
                req.setAttribute("modificarId", modificarId);
            }
        }

        List<Categoria> categorias = new CategoriaDAO().listar();
        PlatoDAO pDao = new PlatoDAO();
        Map<String, List<Plato>> platosPorCategoria = new LinkedHashMap<>();
        for (Categoria cat : categorias) {
            platosPorCategoria.put(cat.getId(), pDao.listarPorCategoria(cat.getId()));
        }

        // FASE 6.22: Agregar platos INACTIVOS del pedido original + detectar inactivos
        boolean hayInactivos = false;
        if (modoEdicion && detallesPedido != null) {
            for (DetallePedido det : detallesPedido) {
                // Verificar estado actual en BD (el detalle.isActivoEnBD() siempre es true por defecto)
                Plato platoActual = pDao.buscarPorId(det.getIdPlato());
                if (platoActual != null && !platoActual.isActivo()) {
                    // Marcar como inactivo en el detalle para que doPost() y JSP lo manejen correctamente
                    det.setActivoEnBD(false);
                    hayInactivos = true;
                    String catId = platoActual.getIdCategoria();
                    if (catId == null) catId = "";
                    platosPorCategoria.computeIfAbsent(catId, k -> new ArrayList<>()).add(platoActual);
                }
            }
        }
        req.setAttribute("hayPlatosInactivos", hayInactivos);

        req.setAttribute("clienteSeleccionado", cliente);
        req.setAttribute("categorias", categorias);
        req.setAttribute("platosPorCategoria", platosPorCategoria);
        req.getRequestDispatcher("/vistas/empleado/tomar-pedido.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        if (session == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null || !"EMPLEADO".equals(usuario.getPerfil())) {
            resp.sendRedirect(req.getContextPath() + "/login"); return;
        }

        Empleado empleado = (Empleado) session.getAttribute("empleado");
        String idCliente = req.getParameter("idCliente");

        String[] platosSeleccionados = req.getParameterValues("platos");
        String[] platosInactivos = req.getParameterValues("platos_inactivos");
        
        if ((platosSeleccionados == null || platosSeleccionados.length == 0) &&
            (platosInactivos == null || platosInactivos.length == 0)) {
            resp.sendRedirect(req.getContextPath() + "/empleado/tomar-pedido?idCliente=" + idCliente + "&error=vacio");
            return;
        }

        // FASE 6.19: Verificar si es modificación de pedido existente
        Pedido pedidoModificando = (Pedido) session.getAttribute("pedidoModificando");
        
        PlatoDAO platoDao = new PlatoDAO();
        List<DetallePedido> detalles = new ArrayList<>();
        BigDecimal subtotal = BigDecimal.ZERO;

        // Procesar platos ACTIVOS seleccionados
        if (platosSeleccionados != null) {
            for (String idPlatoStr : platosSeleccionados) {
                String cantStr = req.getParameter("cantidad_" + idPlatoStr);
                int cantidad = (cantStr != null && !cantStr.isEmpty()) ? Integer.parseInt(cantStr) : 1;
                if (cantidad < 1) cantidad = 1;

                Plato plato = platoDao.buscarPorId(idPlatoStr);
                if (plato != null) {
                    DetallePedido d = new DetallePedido();
                    d.setIdPlato(idPlatoStr);
                    d.setNombrePlato(plato.getNombre());
                    d.setCategoriaPlato(plato.getNombreCategoria());
                    d.setCantidad(cantidad);
                    d.setPrecioUnitario(plato.getPrecio());
                    d.setActivoEnBD(true);
                    detalles.add(d);
                    subtotal = subtotal.add(plato.getPrecio().multiply(BigDecimal.valueOf(cantidad)));
                }
            }
        }

        // Mantener platos INACTIVOS del pedido original
        if (pedidoModificando != null && pedidoModificando.getDetalles() != null) {
            for (DetallePedido detOriginal : pedidoModificando.getDetalles()) {
                if (!detOriginal.isActivoEnBD()) {
                    // Mantener el detalle original completo (incluyendo precio del momento)
                    detalles.add(detOriginal);
                    subtotal = subtotal.add(detOriginal.getSubtotalLinea());
                }
            }
        }

        BigDecimal iva      = subtotal.multiply(IVA_PCT);
        BigDecimal servicio = subtotal.multiply(SERVICIO_PCT);
        BigDecimal total    = subtotal.add(iva).add(servicio);

        PedidoDAO pDao = new PedidoDAO();
        
        if (pedidoModificando != null) {
            // ACTUALIZAR pedido existente
            pedidoModificando.setDetalles(detalles);
            pedidoModificando.setSubtotal(subtotal);
            pedidoModificando.setIva(iva);
            pedidoModificando.setServicio(servicio);
            pedidoModificando.setTotal(total);
            
            pDao.actualizarTodo(pedidoModificando);
            session.removeAttribute("pedidoModificando");
            
            session.setAttribute("mensaje", "Pedido actualizado correctamente");
            session.setAttribute("tipoMensaje", "success");
            // FASE 6.21: Guardar idCliente en sesión para que factura tenga link de vuelta
            session.setAttribute("clienteFacturaId", idCliente);
            resp.sendRedirect(req.getContextPath() + "/factura?id=" + pedidoModificando.getId());
        } else {
            // CREAR nuevo pedido
            Pedido pedido = new Pedido();
            pedido.setIdCliente(idCliente);
            if (empleado != null) pedido.setIdEmpleado(empleado.getId());
            pedido.setFecha(LocalDate.now());
            pedido.setHora(LocalTime.now());
            pedido.setSubtotal(subtotal);
            pedido.setIva(iva);
            pedido.setServicio(servicio);
            pedido.setTotal(total);
            pedido.setDetalles(detalles);

            String idPedido = pDao.insertar(pedido);
            // FASE 6.21: Guardar idCliente en sesión para que factura tenga link de vuelta
            session.setAttribute("clienteFacturaId", idCliente);
            session.setAttribute("mensaje", "Pedido creado exitosamente");
            session.setAttribute("tipoMensaje", "success");
            resp.sendRedirect(req.getContextPath() + "/factura?id=" + idPedido);
        }
    }
}
