package ec.edu.monster.restaurante.controlador;

import ec.edu.monster.restaurante.dao.ClienteDAO;
import ec.edu.monster.restaurante.dao.UsuarioDAO;
import ec.edu.monster.restaurante.modelo.Cliente;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/registro")
public class RegistroClienteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/vistas/registro-cliente.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String nombres   = req.getParameter("nombres").trim();
        String apellidos = req.getParameter("apellidos").trim();
        String cedula    = req.getParameter("cedula").trim();
        String direccion = req.getParameter("direccion").trim();
        String correo    = req.getParameter("correo").trim();
        String telefono  = req.getParameter("telefono").trim();
        String username  = req.getParameter("username").trim();
        String password  = req.getParameter("password").trim();

        UsuarioDAO uDao = new UsuarioDAO();
        ClienteDAO cDao = new ClienteDAO();

        if (uDao.existeUsername(username)) {
            req.setAttribute("error", "El nombre de usuario ya está en uso.");
            req.getRequestDispatcher("/vistas/registro-cliente.jsp").forward(req, resp);
            return;
        }
        if (cDao.existeCedula(cedula)) {
            req.setAttribute("error", "La cédula ya está registrada en el sistema.");
            req.getRequestDispatcher("/vistas/registro-cliente.jsp").forward(req, resp);
            return;
        }

        String idUsuario = uDao.insertar(username, password, "CLIENTE");
        if (idUsuario == null) {
            req.setAttribute("error", "Error al crear el usuario. Intente nuevamente.");
            req.getRequestDispatcher("/vistas/registro-cliente.jsp").forward(req, resp);
            return;
        }

        Cliente c = new Cliente();
        c.setNombres(nombres);
        c.setApellidos(apellidos);
        c.setCedula(cedula);
        c.setDireccion(direccion);
        c.setCorreo(correo);
        c.setTelefono(telefono);
        c.setIdUsuario(idUsuario);
        cDao.insertar(c);

        resp.sendRedirect("login?registrado=1");
    }
}
