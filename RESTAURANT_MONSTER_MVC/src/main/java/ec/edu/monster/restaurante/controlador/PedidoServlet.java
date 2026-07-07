package ec.edu.monster.restaurante.controlador;

import ec.edu.monster.restaurante.dao.ClienteDAO;
import ec.edu.monster.restaurante.dao.PedidoDAO;
import ec.edu.monster.restaurante.dao.PlatoDAO;
import ec.edu.monster.restaurante.modelo.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/pedido")
public class PedidoServlet extends HttpServlet {

    private static final BigDecimal IVA_PCT      = new BigDecimal("0.15");
    private static final BigDecimal SERVICIO_PCT = new BigDecimal("0.10");

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (!"CLIENTE".equals(usuario.getPerfil())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Cliente cliente = (Cliente) session.getAttribute("cliente");
        if (cliente == null) {
            cliente = new ClienteDAO().buscarPorIdUsuario(usuario.getId());
            session.setAttribute("cliente", cliente);
        }

        String[] platosSeleccionados = req.getParameterValues("platos");
        String[] platosInactivos = req.getParameterValues("platos_inactivos");
        
        if ((platosSeleccionados == null || platosSeleccionados.length == 0) &&
            (platosInactivos == null || platosInactivos.length == 0)) {
            resp.sendRedirect(req.getContextPath() + "/menu?error=vacio");
            return;
        }

        // FASE 6.6: Verificar si es modificación de pedido existente
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
                if (plato != null && plato.isActivo()) {
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

        // FASE 6.6: MANTENER platos INACTIVOS del pedido original
        if (pedidoModificando != null && pedidoModificando.getDetalles() != null) {
            for (DetallePedido detOriginal : pedidoModificando.getDetalles()) {
                if (!detOriginal.isActivoEnBD()) {
                    // Mantener el detalle original completo (incluyendo precio del momento)
                    detalles.add(detOriginal);
                    subtotal = subtotal.add(detOriginal.getSubtotalLinea());
                }
            }
        }

        BigDecimal iva       = subtotal.multiply(IVA_PCT);
        BigDecimal servicio  = subtotal.multiply(SERVICIO_PCT);
        BigDecimal total     = subtotal.add(iva).add(servicio);

        Pedido pedido = new Pedido();
        pedido.setIdCliente(cliente.getId());
        pedido.setFecha(LocalDate.now());
        pedido.setHora(LocalTime.now());
        pedido.setSubtotal(subtotal);
        pedido.setIva(iva);
        pedido.setServicio(servicio);
        pedido.setTotal(total);
        pedido.setDetalles(detalles);
        
        if (pedidoModificando != null) {
            // ACTUALIZAR pedido existente
            pedidoModificando.setDetalles(detalles);
            pedidoModificando.setSubtotal(subtotal);
            pedidoModificando.setIva(iva);
            pedidoModificando.setServicio(servicio);
            pedidoModificando.setTotal(total);
            
            PedidoDAO pDao = new PedidoDAO();
            pDao.actualizarTodo(pedidoModificando);
            session.removeAttribute("pedidoModificando");
            
            session.setAttribute("mensaje", "Pedido actualizado correctamente");
            session.setAttribute("tipoMensaje", "success");
            resp.sendRedirect(req.getContextPath() + "/reservas");
        } else {
            // CREAR nuevo pedido
            PedidoDAO pDao = new PedidoDAO();
            String idPedido = pDao.insertar(pedido);

            if (idPedido == null) {
                resp.sendRedirect(req.getContextPath() + "/menu?error=pedido");
                return;
            }

            session.setAttribute("mensaje", "Pedido creado exitosamente");
            session.setAttribute("tipoMensaje", "success");
            resp.sendRedirect(req.getContextPath() + "/factura?id=" + idPedido);
        }
    }
}
