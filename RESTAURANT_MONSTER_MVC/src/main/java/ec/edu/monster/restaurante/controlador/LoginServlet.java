package ec.edu.monster.restaurante.controlador;

import ec.edu.monster.restaurante.dao.ClienteDAO;
import ec.edu.monster.restaurante.dao.EmpleadoDAO;
import ec.edu.monster.restaurante.dao.UsuarioDAO;
import ec.edu.monster.restaurante.modelo.Cliente;
import ec.edu.monster.restaurante.modelo.Empleado;
import ec.edu.monster.restaurante.modelo.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("usuario") != null) {
            redirigirPorPerfil((Usuario) session.getAttribute("usuario"), resp);
            return;
        }
        req.getRequestDispatcher("/vistas/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        UsuarioDAO uDao = new UsuarioDAO();
        Usuario usuario = uDao.autenticar(username, password);

        if (usuario == null) {
            req.setAttribute("error", "Usuario o contraseña incorrectos.");
            req.getRequestDispatcher("/vistas/login.jsp").forward(req, resp);
            return;
        }

        HttpSession session = req.getSession();
        session.setAttribute("usuario", usuario);

        if ("CLIENTE".equals(usuario.getPerfil())) {
            ClienteDAO cDao = new ClienteDAO();
            Cliente cliente = cDao.buscarPorIdUsuario(usuario.getId());
            session.setAttribute("cliente", cliente);
        } else if ("EMPLEADO".equals(usuario.getPerfil())) {
            EmpleadoDAO eDao = new EmpleadoDAO();
            Empleado empleado = eDao.buscarPorIdUsuario(usuario.getId());
            session.setAttribute("empleado", empleado);
        }

        redirigirPorPerfil(usuario, resp);
    }

    private void redirigirPorPerfil(Usuario u, HttpServletResponse resp) throws IOException {
        switch (u.getPerfil()) {
            case "ADMIN":    resp.sendRedirect("admin");    break;
            case "EMPLEADO": resp.sendRedirect("empleado"); break;
            case "CLIENTE":  resp.sendRedirect("menu");     break;
            default:         resp.sendRedirect("login");
        }
    }
}
