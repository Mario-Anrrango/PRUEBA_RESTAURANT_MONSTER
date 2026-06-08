package ec.edu.monster.restaurante.controlador;

import ec.edu.monster.restaurante.dao.*;
import ec.edu.monster.restaurante.modelo.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.Part;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;
import java.util.List;

@MultipartConfig
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
            case "nuevoPlato":     mostrarFormPlato(req, resp, 0);    break;
            case "editarPlato":    mostrarFormPlato(req, resp, Integer.parseInt(req.getParameter("id"))); break;
            case "eliminarPlato":  eliminarPlato(req, resp);          break;
            case "activarPlato":   activarPlato(req, resp);           break;
            case "formCliente":    formCliente(req, resp);            break;
            case "editarCliente":  editarCliente(req, resp);          break;
            case "formEmpleado":   formEmpleado(req, resp);           break;
            case "editarEmpleado": editarEmpleado(req, resp);         break;
            case "listarClientes":   listarClientes(req, resp);         break;
            case "listarEmpleados":  listarEmpleados(req, resp);        break;
            case "toggleCliente":    toggleCliente(req, resp);          break;
            case "toggleEmpleado":   toggleEmpleado(req, resp);         break;
            
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
            case "guardarPlato":       guardarPlato(req, resp);        break;
            case "registrarCliente":   registrarCliente(req, resp);    break;
            case "actualizarCliente":  actualizarCliente(req, resp);   break;
            case "registrarEmpleado":  registrarEmpleado(req, resp);   break;
            case "actualizarEmpleado": actualizarEmpleado(req, resp);  break;
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

    private void mostrarFormPlato(HttpServletRequest req, HttpServletResponse resp, int id)
            throws ServletException, IOException {
        Plato plato = (id > 0) ? new PlatoDAO().buscarPorId(id) : new Plato();
        req.setAttribute("plato", plato);
        req.setAttribute("categorias", new CategoriaDAO().listar());
        req.getRequestDispatcher("/vistas/admin/form-plato.jsp").forward(req, resp);
    }

    private void guardarPlato(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        Plato p = new Plato();
        String idStr = req.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) p.setId(Integer.parseInt(idStr));
        p.setNombre(req.getParameter("nombre").trim());
        p.setDescripcion(req.getParameter("descripcion").trim());
        p.setPrecio(Double.parseDouble(req.getParameter("precio")));
        p.setIdCategoria(Integer.parseInt(req.getParameter("idCategoria")));
        p.setActivo(1);

        String fotoActual = req.getParameter("fotoActual");
        try {
            Part fotoPart = req.getPart("foto");
            String fotoGuardada = guardarFotoSiExiste(req, fotoPart);
            if (fotoGuardada != null) {
                p.setFoto(fotoGuardada);
            } else if (fotoActual != null && !fotoActual.isBlank()) {
                p.setFoto(fotoActual);
            } else {
                p.setFoto("img/default.jpg");
            }
        } catch (ServletException e) {
            throw new IOException("No se pudo procesar la imagen del plato.", e);
        }

        PlatoDAO dao = new PlatoDAO();
        if (p.getId() > 0) dao.actualizar(p);
        else dao.insertar(p);

        resp.sendRedirect("admin?accion=listarPlatos&ok=1");
    }

    private String guardarFotoSiExiste(HttpServletRequest req, Part fotoPart) throws IOException {
        if (fotoPart == null || fotoPart.getSize() == 0) {
            return null;
        }

        String nombreOriginal = extraerNombreArchivo(fotoPart);
        if (nombreOriginal.isBlank()) {
            return null;
        }

        String extension = "";
        int punto = nombreOriginal.lastIndexOf('.');
        if (punto >= 0) {
            extension = nombreOriginal.substring(punto);
        }

        // 1. Generar nombre seguro y la ruta que se guardará en la base de datos
        String nombreSeguro = UUID.randomUUID().toString().replace("-", "") + extension;
        String rutaRelativa = "img/" + nombreSeguro; // Ahora guarda todo directo en la carpeta img/

        // 2. Obtener la ruta física real del proyecto desplegado
        String appPath = req.getServletContext().getRealPath("");
        String rutaFisica = appPath + java.io.File.separator + "img";

        // 3. Crear la carpeta "img" si por alguna razón no existe
        java.io.File directorio = new java.io.File(rutaFisica);
        if (!directorio.exists()) {
            directorio.mkdirs();
        }

        // 4. Copiar el archivo usando InputStream (Esto EVITA el error de ruta duplicada de Payara)
        java.io.File archivoDestino = new java.io.File(directorio, nombreSeguro);
        try (java.io.InputStream input = fotoPart.getInputStream()) {
            java.nio.file.Files.copy(input, archivoDestino.toPath(), java.nio.file.StandardCopyOption.REPLACE_EXISTING);
        }

        return rutaRelativa;
    }

    private String extraerNombreArchivo(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        if (contentDisposition == null) {
            return "";
        }

        for (String segment : contentDisposition.split(";")) {
            String trimmed = segment.trim();
            if (trimmed.startsWith("filename=")) {
                String filename = trimmed.substring("filename=".length()).trim().replace("\"", "");
                int slash = Math.max(filename.lastIndexOf('/'), filename.lastIndexOf('\\'));
                return slash >= 0 ? filename.substring(slash + 1) : filename;
            }
        }
        return "";
    }

    private void eliminarPlato(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        new PlatoDAO().eliminar(id);
        resp.sendRedirect("admin?accion=listarPlatos&eliminado=1");
    }
    private void activarPlato(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        new PlatoDAO().activar(id);
        resp.sendRedirect(req.getContextPath() + "/admin?accion=listarPlatos&activado=1");
    }

    // ---------- CLIENTES ----------

    private void formCliente(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/vistas/admin/registrar-cliente.jsp").forward(req, resp);
    }

    private void editarCliente(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        Cliente c = new ClienteDAO().buscarPorId(id);
        if (c == null) { resp.sendRedirect("admin?accion=listarClientes"); return; }
        req.setAttribute("cliente", c);
        req.setAttribute("usuarioEditar", new UsuarioDAO().buscarPorId(c.getIdUsuario()));
        req.getRequestDispatcher("/vistas/admin/registrar-cliente.jsp").forward(req, resp);
    }

    private void actualizarCliente(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int id        = Integer.parseInt(req.getParameter("id"));
        int idUsuario = Integer.parseInt(req.getParameter("idUsuario"));
        String username = req.getParameter("username").trim();
        UsuarioDAO uDao = new UsuarioDAO();

        if (uDao.existeUsernameExcluyendo(username, idUsuario)) {
            ClienteDAO cDao = new ClienteDAO();
            Cliente c = cDao.buscarPorId(id);
            req.setAttribute("cliente", c);
            req.setAttribute("usuarioEditar", uDao.buscarPorId(idUsuario));
            req.setAttribute("error", "El nombre de usuario ya existe.");
            req.getRequestDispatcher("/vistas/admin/registrar-cliente.jsp").forward(req, resp);
            return;
        }

        Cliente c = new Cliente();
        c.setId(id);
        c.setNombres(req.getParameter("nombres").trim());
        c.setApellidos(req.getParameter("apellidos").trim());
        c.setDireccion(req.getParameter("direccion").trim());
        c.setCorreo(req.getParameter("correo").trim());
        c.setTelefono(req.getParameter("telefono").trim());
        new ClienteDAO().actualizar(c);
        uDao.actualizarCredenciales(idUsuario, username, req.getParameter("password").trim());

        resp.sendRedirect("admin?accion=listarClientes&editado=1");
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

        resp.sendRedirect("admin?accion=listarClientes&ok=1");
    }

    // ---------- EMPLEADOS ----------

    private void formEmpleado(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/vistas/admin/registrar-empleado.jsp").forward(req, resp);
    }

    private void editarEmpleado(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        Empleado e = new EmpleadoDAO().buscarPorId(id);
        if (e == null) { resp.sendRedirect("admin?accion=listarEmpleados"); return; }
        req.setAttribute("empleado", e);
        req.setAttribute("usuarioEditar", new UsuarioDAO().buscarPorId(e.getIdUsuario()));
        req.getRequestDispatcher("/vistas/admin/registrar-empleado.jsp").forward(req, resp);
    }

    private void actualizarEmpleado(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int id        = Integer.parseInt(req.getParameter("id"));
        int idUsuario = Integer.parseInt(req.getParameter("idUsuario"));
        String username = req.getParameter("username").trim();
        UsuarioDAO uDao   = new UsuarioDAO();
        EmpleadoDAO eDao  = new EmpleadoDAO();

        if (uDao.existeUsernameExcluyendo(username, idUsuario)) {
            Empleado e = eDao.buscarPorId(id);
            req.setAttribute("empleado", e);
            req.setAttribute("usuarioEditar", uDao.buscarPorId(idUsuario));
            req.setAttribute("error", "El nombre de usuario ya existe.");
            req.getRequestDispatcher("/vistas/admin/registrar-empleado.jsp").forward(req, resp);
            return;
        }

        Empleado e = new Empleado();
        e.setId(id);
        e.setNombres(req.getParameter("nombres").trim());
        e.setApellidos(req.getParameter("apellidos").trim());
        e.setCargo(req.getParameter("cargo").trim());
        e.setTelefono(req.getParameter("telefono").trim());
        e.setCorreo(req.getParameter("correo").trim());
        e.setFechaIngreso(req.getParameter("fechaIngreso").trim());
        eDao.actualizar(e);
        uDao.actualizarCredenciales(idUsuario, username, req.getParameter("password").trim());

        resp.sendRedirect("admin?accion=listarEmpleados&editado=1");
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

        int idUsr = uDao.insertar(username, req.getParameter("password").trim(), "EMPLEADO");
        Empleado e = new Empleado();
        e.setNombres(req.getParameter("nombres").trim());
        e.setApellidos(req.getParameter("apellidos").trim());
        e.setCedula(cedula);
        e.setCargo(req.getParameter("cargo").trim());
        e.setTelefono(req.getParameter("telefono").trim());
        e.setCorreo(req.getParameter("correo").trim());
        e.setFechaIngreso(req.getParameter("fechaIngreso").trim());
        e.setIdUsuario(idUsr);
        eDao.insertar(e);

        resp.sendRedirect("admin?accion=listarEmpleados&ok=1");
    }

    private void toggleCliente(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        int idUsuario = Integer.parseInt(req.getParameter("idUsuario"));
        new UsuarioDAO().toggleActivo(idUsuario);
        resp.sendRedirect("admin?accion=listarClientes");
    }

    private void toggleEmpleado(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        int idUsuario = Integer.parseInt(req.getParameter("idUsuario"));
        new UsuarioDAO().toggleActivo(idUsuario);
        resp.sendRedirect("admin?accion=listarEmpleados");
    }

    private boolean tieneAcceso(HttpServletRequest req, String perfil) {
        HttpSession s = req.getSession(false);
        if (s == null) return false;
        Usuario u = (Usuario) s.getAttribute("usuario");
        return u != null && perfil.equals(u.getPerfil());
    }
}
