package ec.edu.monster.restaurante.controlador;

import ec.edu.monster.restaurante.dao.CategoriaDAO;
import ec.edu.monster.restaurante.dao.PlatoDAO;
import ec.edu.monster.restaurante.modelo.Categoria;
import ec.edu.monster.restaurante.modelo.Plato;
import ec.edu.monster.restaurante.modelo.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
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

        List<Categoria> categorias = new CategoriaDAO().listar();
        PlatoDAO pDao = new PlatoDAO();

        Map<String, List<Plato>> platosPorCategoria = new LinkedHashMap<>();
        for (Categoria cat : categorias) {
            platosPorCategoria.put(cat.getId(), pDao.listarPorCategoria(cat.getId()));
        }

        req.setAttribute("categorias", categorias);
        req.setAttribute("platosPorCategoria", platosPorCategoria);
        req.getRequestDispatcher("/vistas/cliente/menu.jsp").forward(req, resp);
    }
}
