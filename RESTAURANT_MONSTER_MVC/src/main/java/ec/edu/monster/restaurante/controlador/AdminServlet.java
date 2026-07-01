package ec.edu.monster.restaurante.controlador;

import ec.edu.monster.restaurante.dao.*;
import ec.edu.monster.restaurante.modelo.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!tieneAcceso(req, "ADMIN")) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String accion = req.getParameter("accion");
        if (accion == null) accion = "dashboard";

        switch (accion) {
            case "listarPlatos":   mostrarPlatos(req, resp);          break;
            case "nuevoPlato":     mostrarFormPlato(req, resp, null);    break;
            case "editarPlato":    mostrarFormPlato(req, resp, req.getParameter("id")); break;
            case "eliminarPlato":  eliminarPlato(req, resp);          break;
            case "formCliente":    formCliente(req, resp);            break;
            case "formEmpleado":   formEmpleado(req, resp);           break;
            case "listarClientes": listarClientes(req, resp);         break;
            case "listarEmpleados":listarEmpleados(req, resp);        break;
            default:               req.getRequestDispatcher("/vistas/admin/dashboard.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!tieneAcceso(req, "ADMIN")) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
        req.setCharacterEncoding("UTF-8");

        String accion = req.getParameter("accion");
        if (accion == null) accion = "";

        switch (accion) {
            case "guardarPlato":    guardarPlato(req, resp);    break;
            case "registrarCliente":registrarCliente(req, resp);break;
            case "registrarEmpleado":registrarEmpleado(req, resp);break;
            default: resp.sendRedirect("admin");
        }
    }

    // ---------- PLATOS ----------

    private void mostrarPlatos(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        List<Plato> platos = new PlatoDAO().listarTodos();
        req.setAttribute("platos", platos);
        req.getRequestDispatcher("/vistas/admin/gestion-platos.jsp").forward(req, resp);
    }

    private void mostrarFormPlato(HttpServletRequest req, HttpServletResponse resp, String id)
            throws ServletException, IOException {
        Plato plato = (id != null && !id.isEmpty()) ? new PlatoDAO().buscarPorId(id) : new Plato();
        req.setAttribute("plato", plato);
        req.setAttribute("categorias", new CategoriaDAO().listar());
        req.getRequestDispatcher("/vistas/admin/form-plato.jsp").forward(req, resp);
    }

    private void guardarPlato(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        Plato p = new Plato();
        String idStr = req.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) p.setId(idStr);
        p.setNombre(req.getParameter("nombre").trim());
        p.setDescripcion(req.getParameter("descripcion").trim());
        p.setPrecio(new BigDecimal(req.getParameter("precio")));
        p.setFoto(req.getParameter("foto").trim());
        p.setIdCategoria(req.getParameter("idCategoria"));
        p.setActivo(true);

        PlatoDAO dao = new PlatoDAO();
        if (idStr != null && !idStr.isEmpty()) dao.actualizar(p);
        else dao.insertar(p);

        resp.sendRedirect("admin?accion=listarPlatos&ok=1");
    }

    private void eliminarPlato(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String id = req.getParameter("id");
        if (id != null && !id.isEmpty()) {
            new PlatoDAO().eliminar(id);
        }
        resp.sendRedirect("admin?accion=listarPlatos&eliminado=1");
    }

    // ---------- CLIENTES ----------

    private void formCliente(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/vistas/admin/registrar-cliente.jsp").forward(req, resp);
    }

    private void listarClientes(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("clientes", new ClienteDAO().listar());
        req.getRequestDispatcher("/vistas/admin/lista-clientes.jsp").forward(req, resp);
    }

    private void registrarCliente(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String cedula    = req.getParameter("cedula").trim();
        ClienteDAO cDao  = new ClienteDAO();
        UsuarioDAO uDao  = new UsuarioDAO();

        if (cDao.existeCedula(cedula)) {
            req.setAttribute("error", "La cédula ya está registrada.");
            req.getRequestDispatcher("/vistas/admin/registrar-cliente.jsp").forward(req, resp);
            return;
        }

        String username = req.getParameter("username").trim();
        if (uDao.existeUsername(username)) {
            req.setAttribute("error", "El nombre de usuario ya existe.");
            req.getRequestDispatcher("/vistas/admin/registrar-cliente.jsp").forward(req, resp);
            return;
        }

        String idUsr = uDao.insertar(username, req.getParameter("password").trim(), "CLIENTE");
        Cliente c = new Cliente();
        c.setNombres(req.getParameter("nombres").trim());
        c.setApellidos(req.getParameter("apellidos").trim());
        c.setCedula(cedula);
        c.setDireccion(req.getParameter("direccion").trim());
        c.setCorreo(req.getParameter("correo").trim());
        c.setTelefono(req.getParameter("telefono").trim());
        c.setIdUsuario(idUsr);
        cDao.insertar(c);

        resp.sendRedirect("admin?accion=listarClientes&ok=1");
    }

    // ---------- EMPLEADOS ----------

    private void formEmpleado(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/vistas/admin/registrar-empleado.jsp").forward(req, resp);
    }

    private void listarEmpleados(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("empleados", new EmpleadoDAO().listar());
        req.getRequestDispatcher("/vistas/admin/lista-empleados.jsp").forward(req, resp);
    }

    private void registrarEmpleado(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String cedula   = req.getParameter("cedula").trim();
        EmpleadoDAO eDao = new EmpleadoDAO();
        UsuarioDAO  uDao = new UsuarioDAO();

        if (eDao.existeCedula(cedula)) {
            req.setAttribute("error", "La cédula ya está registrada.");
            req.getRequestDispatcher("/vistas/admin/registrar-empleado.jsp").forward(req, resp);
            return;
        }
        String username = req.getParameter("username").trim();
        if (uDao.existeUsername(username)) {
            req.setAttribute("error", "El nombre de usuario ya existe.");
            req.getRequestDispatcher("/vistas/admin/registrar-empleado.jsp").forward(req, resp);
            return;
        }

        String idUsr = uDao.insertar(username, req.getParameter("password").trim(), "EMPLEADO");
        Empleado e = new Empleado();
        e.setNombres(req.getParameter("nombres").trim());
        e.setApellidos(req.getParameter("apellidos").trim());
        e.setCedula(cedula);
        e.setCargo(req.getParameter("cargo").trim());
        e.setTelefono(req.getParameter("telefono").trim());
        e.setCorreo(req.getParameter("correo").trim());
        e.setFechaIngreso(LocalDate.parse(req.getParameter("fechaIngreso")));
        e.setIdUsuario(idUsr);
        eDao.insertar(e);

        resp.sendRedirect("admin?accion=listarEmpleados&ok=1");
    }

    private boolean tieneAcceso(HttpServletRequest req, String perfil) {
        HttpSession s = req.getSession(false);
        if (s == null) return false;
        Usuario u = (Usuario) s.getAttribute("usuario");
        return u != null && perfil.equals(u.getPerfil());
    }
}
