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

        List<Categoria> categorias = new CategoriaDAO().listar();
        PlatoDAO pDao = new PlatoDAO();
        Map<String, List<Plato>> platosPorCategoria = new LinkedHashMap<>();
        for (Categoria cat : categorias) {
            platosPorCategoria.put(cat.getId(), pDao.listarPorCategoria(cat.getId()));
        }

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
        if (platosSeleccionados == null || platosSeleccionados.length == 0) {
            resp.sendRedirect(req.getContextPath() + "/empleado/tomar-pedido?idCliente=" + idCliente + "&error=vacio");
            return;
        }

        PlatoDAO platoDao = new PlatoDAO();
        List<DetallePedido> detalles = new ArrayList<>();
        BigDecimal subtotal = BigDecimal.ZERO;

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
                detalles.add(d);
                subtotal = subtotal.add(plato.getPrecio().multiply(BigDecimal.valueOf(cantidad)));
            }
        }

        BigDecimal iva      = subtotal.multiply(IVA_PCT);
        BigDecimal servicio = subtotal.multiply(SERVICIO_PCT);
        BigDecimal total    = subtotal.add(iva).add(servicio);

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

        PedidoDAO pDao = new PedidoDAO();
        String idPedido = pDao.insertar(pedido);

        resp.sendRedirect(req.getContextPath() + "/factura?id=" + idPedido);
    }
}
