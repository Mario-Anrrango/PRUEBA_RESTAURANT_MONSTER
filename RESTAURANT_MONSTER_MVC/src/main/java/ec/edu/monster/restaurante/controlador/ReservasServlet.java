package ec.edu.monster.restaurante.controlador;

import ec.edu.monster.restaurante.dao.PedidoDAO;
import ec.edu.monster.restaurante.modelo.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
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
                new PedidoDAO().cancelar(id);
            }
            resp.sendRedirect("reservas?msg=cancelado");
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

        // Aplicar filtros
        String desde = req.getParameter("desde");
        String hasta = req.getParameter("hasta");
        String estado = req.getParameter("estado");

        if (cliente != null) {
            List<Pedido> pedidos = new PedidoDAO().listarPorCliente(cliente.getId());

            // Filtrar por estado
            if (estado != null && !"TODOS".equals(estado)) {
                List<Pedido> filtrados = new ArrayList<>();
                for (Pedido p : pedidos) {
                    if (estado.equals(p.getEstado())) {
                        filtrados.add(p);
                    }
                }
                pedidos = filtrados;
            }

            // Filtrar por rango de fechas
            if (desde != null && !desde.isEmpty()) {
                LocalDate desdeDate = LocalDate.parse(desde);
                List<Pedido> filtrados = new ArrayList<>();
                for (Pedido p : pedidos) {
                    if (!p.getFecha().isBefore(desdeDate)) {
                        filtrados.add(p);
                    }
                }
                pedidos = filtrados;
            }

            if (hasta != null && !hasta.isEmpty()) {
                LocalDate hastaDate = LocalDate.parse(hasta);
                List<Pedido> filtrados = new ArrayList<>();
                for (Pedido p : pedidos) {
                    if (!p.getFecha().isAfter(hastaDate)) {
                        filtrados.add(p);
                    }
                }
                pedidos = filtrados;
            }

            req.setAttribute("pedidos", pedidos);
        }

        req.getRequestDispatcher("/vistas/cliente/reservas.jsp").forward(req, resp);
    }
}
