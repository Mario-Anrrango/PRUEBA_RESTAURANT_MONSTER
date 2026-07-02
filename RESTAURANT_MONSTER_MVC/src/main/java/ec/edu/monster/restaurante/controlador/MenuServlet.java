package ec.edu.monster.restaurante.controlador;

import ec.edu.monster.restaurante.dao.CategoriaDAO;
import ec.edu.monster.restaurante.dao.PedidoDAO;
import ec.edu.monster.restaurante.dao.PlatoDAO;
import ec.edu.monster.restaurante.modelo.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.*;

@WebServlet("/menu")
public class MenuServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        Usuario u = (Usuario) session.getAttribute("usuario");
        if (!"CLIENTE".equals(u.getPerfil())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // PROBLEMA 2: Manejar modificación de pedido existente
        String modificarId = req.getParameter("modificar");
        if (modificarId != null && !modificarId.isEmpty()) {
            PedidoDAO pedidoDAO = new PedidoDAO();
            Pedido pedido = pedidoDAO.buscarPorId(modificarId);
            
            if (pedido != null && "PENDIENTE".equals(pedido.getEstado())) {
                LocalDateTime creado = LocalDateTime.of(pedido.getFecha(), pedido.getHora());
                long horasTranscurridas = Duration.between(creado, LocalDateTime.now()).toHours();
                
                if (horasTranscurridas < 24) {
                    // Guardar pedido y detalles en sesión para que menu.jsp los pre-cargue
                    session.setAttribute("pedidoModificando", pedido);
                    req.setAttribute("detallesModificar", pedido.getDetalles());
                    req.setAttribute("modificandoId", modificarId);
                } else {
                    session.removeAttribute("pedidoModificando");
                    resp.sendRedirect(req.getContextPath() + "/reservas?error=noModificable");
                    return;
                }
            } else {
                session.removeAttribute("pedidoModificando");
                resp.sendRedirect(req.getContextPath() + "/reservas?error=noModificable");
                return;
            }
        } else {
            session.removeAttribute("pedidoModificando");
        }

        // PROBLEMA 1: Usar listarActivosAgrupados para evitar problemas de tipo id_categoria
        PlatoDAO pDao = new PlatoDAO();
        List<Categoria> categorias = new CategoriaDAO().listar();
        Map<String, List<Plato>> platosActivos = pDao.listarActivosAgrupados();
        
        // Organizar por categoría, filtrando solo las que tienen platos activos
        Map<String, List<Plato>> platosPorCategoria = new LinkedHashMap<>();
        for (Categoria cat : categorias) {
            List<Plato> platos = platosActivos.get(cat.getId());
            if (platos != null && !platos.isEmpty()) {
                platosPorCategoria.put(cat.getId(), platos);
            }
        }

        req.setAttribute("categorias", categorias);
        req.setAttribute("platosPorCategoria", platosPorCategoria);
        req.getRequestDispatcher("/vistas/cliente/menu.jsp").forward(req, resp);
    }
}
