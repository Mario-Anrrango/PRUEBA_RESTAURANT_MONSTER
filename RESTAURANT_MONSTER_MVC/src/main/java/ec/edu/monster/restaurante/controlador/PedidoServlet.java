package ec.edu.monster.restaurante.controlador;

import ec.edu.monster.restaurante.dao.ClienteDAO;
import ec.edu.monster.restaurante.dao.PedidoDAO;
import ec.edu.monster.restaurante.dao.PlatoDAO;
import ec.edu.monster.restaurante.modelo.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/pedido")
public class PedidoServlet extends HttpServlet {

    private static final double IVA_PCT      = 0.15;
    private static final double SERVICIO_PCT = 0.10;

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

        // Obtener cliente de la sesión
        Cliente cliente = (Cliente) session.getAttribute("cliente");
        if (cliente == null) {
            cliente = new ClienteDAO().buscarPorIdUsuario(usuario.getId());
            session.setAttribute("cliente", cliente);
        }

        // Recoger los platos seleccionados: los checkboxes envían plato_<id>
        String[] platosSeleccionados = req.getParameterValues("platos");
        if (platosSeleccionados == null || platosSeleccionados.length == 0) {
            resp.sendRedirect(req.getContextPath() + "/menu?error=vacio");
            return;
        }

        PlatoDAO platoDao = new PlatoDAO();
        List<DetallePedido> detalles = new ArrayList<>();
        double subtotal = 0;

        for (String idPlatoStr : platosSeleccionados) {
            int idPlato = Integer.parseInt(idPlatoStr);
            String cantStr = req.getParameter("cantidad_" + idPlato);
            int cantidad = (cantStr != null && !cantStr.isEmpty()) ? Integer.parseInt(cantStr) : 1;
            if (cantidad < 1) cantidad = 1;

            Plato plato = platoDao.buscarPorId(idPlato);
            if (plato != null) {
                DetallePedido d = new DetallePedido();
                d.setIdPlato(idPlato);
                d.setNombrePlato(plato.getNombre());
                d.setCategoriaPlato(plato.getNombreCategoria());
                d.setCantidad(cantidad);
                d.setPrecioUnitario(plato.getPrecio());
                detalles.add(d);
                subtotal += plato.getPrecio() * cantidad;
            }
        }

        PedidoDAO pDao = new PedidoDAO();
        int idPedido;

        // Si hay pedido pendiente, agregar los nuevos ítems a ese pedido
        String idPendienteStr = req.getParameter("idPedidoPendiente");
        if (idPendienteStr != null && !idPendienteStr.isEmpty()) {
            idPedido = Integer.parseInt(idPendienteStr);
            Pedido existente = pDao.buscarPorId(idPedido);
            if (existente != null && "PENDIENTE".equals(existente.getEstado())
                    && existente.getIdCliente() == cliente.getId()) {
                double nuevaSubtotal = existente.getSubtotal() + subtotal;
                double nuevaIva      = nuevaSubtotal * IVA_PCT;
                double nuevoServicio = nuevaSubtotal * SERVICIO_PCT;
                double nuevoTotal    = nuevaSubtotal + nuevaIva + nuevoServicio;
                for (DetallePedido d : detalles) {
                    d.setIdPedido(idPedido);
                    pDao.insertarDetalle(d);
                }
                pDao.actualizarTotales(idPedido, nuevaSubtotal, nuevaIva, nuevoServicio, nuevoTotal);
                resp.sendRedirect(req.getContextPath() + "/factura?id=" + idPedido);
                return;
            }
        }

        // Crear nuevo pedido
        double iva       = subtotal * IVA_PCT;
        double servicio  = subtotal * SERVICIO_PCT;
        double total     = subtotal + iva + servicio;

        Pedido pedido = new Pedido();
        pedido.setIdCliente(cliente.getId());
        pedido.setFecha(LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd")));
        pedido.setHora(LocalTime.now().format(DateTimeFormatter.ofPattern("HH:mm:ss")));
        pedido.setSubtotal(subtotal);
        pedido.setIva(iva);
        pedido.setServicio(servicio);
        pedido.setTotal(total);
        pedido.setDetalles(detalles);

        idPedido = pDao.insertar(pedido);

        if (idPedido < 0) {
            resp.sendRedirect(req.getContextPath() + "/menu?error=pedido");
            return;
        }

        for (DetallePedido d : detalles) {
            d.setIdPedido(idPedido);
            pDao.insertarDetalle(d);
        }

        resp.sendRedirect(req.getContextPath() + "/factura?id=" + idPedido);
    }
}
