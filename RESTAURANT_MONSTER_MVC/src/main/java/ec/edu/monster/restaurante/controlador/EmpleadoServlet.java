package ec.edu.monster.restaurante.controlador;

import ec.edu.monster.restaurante.dao.*;
import ec.edu.monster.restaurante.modelo.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/empleado")
public class EmpleadoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!tieneAcceso(req, "EMPLEADO")) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String accion = req.getParameter("accion");
        if (accion == null) accion = "dashboard";

        switch (accion) {
            case "formCliente":  req.getRequestDispatcher("/vistas/empleado/registrar-cliente.jsp").forward(req, resp); break;
            case "buscarCliente":mostrarBusqueda(req, resp); break;
            default:             req.getRequestDispatcher("/vistas/empleado/dashboard.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!tieneAcceso(req, "EMPLEADO")) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
        req.setCharacterEncoding("UTF-8");

        String accion = req.getParameter("accion");
        if (accion == null) accion = "";

        switch (accion) {
            case "registrarCliente": registrarCliente(req, resp); break;
            case "buscarCedula":     buscarPorCedula(req, resp);  break;
            default: resp.sendRedirect("empleado");
        }
    }

    private void mostrarBusqueda(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/vistas/empleado/buscar-cliente.jsp").forward(req, resp);
    }

    private void buscarPorCedula(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String cedula = req.getParameter("cedula").trim();
        Cliente cliente = new ClienteDAO().buscarPorCedula(cedula);
        if (cliente == null) {
            req.setAttribute("error", "No se encontró ningún cliente con la cédula: " + cedula);
        } else {
            req.setAttribute("clienteEncontrado", cliente);
            PedidoDAO pDao = new PedidoDAO();
            req.setAttribute("historialPedidos", pDao.listarPorCliente(cliente.getId()));
        }
        req.getRequestDispatcher("/vistas/empleado/buscar-cliente.jsp").forward(req, resp);
    }

    private void registrarCliente(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String cedula   = req.getParameter("cedula").trim();
        ClienteDAO cDao = new ClienteDAO();
        UsuarioDAO uDao = new UsuarioDAO();

        if (cDao.existeCedula(cedula)) {
            req.setAttribute("error", "La cédula ya está registrada en el sistema.");
            req.getRequestDispatcher("/vistas/empleado/registrar-cliente.jsp").forward(req, resp);
            return;
        }
        String username = req.getParameter("username").trim();
        if (uDao.existeUsername(username)) {
            req.setAttribute("error", "El nombre de usuario ya existe.");
            req.getRequestDispatcher("/vistas/empleado/registrar-cliente.jsp").forward(req, resp);
            return;
        }

        int idUsr = uDao.insertar(username, req.getParameter("password").trim(), "CLIENTE");
        Cliente c = new Cliente();
        c.setNombres(req.getParameter("nombres").trim());
        c.setApellidos(req.getParameter("apellidos").trim());
        c.setCedula(cedula);
        c.setDireccion(req.getParameter("direccion").trim());
        c.setCorreo(req.getParameter("correo").trim());
        c.setTelefono(req.getParameter("telefono").trim());
        c.setIdUsuario(idUsr);
        cDao.insertar(c);

        req.setAttribute("exito", "Cliente registrado correctamente.");
        req.getRequestDispatcher("/vistas/empleado/registrar-cliente.jsp").forward(req, resp);
    }

    private boolean tieneAcceso(HttpServletRequest req, String perfil) {
        HttpSession s = req.getSession(false);
        if (s == null) return false;
        Usuario u = (Usuario) s.getAttribute("usuario");
        return u != null && perfil.equals(u.getPerfil());
    }
}
