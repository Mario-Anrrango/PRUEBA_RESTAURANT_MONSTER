package ec.edu.monster.restaurante.controlador;

import ec.edu.monster.restaurante.dao.*;
import ec.edu.monster.restaurante.modelo.*;
import ec.edu.monster.restaurante.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

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
            case "formCliente":     cargarFormCliente(req, resp); break;
            case "buscarCliente":   mostrarBusqueda(req, resp);   break;
            case "cancelarPedido":  cancelarPedido(req, resp);    break;
            case "buscarPorId":     buscarPorIdYRedirigir(req, resp); break;
            default:                req.getRequestDispatcher("/vistas/empleado/dashboard.jsp").forward(req, resp);
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
            case "registrarCliente":  registrarCliente(req, resp); break;
            case "actualizarCliente": actualizarCliente(req, resp); break;
            case "buscarCedula":      buscarPorCedula(req, resp);  break;
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

    // FASE 6.20: Cancelar pedido desde panel mesero
    private void cancelarPedido(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String pedidoId = req.getParameter("id");
        if (pedidoId != null && !pedidoId.isEmpty()) {
            new PedidoDAO().cancelar(pedidoId);
        }
        HttpSession session = req.getSession();
        session.setAttribute("mensaje", "Pedido cancelado correctamente");
        session.setAttribute("tipoMensaje", "success");
        resp.sendRedirect("empleado?accion=buscarCliente");
    }

    // FASE 6.20: Volver al cliente desde tomar-pedido (mantiene búsqueda)
    // FASE 6.24: Paginación en historial
    private void buscarPorIdYRedirigir(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String id = req.getParameter("id");
        if (id != null && !id.isEmpty()) {
            ClienteDAO cDao = new ClienteDAO();
            Cliente cliente = cDao.buscarPorId(id);
            if (cliente != null) {
                req.setAttribute("clienteEncontrado", cliente);
                cargarHistorialPaginado(req, cliente.getId());
            }
        }
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
            cargarHistorialPaginado(req, cliente.getId());
        }
        req.getRequestDispatcher("/vistas/empleado/buscar-cliente.jsp").forward(req, resp);
    }

    private void registrarCliente(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // FASE 6.20: Null-safe para cedula e identificacionExtranjera (extranjero)
        String cedula = req.getParameter("cedula");
        if (cedula != null) cedula = cedula.trim();
        
        String identificacionExtranjera = req.getParameter("identificacionExtranjera");
        if (identificacionExtranjera != null) identificacionExtranjera = identificacionExtranjera.trim();
        
        // Validar que al menos uno tenga valor
        if ((cedula == null || cedula.isEmpty()) && (identificacionExtranjera == null || identificacionExtranjera.isEmpty())) {
            req.setAttribute("error", "Debe ingresar cédula o identificación extranjera");
            req.getRequestDispatcher("/vistas/empleado/registrar-cliente.jsp").forward(req, resp);
            return;
        }
        
        ClienteDAO cDao = new ClienteDAO();
        UsuarioDAO uDao = new UsuarioDAO();

        if (cedula != null && !cedula.isEmpty() && cDao.existeCedula(cedula)) {
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
        c.setIdentificacionExtranjera(identificacionExtranjera);
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
            // FASE 6.20: Mantener cédula/identificación original (no modificable en edición)
            // Solo actualizar si no está en edición (los campos readonly no se envían)
            String cedulaParam = req.getParameter("cedula");
            if (cedulaParam != null && !cedulaParam.isEmpty()) {
                c.setCedula(cedulaParam.trim());
            }
            String idExt = req.getParameter("identificacionExtranjera");
            if (idExt != null) c.setIdentificacionExtranjera(idExt);
            // Hidden input envía "on" o "" (ya que checkbox disabled no se envía)
            c.setEsExtranjero("on".equals(req.getParameter("esExtranjero")));
            c.setDireccion(req.getParameter("direccion").trim());
            c.setCorreo(req.getParameter("correo").trim());
            c.setTelefono(req.getParameter("telefono").trim());
            cDao.actualizar(c);
        }
        HttpSession session = req.getSession();
        session.setAttribute("mensaje", "Cliente actualizado correctamente");
        session.setAttribute("tipoMensaje", "success");
        resp.sendRedirect("empleado?accion=buscarPorId&id=" + c.getId());
    }

    // FASE 6.24: Cargar historial paginado
    private void cargarHistorialPaginado(HttpServletRequest req, String idCliente) {
        PedidoDAO pDao = new PedidoDAO();
        int pagina = 1;
        int registrosPorPagina = 5;
        String fechaDesde = req.getParameter("fechaDesde");
        String fechaHasta = req.getParameter("fechaHasta");
        String estado = req.getParameter("estado");
        
        String paginaStr = req.getParameter("pagina");
        if (paginaStr != null && !paginaStr.isEmpty()) {
            try { pagina = Integer.parseInt(paginaStr); if (pagina < 1) pagina = 1; }
            catch (NumberFormatException e) { pagina = 1; }
        }
        String registrosStr = req.getParameter("registros");
        if (registrosStr != null && !registrosStr.isEmpty()) {
            try { 
                registrosPorPagina = Integer.parseInt(registrosStr);
                if (registrosPorPagina < 1) registrosPorPagina = 5;
                if (registrosPorPagina > 50) registrosPorPagina = 50;
            } catch (NumberFormatException e) { registrosPorPagina = 5; }
        }
        
        int totalRegistros = pDao.contarPedidosPorCliente(idCliente, fechaDesde, fechaHasta, estado);
        int totalPaginas = (int) Math.ceil((double) totalRegistros / registrosPorPagina);
        if (pagina > totalPaginas && totalPaginas > 0) pagina = totalPaginas;
        
        List<Pedido> historial = pDao.listarPorClienteConPaginacion(idCliente, pagina, registrosPorPagina, fechaDesde, fechaHasta, estado);
        
        req.setAttribute("historialPedidos", historial);
        req.setAttribute("pagina", pagina);
        req.setAttribute("totalPaginas", totalPaginas);
        req.setAttribute("totalRegistros", (long) totalRegistros);
        req.setAttribute("registrosPorPagina", registrosPorPagina);
        req.setAttribute("fechaDesde", fechaDesde);
        req.setAttribute("fechaHasta", fechaHasta);
        req.setAttribute("estadoFiltro", estado);
    }
    
    private boolean tieneAcceso(HttpServletRequest req, String perfil) {
        HttpSession s = req.getSession(false);
        if (s == null) return false;
        Usuario u = (Usuario) s.getAttribute("usuario");
        return u != null && perfil.equals(u.getPerfil());
    }
}
