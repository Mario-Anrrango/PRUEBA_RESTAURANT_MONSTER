package ec.edu.monster.restaurante.controlador;

import ec.edu.monster.restaurante.dao.*;
import ec.edu.monster.restaurante.modelo.*;
import ec.edu.monster.restaurante.util.ImageHandler;
import ec.edu.monster.restaurante.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@WebServlet("/admin")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,        // 1 MB
    maxFileSize = 5 * 1024 * 1024,          // 5 MB
    maxRequestSize = 5 * 1024 * 1024        // 5 MB
)
public class AdminServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!tieneAcceso(req, "ADMIN")) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html;charset=UTF-8");

        String accion = req.getParameter("accion");
        if (accion == null) accion = "dashboard";

        switch (accion) {
            case "listarPlatos":      listarPlatos(req, resp);               break;
            case "nuevoPlato":        mostrarFormPlato(req, resp, null);       break;
            case "editarPlato":       mostrarFormPlato(req, resp, req.getParameter("id")); break;
            case "eliminarPlato":     eliminarPlato(req, resp);               break;
            case "activarPlato":      activarPlato(req, resp);                break;
            case "formCliente":       formCliente(req, resp);                 break;
            case "editarCliente":     editarCliente(req, resp);              break;
            case "activarCliente":    activarCliente(req, resp);               break;
            case "desactivarCliente": desactivarCliente(req, resp);            break;
            case "formEmpleado":      formEmpleado(req, resp);                break;
            case "editarEmpleado":    editarEmpleado(req, resp);             break;
            case "activarEmpleado":   activarEmpleado(req, resp);             break;
            case "desactivarEmpleado":desactivarEmpleado(req, resp);          break;
            case "listarClientes":    listarClientes(req, resp);              break;
            case "listarEmpleados":   listarEmpleados(req, resp);             break;
            default:                  req.getRequestDispatcher("/vistas/admin/dashboard.jsp").forward(req, resp);
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
            case "actualizarPlato":    actualizarPlato(req, resp);      break;
            case "registrarCliente":   registrarCliente(req, resp);     break;
            case "actualizarCliente":  actualizarCliente(req, resp);   break;
            case "registrarEmpleado":  registrarEmpleado(req, resp);   break;
            case "actualizarEmpleado": actualizarEmpleado(req, resp);  break;
            case "resetPassword":      resetPassword(req, resp);       break;
            default: resp.sendRedirect("admin");
        }
    }

    // ---------- PLATOS ----------

    private void listarPlatos(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Obtener parámetros de paginación
        int pagina = 1;
        int registrosPorPagina = 5; // Default 5 registros
        if (req.getParameter("pagina") != null) {
            try { pagina = Integer.parseInt(req.getParameter("pagina")); } catch (NumberFormatException e) {}
        }
        if (req.getParameter("registros") != null) {
            try { registrosPorPagina = Integer.parseInt(req.getParameter("registros")); } catch (NumberFormatException e) {}
        }
        
        // Obtener filtro de categoría
        String categoriaFiltro = req.getParameter("categoria");
        
        try {
            PlatoDAO platoDAO = new PlatoDAO();
            CategoriaDAO categoriaDAO = new CategoriaDAO();
            
            // Obtener platos con paginación y filtro
            List<Plato> platos;
            int totalRegistros;
            
            if (categoriaFiltro != null && !categoriaFiltro.isEmpty() && !"TODOS".equals(categoriaFiltro)) {
                platos = platoDAO.listarPorCategoriaConPaginacion(categoriaFiltro, pagina, registrosPorPagina);
                totalRegistros = platoDAO.contarPorCategoria(categoriaFiltro);
            } else {
                platos = platoDAO.listarConPaginacion(pagina, registrosPorPagina);
                totalRegistros = platoDAO.contarTotal();
                categoriaFiltro = "TODOS";
            }
            
            int totalPaginas = (int) Math.ceil((double) totalRegistros / registrosPorPagina);
            if (totalPaginas < 1) totalPaginas = 1;
            
            // Obtener categorías para el filtro
            List<Categoria> categorias = categoriaDAO.listar();
            
            req.setAttribute("platos", platos);
            req.setAttribute("pagina", pagina);
            req.setAttribute("totalPaginas", totalPaginas);
            req.setAttribute("totalRegistros", totalRegistros);
            req.setAttribute("registrosPorPagina", registrosPorPagina);
            req.setAttribute("categoriaFiltro", categoriaFiltro);
            req.setAttribute("categorias", categorias);
            
            // Los mensajes se mantienen en session para que el JSP los lea con sessionScope
            // El propio JSP los elimina con <c:remove> despues de mostrarlos
            
            req.getRequestDispatcher("/vistas/admin/gestion-platos.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error al listar platos", e);
        }
    }

    private void mostrarFormPlato(HttpServletRequest req, HttpServletResponse resp, String id)
            throws ServletException, IOException {
        Plato plato = (id != null && !id.isEmpty()) ? new PlatoDAO().buscarPorId(id) : new Plato();
        req.setAttribute("plato", plato);
        req.setAttribute("categorias", new CategoriaDAO().listar());
        req.getRequestDispatcher("/vistas/admin/form-plato.jsp").forward(req, resp);
    }

    private void guardarPlato(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        String idCategoria = req.getParameter("idCategoria");
        
        // Obtener nombre de categoría para el directorio de imágenes
        CategoriaDAO cDao = new CategoriaDAO();
        Categoria cat = cDao.buscarPorId(idCategoria);
        String nombreCategoria = (cat != null) ? cat.getNombre() : "SIN_CATEGORIA";
        
        Plato p = new Plato();
        p.setNombre(req.getParameter("nombre").trim());
        p.setDescripcion(req.getParameter("descripcion").trim());
        p.setPrecio(new BigDecimal(req.getParameter("precio")));
        p.setIdCategoria(idCategoria);
        p.setActivo(true);

        // Procesar imagen
        Part filePart = req.getPart("foto");
        PlatoDAO dao = new PlatoDAO();
        HttpSession session = req.getSession();
        
        if (dao.insertar(p)) {
            // Buscar el plato recién creado para obtener su ID
            Plato creado = dao.buscarPorNombre(p.getNombre());
            if (creado != null && filePart != null && filePart.getSize() > 0) {
                if (!ImageHandler.isValidSize(filePart.getSize())) {
                    session.setAttribute("mensaje", "La imagen excede el tamaño máximo de 5MB");
                    session.setAttribute("tipoMensaje", "error");
                    resp.sendRedirect("admin?accion=listarPlatos");
                    return;
                }
                String rutaRelativa = ImageHandler.saveImage(filePart, creado.getId(), nombreCategoria);
                if (rutaRelativa != null) {
                    creado.setFoto(rutaRelativa);
                    dao.actualizar(creado);
                    session.setAttribute("mensaje", "Plato creado correctamente");
                    session.setAttribute("tipoMensaje", "success");
                } else {
                    session.setAttribute("mensaje", "Plato creado sin imagen. Formato no soportado. Use JPG, JPEG, PNG o WEBP");
                    session.setAttribute("tipoMensaje", "warning");
                }
            } else {
                session.setAttribute("mensaje", "Plato creado correctamente");
                session.setAttribute("tipoMensaje", "success");
            }
        } else {
            session.setAttribute("mensaje", "Error al crear el plato");
            session.setAttribute("tipoMensaje", "error");
        }
        resp.sendRedirect("admin?accion=listarPlatos");
    }

    private void actualizarPlato(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        String id = req.getParameter("id");
        String nombre = req.getParameter("nombre").trim();
        String idCategoria = req.getParameter("idCategoria");
        String precioStr = req.getParameter("precio");
        String descripcion = req.getParameter("descripcion").trim();
        String fotoActual = req.getParameter("fotoActual");
        
        HttpSession session = req.getSession();
        
        // Validaciones server-side
        java.util.List<String> errores = validarPlato(nombre, idCategoria, precioStr, descripcion);
        
        if (!errores.isEmpty()) {
            session.setAttribute("mensaje", String.join(" | ", errores));
            session.setAttribute("tipoMensaje", "error");
            resp.sendRedirect("admin?accion=editarPlato&id=" + id);
            return;
        }
        
        try {
            PlatoDAO platoDAO = new PlatoDAO();
            Plato plato = platoDAO.buscarPorId(id);
            
            if (plato == null) {
                session.setAttribute("mensaje", "Error: No se encontró el plato");
                session.setAttribute("tipoMensaje", "error");
                resp.sendRedirect("admin?accion=listarPlatos");
                return;
            }
            
            // Obtener nombre de categoría para el directorio
            CategoriaDAO cDao = new CategoriaDAO();
            Categoria cat = cDao.buscarPorId(idCategoria);
            String nombreCategoria = (cat != null) ? cat.getNombre() : "SIN_CATEGORIA";
            String categoriaAnteriorId = plato.getIdCategoria();
            
            // Actualizar datos básicos
            plato.setNombre(nombre);
            plato.setPrecio(new BigDecimal(precioStr));
            plato.setDescripcion(descripcion);
            plato.setIdCategoria(idCategoria);
            
            // Detectar si la foto actual está en formato antiguo (img/CATEGORIA/archivo)
            boolean esRutaAntigua = fotoActual != null && fotoActual.startsWith("img/");
            
            // Procesar foto
            Part filePart = req.getPart("foto");
            StringBuilder detalle = new StringBuilder();
            boolean fotoCambiada = false;
            boolean fotoMigrada = false;
            boolean categoriaCambiada = categoriaAnteriorId != null && !categoriaAnteriorId.equals(idCategoria);
            
            if (filePart != null && filePart.getSize() > 0) {
                // Se subió una foto NUEVA
                if (!ImageHandler.isValidSize(filePart.getSize())) {
                    session.setAttribute("mensaje", "La imagen excede el tamaño máximo de 5MB");
                    session.setAttribute("tipoMensaje", "error");
                    resp.sendRedirect("admin?accion=editarPlato&id=" + id);
                    return;
                }
                // Si la foto anterior es de ruta antigua, migrarla primero
                if (esRutaAntigua) {
                    String realPath = getServletContext().getRealPath("/");
                    // fotoActual ya contiene la ruta completa desde la raiz del WAR: "img/ENTRADA/bolon.jpg"
                    String oldAbsolutePath = realPath + "/" + fotoActual;
                    String extension = getFileExtension(fotoActual);
                    ImageHandler.migrateImage(oldAbsolutePath, plato.getId(), nombreCategoria, extension);
                    // La imagen nueva reemplazará a la migrada abajo
                } else {
                    // Eliminar foto anterior si existe (solo si es de ruta nueva)
                    if (fotoActual != null && !fotoActual.isEmpty()) {
                        ImageHandler.deleteImage(fotoActual);
                    }
                }
                // Guardar nueva imagen en la categoría actual
                String rutaRelativa = ImageHandler.saveImage(filePart, plato.getId(), nombreCategoria);
                if (rutaRelativa != null) {
                    plato.setFoto(rutaRelativa);
                    fotoCambiada = true;
                } else {
                    session.setAttribute("mensaje", "Formato de imagen no soportado. Use JPG, JPEG, PNG o WEBP");
                    session.setAttribute("tipoMensaje", "warning");
                }
            } else if (esRutaAntigua) {
                // No se subió foto nueva, pero la foto actual es de ruta antigua → migrar
                String realPath = getServletContext().getRealPath("/");
                // fotoActual ya contiene la ruta completa desde la raiz del WAR: "img/ENTRADA/bolon.jpg"
                String oldAbsolutePath = realPath + "/" + fotoActual;
                String extension = getFileExtension(fotoActual);
                String nuevaRuta = ImageHandler.migrateImage(oldAbsolutePath, plato.getId(), nombreCategoria, extension);
                plato.setFoto(nuevaRuta);
                fotoMigrada = true;
            } else if (categoriaCambiada && fotoActual != null && !fotoActual.isEmpty()) {
                // No se subió foto nueva, PERO cambió la categoría → mover imagen
                ImageHandler.moveImage(fotoActual, nombreCategoria, plato.getId());
                String extension = getFileExtension(fotoActual);
                plato.setFoto("platos/" + nombreCategoria + "/" + plato.getId() + extension);
            }
            // Si no se subió foto y no cambió categoría, mantener la foto existente
            
            platoDAO.actualizar(plato);
            
            // Mensaje detallado
            detalle.append("Plato actualizado correctamente");
            if (fotoCambiada && !fotoMigrada) detalle.append(" - Foto actualizada");
            if (categoriaCambiada) detalle.append(" - Categoría cambiada a ").append(nombreCategoria);
            
            session.setAttribute("mensaje", detalle.toString());
            session.setAttribute("tipoMensaje", "success");
            resp.sendRedirect("admin?accion=listarPlatos");
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("mensaje", "Error al actualizar: " + e.getMessage());
            session.setAttribute("tipoMensaje", "error");
            resp.sendRedirect("admin?accion=editarPlato&id=" + id);
        }
    }

    private void eliminarPlato(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String id = req.getParameter("id");
        HttpSession session = req.getSession();
        if (id != null && !id.isEmpty()) {
            new PlatoDAO().eliminar(id);
            session.setAttribute("mensaje", "Plato desactivado del menú");
            session.setAttribute("tipoMensaje", "success");
        }
        resp.sendRedirect("admin?accion=listarPlatos");
    }

    private void activarPlato(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String id = req.getParameter("id");
        String activo = req.getParameter("activo");
        HttpSession session = req.getSession();
        if (id != null && !id.isEmpty()) {
            PlatoDAO dao = new PlatoDAO();
            Plato p = dao.buscarPorId(id);
            if (p != null) {
                p.setActivo("true".equals(activo));
                dao.actualizar(p);
                session.setAttribute("mensaje", "Plato " + (p.isActivo() ? "activado" : "desactivado") + " correctamente");
                session.setAttribute("tipoMensaje", "success");
            }
        }
        resp.sendRedirect("admin?accion=listarPlatos");
    }

    // ---------- CLIENTES ----------

    private void formCliente(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/vistas/admin/registrar-cliente.jsp").forward(req, resp);
    }

    private void editarCliente(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String id = req.getParameter("id");
        if (id != null && !id.isEmpty()) {
            Cliente cliente = new ClienteDAO().buscarPorId(id);
            req.setAttribute("cliente", cliente);
        }
        req.getRequestDispatcher("/vistas/admin/registrar-cliente.jsp").forward(req, resp);
    }

    private void listarClientes(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        ClienteDAO cDao = new ClienteDAO();
        UsuarioDAO uDao = new UsuarioDAO();
        String busqueda = req.getParameter("busqueda");
        
        // Paginación
        int pagina = 1;
        int registrosPorPagina = 5;
        if (req.getParameter("pagina") != null) {
            try { pagina = Integer.parseInt(req.getParameter("pagina")); } catch (NumberFormatException e) {}
        }
        if (req.getParameter("registros") != null) {
            try { registrosPorPagina = Integer.parseInt(req.getParameter("registros")); } catch (NumberFormatException e) {}
        }
        
        List<Cliente> clientes;
        long totalRegistros;
        
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            clientes = cDao.buscarPorCedulaOIdentificacion(busqueda.trim());
            totalRegistros = clientes.size();
        } else {
            clientes = cDao.listarConPaginacion(pagina, registrosPorPagina);
            totalRegistros = cDao.contarTotal();
        }
        
        // Verificar estado activo de cada cliente (PROBLEMA 3)
        Map<String, Boolean> estadosActivos = new java.util.HashMap<>();
        for (Cliente c : clientes) {
            if (c.getIdUsuario() != null) {
                Usuario usr = uDao.buscarPorId(c.getIdUsuario());
                estadosActivos.put(c.getId(), usr != null ? usr.isActivo() : true);
            } else {
                estadosActivos.put(c.getId(), true);
            }
        }
        
        int totalPaginas = (int) Math.ceil((double) totalRegistros / registrosPorPagina);
        if (totalPaginas < 1) totalPaginas = 1;
        
        req.setAttribute("clientes", clientes);
        req.setAttribute("estadosActivos", estadosActivos);
        req.setAttribute("pagina", pagina);
        req.setAttribute("totalPaginas", totalPaginas);
        req.setAttribute("totalRegistros", totalRegistros);
        req.setAttribute("registrosPorPagina", registrosPorPagina);
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
        resp.sendRedirect("admin?accion=listarClientes");
    }

    private void actualizarCliente(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String id = req.getParameter("id");
        ClienteDAO cDao = new ClienteDAO();
        Cliente c = cDao.buscarPorId(id);
        HttpSession session = req.getSession();
        if (c != null) {
            c.setNombres(req.getParameter("nombres").trim());
            c.setApellidos(req.getParameter("apellidos").trim());
            c.setIdentificacionExtranjera(req.getParameter("identificacionExtranjera"));
            c.setEsExtranjero("on".equals(req.getParameter("esExtranjero")));
            c.setDireccion(req.getParameter("direccion").trim());
            c.setCorreo(req.getParameter("correo").trim());
            c.setTelefono(req.getParameter("telefono").trim());
            cDao.actualizar(c);
            session.setAttribute("mensaje", "Cliente actualizado correctamente");
            session.setAttribute("tipoMensaje", "success");
        }
        resp.sendRedirect("admin?accion=listarClientes");
    }

    // ---------- EMPLEADOS ----------

    private void formEmpleado(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/vistas/admin/registrar-empleado.jsp").forward(req, resp);
    }

    private void editarEmpleado(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String id = req.getParameter("id");
        if (id != null && !id.isEmpty()) {
            Empleado empleado = new EmpleadoDAO().buscarPorId(id);
            req.setAttribute("empleado", empleado);
        }
        req.getRequestDispatcher("/vistas/admin/registrar-empleado.jsp").forward(req, resp);
    }

    private void listarEmpleados(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        EmpleadoDAO eDao = new EmpleadoDAO();
        UsuarioDAO uDao = new UsuarioDAO();
        String busqueda = req.getParameter("busqueda");
        
        // Paginación
        int pagina = 1;
        int registrosPorPagina = 5;
        if (req.getParameter("pagina") != null) {
            try { pagina = Integer.parseInt(req.getParameter("pagina")); } catch (NumberFormatException e) {}
        }
        if (req.getParameter("registros") != null) {
            try { registrosPorPagina = Integer.parseInt(req.getParameter("registros")); } catch (NumberFormatException e) {}
        }
        
        List<Empleado> empleados;
        long totalRegistros;
        
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            empleados = eDao.buscarPorCedulaOIdentificacion(busqueda.trim());
            totalRegistros = empleados.size();
        } else {
            empleados = eDao.listarConPaginacion(pagina, registrosPorPagina);
            totalRegistros = eDao.contarTotal();
        }
        
        // Verificar estado activo de cada empleado (PROBLEMA 3)
        Map<String, Boolean> estadosActivos = new java.util.HashMap<>();
        for (Empleado e : empleados) {
            if (e.getIdUsuario() != null) {
                Usuario usr = uDao.buscarPorId(e.getIdUsuario());
                estadosActivos.put(e.getId(), usr != null ? usr.isActivo() : true);
            } else {
                estadosActivos.put(e.getId(), true);
            }
        }
        
        int totalPaginas = (int) Math.ceil((double) totalRegistros / registrosPorPagina);
        if (totalPaginas < 1) totalPaginas = 1;
        
        req.setAttribute("empleados", empleados);
        req.setAttribute("estadosActivos", estadosActivos);
        req.setAttribute("pagina", pagina);
        req.setAttribute("totalPaginas", totalPaginas);
        req.setAttribute("totalRegistros", totalRegistros);
        req.setAttribute("registrosPorPagina", registrosPorPagina);
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

        // Encriptar contraseña con BCrypt
        String password = req.getParameter("password").trim();
        String hashedPassword = PasswordUtil.hash(password);
        String idUsr = uDao.insertar(username, hashedPassword, "EMPLEADO");

        Empleado e = new Empleado();
        e.setNombres(req.getParameter("nombres").trim());
        e.setApellidos(req.getParameter("apellidos").trim());
        e.setCedula(cedula);
        e.setIdentificacionExtranjera(req.getParameter("identificacionExtranjera"));
        e.setEsExtranjero("on".equals(req.getParameter("esExtranjero")));
        e.setCargo(req.getParameter("cargo").trim());
        e.setTelefono(req.getParameter("telefono").trim());
        e.setCorreo(req.getParameter("correo").trim());
        e.setFechaIngreso(LocalDate.now()); // Fecha automática
        e.setIdUsuario(idUsr);
        eDao.insertar(e);
        
        HttpSession session = req.getSession();
        session.setAttribute("mensaje", "Empleado registrado correctamente");
        session.setAttribute("tipoMensaje", "success");
        resp.sendRedirect("admin?accion=listarEmpleados");
    }

    private void actualizarEmpleado(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String id = req.getParameter("id");
        EmpleadoDAO eDao = new EmpleadoDAO();
        UsuarioDAO uDao = new UsuarioDAO();
        Empleado e = eDao.buscarPorId(id);
        HttpSession session = req.getSession();
        if (e != null) {
            String cargoAnterior = e.getCargo();
            e.setNombres(req.getParameter("nombres").trim());
            e.setApellidos(req.getParameter("apellidos").trim());
            e.setIdentificacionExtranjera(req.getParameter("identificacionExtranjera"));
            e.setEsExtranjero("on".equals(req.getParameter("esExtranjero")));
            e.setCargo(req.getParameter("cargo").trim());
            e.setTelefono(req.getParameter("telefono").trim());
            e.setCorreo(req.getParameter("correo").trim());
            eDao.actualizar(e);
            
            // PROBLEMA 7: Sincronizar perfil del usuario con el cargo
            String nuevoPerfil = "Admin".equalsIgnoreCase(e.getCargo()) ? "ADMIN" : "EMPLEADO";
            String perfilAnterior = cargoAnterior != null ? ("Admin".equalsIgnoreCase(cargoAnterior) ? "ADMIN" : "EMPLEADO") : null;
            if (nuevoPerfil != null && !nuevoPerfil.equals(perfilAnterior) && e.getIdUsuario() != null) {
                uDao.actualizarPerfil(e.getIdUsuario(), nuevoPerfil);
            }
            
            session.setAttribute("mensaje", "Empleado actualizado correctamente");
            session.setAttribute("tipoMensaje", "success");
        }
        resp.sendRedirect("admin?accion=listarEmpleados");
    }

    // ---------- ACTIVAR/DESACTIVAR CLIENTE (solo usuarios tiene campo activo) ----------

    private void activarCliente(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String id = req.getParameter("id");
        HttpSession session = req.getSession();
        if (id != null && !id.isEmpty()) {
            ClienteDAO cDao = new ClienteDAO();
            UsuarioDAO uDao = new UsuarioDAO();
            Cliente c = cDao.buscarPorId(id);
            if (c != null) {
                uDao.activar(c.getIdUsuario());
                session.setAttribute("mensaje", "Cliente activado correctamente");
                session.setAttribute("tipoMensaje", "success");
            }
        }
        resp.sendRedirect("admin?accion=listarClientes");
    }

    private void desactivarCliente(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String id = req.getParameter("id");
        HttpSession session = req.getSession();
        if (id != null && !id.isEmpty()) {
            ClienteDAO cDao = new ClienteDAO();
            UsuarioDAO uDao = new UsuarioDAO();
            Cliente c = cDao.buscarPorId(id);
            if (c != null) {
                uDao.desactivar(c.getIdUsuario());
                session.setAttribute("mensaje", "Cliente desactivado correctamente");
                session.setAttribute("tipoMensaje", "success");
            }
        }
        resp.sendRedirect("admin?accion=listarClientes");
    }

    // ---------- ACTIVAR/DESACTIVAR EMPLEADO (solo usuarios tiene campo activo) ----------

    private void activarEmpleado(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String id = req.getParameter("id");
        HttpSession session = req.getSession();
        if (id != null && !id.isEmpty()) {
            EmpleadoDAO eDao = new EmpleadoDAO();
            UsuarioDAO uDao = new UsuarioDAO();
            Empleado e = eDao.buscarPorId(id);
            if (e != null) {
                uDao.activar(e.getIdUsuario());
                session.setAttribute("mensaje", "Empleado activado correctamente");
                session.setAttribute("tipoMensaje", "success");
            }
        }
        resp.sendRedirect("admin?accion=listarEmpleados");
    }

    private void desactivarEmpleado(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String id = req.getParameter("id");
        HttpSession session = req.getSession();
        if (id != null && !id.isEmpty()) {
            EmpleadoDAO eDao = new EmpleadoDAO();
            UsuarioDAO uDao = new UsuarioDAO();
            Empleado e = eDao.buscarPorId(id);
            if (e != null) {
                uDao.desactivar(e.getIdUsuario());
                session.setAttribute("mensaje", "Empleado desactivado correctamente");
                session.setAttribute("tipoMensaje", "success");
            }
        }
        resp.sendRedirect("admin?accion=listarEmpleados");
    }

    // ---------- HELPERS ----------

    private String getFileExtension(String fileName) {
        if (fileName == null || fileName.isEmpty()) {
            return ".jpg";
        }
        int lastDotIndex = fileName.lastIndexOf(".");
        if (lastDotIndex > 0) {
            return fileName.substring(lastDotIndex);
        }
        return ".jpg";
    }

    private java.util.List<String> validarPlato(String nombre, String idCategoria, String precioStr, String descripcion) {
        java.util.List<String> errores = new java.util.ArrayList<>();
        
        if (nombre.trim().length() < 4 || nombre.trim().length() > 50) {
            errores.add("Nombre: 4-50 caracteres");
        }
        if (!nombre.matches("^[a-zA-ZáéíóúÁÉÍÓÚñÑ\\s]+$")) {
            errores.add("Nombre: solo letras permitidas");
        }
        if (idCategoria == null || idCategoria.isEmpty() || "-- Seleccionar --".equals(idCategoria)) {
            errores.add("Debe seleccionar una categoría");
        }
        
        try {
            BigDecimal precio = new BigDecimal(precioStr);
            if (precio.compareTo(new BigDecimal("0.10")) < 0 || 
                precio.compareTo(new BigDecimal("99.99")) > 0) {
                errores.add("Precio: 0.10 a 99.99");
            }
        } catch (NumberFormatException e) {
            errores.add("Precio inválido");
        }
        
        if (descripcion.trim().length() < 10 || descripcion.trim().length() > 300) {
            errores.add("Descripción: 10-300 caracteres");
        }
        
        return errores;
    }

    // ---------- RESET PASSWORD ----------

    private void resetPassword(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String id = req.getParameter("id");
        String perfil = req.getParameter("perfil");
        String newPassword = req.getParameter("newPassword");

        HttpSession session = req.getSession();
        if (id != null && !id.isEmpty() && newPassword != null && !newPassword.isEmpty()) {
            String hashed = PasswordUtil.hash(newPassword);
            new UsuarioDAO().actualizarPassword(id, hashed);
            session.setAttribute("mensaje", "Contraseña actualizada correctamente");
            session.setAttribute("tipoMensaje", "success");
        } else {
            session.setAttribute("mensaje", "Error: Datos incompletos");
            session.setAttribute("tipoMensaje", "error");
        }

        if ("CLIENTE".equals(perfil)) {
            resp.sendRedirect("admin?accion=listarClientes");
        } else {
            resp.sendRedirect("admin?accion=listarEmpleados");
        }
    }

    // ---------- UTIL ----------

    private boolean tieneAcceso(HttpServletRequest req, String perfil) {
        HttpSession s = req.getSession(false);
        if (s == null) return false;
        Usuario u = (Usuario) s.getAttribute("usuario");
        return u != null && perfil.equals(u.getPerfil());
    }
}
