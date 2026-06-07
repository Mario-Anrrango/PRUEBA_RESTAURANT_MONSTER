package ec.edu.monster.restaurante.controlador;

import ec.edu.monster.restaurante.dao.*;
import ec.edu.monster.restaurante.modelo.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@WebServlet("/empleado/tomar-pedido")
public class TomarPedidoServlet extends HttpServlet {

    private static final double IVA_PCT      = 0.15;
    private static final double SERVICIO_PCT = 0.10;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null || !"EMPLEADO".equals(usuario.getPerfil())) {
            resp.sendRedirect(req.getContextPath() + "/login"); return;
        }

        int idCliente = Integer.parseInt(req.getParameter("idCliente"));
        Cliente cliente = new ClienteDAO().buscarPorId(idCliente);
        if (cliente == null) { resp.sendRedirect(req.getContextPath() + "/empleado"); return; }

        List<Categoria> categorias = new CategoriaDAO().listar();
        PlatoDAO pDao = new PlatoDAO();
        Map<Integer, List<Plato>> platosPorCategoria = new LinkedHashMap<>();
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
        int idCliente = Integer.parseInt(req.getParameter("idCliente"));

        String[] platosSeleccionados = req.getParameterValues("platos");
        if (platosSeleccionados == null || platosSeleccionados.length == 0) {
            resp.sendRedirect(req.getContextPath() + "/empleado/tomar-pedido?idCliente=" + idCliente + "&error=vacio");
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

        double iva      = subtotal * IVA_PCT;
        double servicio = subtotal * SERVICIO_PCT;
        double total    = subtotal + iva + servicio;

        Pedido pedido = new Pedido();
        pedido.setIdCliente(idCliente);
        if (empleado != null) pedido.setIdEmpleado(empleado.getId());
        pedido.setFecha(LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd")));
        pedido.setHora(LocalTime.now().format(DateTimeFormatter.ofPattern("HH:mm:ss")));
        pedido.setSubtotal(subtotal);
        pedido.setIva(iva);
        pedido.setServicio(servicio);
        pedido.setTotal(total);

        PedidoDAO pDao = new PedidoDAO();
        int idPedido = pDao.insertar(pedido);
        for (DetallePedido d : detalles) {
            d.setIdPedido(idPedido);
            pDao.insertarDetalle(d);
        }

        resp.sendRedirect(req.getContextPath() + "/factura?id=" + idPedido);
    }
}
