package ec.edu.monster.restaurante.controlador;

import ec.edu.monster.restaurante.dao.ClienteDAO;
import ec.edu.monster.restaurante.dao.UsuarioDAO;
import ec.edu.monster.restaurante.modelo.Cliente;
import ec.edu.monster.restaurante.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/registro")
public class RegistroClienteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html;charset=UTF-8");

        String accion = req.getParameter("accion");

        if (accion != null) {
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            PrintWriter out = resp.getWriter();

            switch (accion) {
                case "validarCedula":
                    validarCedula(req, out);
                    break;
                case "validarIdentificacion":
                    validarIdentificacion(req, out);
                    break;
                case "validarUsuario":
                    validarUsuario(req, out);
                    break;
                case "validarCorreo":
                    validarCorreo(req, out);
                    break;
                default:
                    req.getRequestDispatcher("/vistas/registro-cliente.jsp").forward(req, resp);
            }
        } else {
            req.getRequestDispatcher("/vistas/registro-cliente.jsp").forward(req, resp);
        }
    }

    private void validarCedula(HttpServletRequest req, PrintWriter out) {
        String cedula = req.getParameter("cedula");
        if (cedula == null || cedula.isEmpty()) {
            out.print("{\"valid\": false, \"message\": \"Cédula es obligatoria\"}");
            return;
        }
        ClienteDAO clienteDAO = new ClienteDAO();
        Cliente existente = clienteDAO.buscarPorCedula(cedula);
        if (existente != null) {
            out.print("{\"valid\": false, \"message\": \"Esta cédula ya está registrada\"}");
        } else if (cedula.length() != 10) {
            out.print("{\"valid\": false, \"message\": \"La cédula debe tener 10 dígitos\"}");
        } else if (!validarCedulaEcuatoriana(cedula)) {
            out.print("{\"valid\": false, \"message\": \"Cédula inválida\"}");
        } else {
            out.print("{\"valid\": true, \"message\": \"Cédula válida\"}");
        }
    }

    private void validarIdentificacion(HttpServletRequest req, PrintWriter out) {
        String idExt = req.getParameter("id");
        if (idExt == null || idExt.isEmpty()) {
            out.print("{\"valid\": false, \"message\": \"Identificación es obligatoria\"}");
            return;
        }
        ClienteDAO clienteDAO = new ClienteDAO();
        Cliente existente = clienteDAO.buscarPorIdentificacionExtranjera(idExt);
        if (existente != null) {
            out.print("{\"valid\": false, \"message\": \"Esta identificación ya está registrada\"}");
        } else if (idExt.length() < 5) {
            out.print("{\"valid\": false, \"message\": \"Mínimo 5 caracteres\"}");
        } else if (idExt.length() > 20) {
            out.print("{\"valid\": false, \"message\": \"Máximo 20 caracteres\"}");
        } else {
            out.print("{\"valid\": true, \"message\": \"Identificación válida\"}");
        }
    }

    private void validarUsuario(HttpServletRequest req, PrintWriter out) {
        String username = req.getParameter("usuario");
        if (username == null || username.isEmpty()) {
            out.print("{\"valid\": false, \"message\": \"Usuario es obligatorio\"}");
            return;
        }
        UsuarioDAO uDao = new UsuarioDAO();
        if (uDao.existeUsername(username)) {
            out.print("{\"valid\": false, \"message\": \"Este usuario ya está registrado\"}");
        } else if (username.length() < 4) {
            out.print("{\"valid\": false, \"message\": \"Mínimo 4 caracteres\"}");
        } else if (username.contains(" ")) {
            out.print("{\"valid\": false, \"message\": \"No se permiten espacios\"}");
        } else {
            out.print("{\"valid\": true, \"message\": \"Usuario disponible\"}");
        }
    }

    private void validarCorreo(HttpServletRequest req, PrintWriter out) {
        String correo = req.getParameter("correo");
        if (correo == null || correo.isEmpty()) {
            out.print("{\"valid\": true, \"message\": \"\"}");
            return;
        }
        // Verificar si existe en BD
        ClienteDAO clienteDAO = new ClienteDAO();
        // Buscar por correo: recorrer clientes (no hay índice de correo)
        java.util.List<Cliente> todos = clienteDAO.listar();
        boolean existe = false;
        for (Cliente c : todos) {
            if (correo.equalsIgnoreCase(c.getCorreo())) {
                existe = true;
                break;
            }
        }
        if (existe) {
            out.print("{\"valid\": false, \"message\": \"Este correo ya está registrado\"}");
        } else {
            out.print("{\"valid\": true, \"message\": \"\"}");
        }
    }

    private boolean validarCedulaEcuatoriana(String cedula) {
        if (cedula == null || cedula.length() != 10) return false;
        try {
            int[] coeficientes = {2, 1, 2, 1, 2, 1, 2, 1, 2};
            int suma = 0;
            for (int i = 0; i < 9; i++) {
                int producto = Integer.parseInt(String.valueOf(cedula.charAt(i))) * coeficientes[i];
                if (producto > 9) producto -= 9;
                suma += producto;
            }
            int digitoVerificador = (10 - (suma % 10)) % 10;
            return Integer.parseInt(String.valueOf(cedula.charAt(9))) == digitoVerificador;
        } catch (NumberFormatException e) {
            return false;
        }
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
        if (!"on".equals(req.getParameter("esExtranjero")) && cDao.existeCedula(cedula)) {
            req.setAttribute("error", "La cédula ya está registrada en el sistema.");
            req.getRequestDispatcher("/vistas/registro-cliente.jsp").forward(req, resp);
            return;
        }

        // Encriptar contraseña con BCrypt
        String hashedPassword = PasswordUtil.hash(password);
        String idUsuario = uDao.insertar(username, hashedPassword, "CLIENTE");
        if (idUsuario == null) {
            req.setAttribute("error", "Error al crear el usuario. Intente nuevamente.");
            req.getRequestDispatcher("/vistas/registro-cliente.jsp").forward(req, resp);
            return;
        }

        Cliente c = new Cliente();
        c.setNombres(nombres);
        c.setApellidos(apellidos);
        c.setCedula(cedula);
        c.setIdentificacionExtranjera(req.getParameter("identificacionExtranjera"));
        c.setEsExtranjero("on".equals(req.getParameter("esExtranjero")));
        c.setDireccion(direccion);
        c.setCorreo(correo);
        c.setTelefono(telefono);
        c.setIdUsuario(idUsuario);
        cDao.insertar(c);

        resp.sendRedirect("login?registrado=1");
    }
}
