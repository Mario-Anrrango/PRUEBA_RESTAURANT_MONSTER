package ec.edu.monster.restaurante.controlador;

import ec.edu.monster.restaurante.dao.PedidoDAO;
import ec.edu.monster.restaurante.modelo.Pedido;
import ec.edu.monster.restaurante.modelo.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/factura")
public class FacturaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html;charset=UTF-8");
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) { resp.sendRedirect(req.getContextPath() + "/menu"); return; }

        Pedido pedido = new PedidoDAO().buscarPorId(idStr);
        if (pedido == null) { resp.sendRedirect(req.getContextPath() + "/menu"); return; }

        req.setAttribute("pedido", pedido);
        req.getRequestDispatcher("/vistas/cliente/factura.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String idStr = req.getParameter("idPedido");
        if (idStr != null && !idStr.isEmpty()) {
            new PedidoDAO().marcarPagado(idStr);
        }
        resp.sendRedirect(req.getContextPath() + "/menu?pagado=1");
    }
}
