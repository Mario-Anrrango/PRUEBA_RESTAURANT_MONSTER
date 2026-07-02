package ec.edu.monster.restaurante.controlador;

import ec.edu.monster.restaurante.dao.*;
import ec.edu.monster.restaurante.modelo.*;
import ec.edu.monster.restaurante.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;

@WebServlet("/empleado")
public class EmpleadoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!tieneAcceso(req, "EMPLEADO")) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html;charset=UTF-8");

        String accion = req.getParameter("accion");
        if (accion == null) accion = "dashboard";

        switch (accion) {
            case "formCliente":    cargarFormCliente(req, resp); break;
            case "buscarCliente":  mostrarBusqueda(req, resp);   break;
            default:               req.getRequestDispatcher("/vistas/empleado/dashboard.jsp").forward(req, resp);
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
            case "actualizarCliente": actualizarCliente(req, resp); break;
            case "buscarCedula":     buscarPorCedula(req, resp);  break;
            default: resp.sendRedirect("empleado");
        }
    }

    private void cargarFormCliente(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String id = req.getParameter("id");
        if (id != null && !id.isEmpty()) {
            Cliente cliente = new ClienteDAO().buscarPorId(id);
            req.setAttribute("cliente", cliente);
        }
        req.getRequestDispatcher("/vistas/empleado/registrar-cliente.jsp").forward(req, resp);
    }

    private void mostrarBusqueda(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/vistas/empleado/buscar-cliente.jsp").forward(req, resp);
    }

    private void buscarPorCedula(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String termino = req.getParameter("cedula").trim();
        ClienteDAO cDao = new ClienteDAO();
        Cliente cliente = null;

        // Detectar si es cédula (10 dígitos numéricos) o identificación extranjera
        if (termino.matches("\\d{10}")) {
            cliente = cDao.buscarPorCedula(termino);
        } else {
            cliente = cDao.buscarPorIdentificacionExtranjera(termino);
        }

        if (cliente == null) {
            req.setAttribute("error", "No se encontró ningún cliente con: " + termino);
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

        if (!cedula.isEmpty() && cDao.existeCedula(cedula)) {
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

        // Encriptar contraseña con BCrypt
        String password = req.getParameter("password").trim();
        String hashedPassword = PasswordUtil.hash(password);
        String idUsr = uDao.insertar(username, hashedPassword, "CLIENTE");

        Cliente c = new Cliente();
        c.setNombres(req.getParameter("nombres").trim());
        c.setApellidos(req.getParameter("apellidos").trim());
        c.setCedula(cedula);
        c.setIdentificacionExtranjera(req.getParameter("identificacionExtranjera"));
        c.setEsExtranjero("on".equals(req.getParameter("esExtranjero")));
        c.setDireccion(req.getParameter("direccion").trim());
        c.setCorreo(req.getParameter("correo").trim());
        c.setTelefono(req.getParameter("telefono").trim());
        c.setIdUsuario(idUsr);
        cDao.insertar(c);

        HttpSession session = req.getSession();
        session.setAttribute("mensaje", "Cliente registrado correctamente");
        session.setAttribute("tipoMensaje", "success");
        resp.sendRedirect("empleado?accion=buscarCliente");
    }

    private void actualizarCliente(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String id = req.getParameter("id");
        ClienteDAO cDao = new ClienteDAO();
        Cliente c = cDao.buscarPorId(id);
        if (c != null) {
            c.setNombres(req.getParameter("nombres").trim());
            c.setApellidos(req.getParameter("apellidos").trim());
            c.setIdentificacionExtranjera(req.getParameter("identificacionExtranjera"));
            c.setEsExtranjero("on".equals(req.getParameter("esExtranjero")));
            c.setDireccion(req.getParameter("direccion").trim());
            c.setCorreo(req.getParameter("correo").trim());
            c.setTelefono(req.getParameter("telefono").trim());
            cDao.actualizar(c);
        }
        // Mantener búsqueda actual - ERROR 12 fix
        String cedulaBuscada = c.getCedula() != null ? c.getCedula() : c.getIdentificacionExtranjera();
        HttpSession session = req.getSession();
        session.setAttribute("mensaje", "Cliente actualizado correctamente");
        session.setAttribute("tipoMensaje", "success");
        resp.sendRedirect("empleado?accion=buscarCliente&cedula=" + (cedulaBuscada != null ? cedulaBuscada : ""));
    }

    private boolean tieneAcceso(HttpServletRequest req, String perfil) {
        HttpSession s = req.getSession(false);
        if (s == null) return false;
        Usuario u = (Usuario) s.getAttribute("usuario");
        return u != null && perfil.equals(u.getPerfil());
    }
}
