package ec.edu.monster.restaurante.controlador;

import ec.edu.monster.restaurante.dao.ClienteDAO;
import ec.edu.monster.restaurante.dao.EmpleadoDAO;
import ec.edu.monster.restaurante.dao.UsuarioDAO;
import ec.edu.monster.restaurante.modelo.Cliente;
import ec.edu.monster.restaurante.modelo.Empleado;
import ec.edu.monster.restaurante.modelo.Usuario;
import ec.edu.monster.restaurante.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html;charset=UTF-8");
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
        Usuario usuario = uDao.buscarPorUsername(username);

        if (usuario == null) {
            req.setAttribute("error", "Usuario o contraseña incorrectos.");
            req.getRequestDispatcher("/vistas/login.jsp").forward(req, resp);
            return;
        }

        // Verificar contraseña
        boolean passwordValida = false;

        if (PasswordUtil.isBcrypt(usuario.getPassword())) {
            // Contraseña ya encriptada → usar BCrypt.verify()
            passwordValida = PasswordUtil.verify(password, usuario.getPassword());
        } else {
            // Contraseña en texto plano (migración) → comparación directa
            passwordValida = password.equals(usuario.getPassword());
            // Migrar automáticamente a BCrypt
            if (passwordValida) {
                String hashed = PasswordUtil.hash(password);
                uDao.actualizarPassword(usuario.getId(), hashed);
            }
        }

        if (!passwordValida) {
            req.setAttribute("error", "Usuario o contraseña incorrectos.");
            req.getRequestDispatcher("/vistas/login.jsp").forward(req, resp);
            return;
        }

        if (!usuario.isActivo()) {
            req.setAttribute("error", "Esta cuenta está desactivada. Contacte al administrador.");
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
