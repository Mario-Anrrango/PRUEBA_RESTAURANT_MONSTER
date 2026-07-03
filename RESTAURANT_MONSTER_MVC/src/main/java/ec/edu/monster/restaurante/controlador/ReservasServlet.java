package ec.edu.monster.restaurante.controlador;

import ec.edu.monster.restaurante.dao.PedidoDAO;
import ec.edu.monster.restaurante.modelo.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet("/reservas")
public class ReservasServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
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

        String accion = req.getParameter("accion");
        if ("cancelar".equals(accion)) {
            String id = req.getParameter("id");
            if (id != null && !id.isEmpty()) {
                PedidoDAO pDao = new PedidoDAO();
                Pedido pedido = pDao.buscarPorId(id);
                if (pedido != null && "PENDIENTE".equals(pedido.getEstado())) {
                    LocalDateTime creado = LocalDateTime.of(pedido.getFecha(), pedido.getHora());
                    long horasTranscurridas = Duration.between(creado, LocalDateTime.now()).toHours();
                    if (horasTranscurridas < 24) {
                        pDao.cancelar(id);
                        session.setAttribute("mensaje", "Pedido cancelado correctamente");
                        session.setAttribute("tipoMensaje", "success");
                    } else {
                        session.setAttribute("mensaje", "No se puede cancelar. Han pasado mas de 24 horas desde la creacion");
                        session.setAttribute("tipoMensaje", "error");
                    }
                } else {
                    session.setAttribute("mensaje", "No se puede cancelar. El pedido no esta pendiente");
                    session.setAttribute("tipoMensaje", "error");
                }
            }
            resp.sendRedirect("reservas");
            return;
        }

        if ("ver".equals(accion)) {
            String id = req.getParameter("id");
            if (id != null && !id.isEmpty()) {
                Pedido pedido = new PedidoDAO().buscarPorId(id);
                req.setAttribute("pedido", pedido);
                req.getRequestDispatcher("/vistas/cliente/ver-reserva.jsp").forward(req, resp);
                return;
            }
            resp.sendRedirect("reservas");
            return;
        }

        // FASE 6.7: Paginacion y filtros en BD
        String desde = req.getParameter("desde");
        String hasta = req.getParameter("hasta");
        String estado = req.getParameter("estado");
        
        int pagina = 1;
        int registrosPorPagina = 5;
        try {
            if (req.getParameter("pagina") != null) pagina = Integer.parseInt(req.getParameter("pagina"));
            if (req.getParameter("registros") != null) registrosPorPagina = Integer.parseInt(req.getParameter("registros"));
        } catch (NumberFormatException e) { /* valores por defecto */ }

        req.setAttribute("desde", desde);
        req.setAttribute("hasta", hasta);
        req.setAttribute("estado", estado);

        if (cliente != null) {
            try {
                PedidoDAO pDao = new PedidoDAO();
                List<Pedido> pedidos = pDao.listarPorClienteConPaginacion(
                    cliente.getId(), pagina, registrosPorPagina, desde, hasta, estado);
                int totalRegistros = pDao.contarPedidosPorCliente(cliente.getId(), desde, hasta, estado);
                int totalPaginas = (int) Math.ceil((double) totalRegistros / registrosPorPagina);
                
                req.setAttribute("pedidos", pedidos);
                req.setAttribute("pagina", pagina);
                req.setAttribute("totalPaginas", totalPaginas);
                req.setAttribute("totalRegistros", totalRegistros);
                req.setAttribute("registrosPorPagina", registrosPorPagina);
            } catch (Exception e) {
                e.printStackTrace();
                req.setAttribute("pedidos", new PedidoDAO().listarPorCliente(cliente.getId()));
                req.setAttribute("pagina", 1);
                req.setAttribute("totalPaginas", 1);
                req.setAttribute("totalRegistros", 0);
                req.setAttribute("registrosPorPagina", 5);
            }
        }

        req.getRequestDispatcher("/vistas/cliente/reservas.jsp").forward(req, resp);
    }
}
