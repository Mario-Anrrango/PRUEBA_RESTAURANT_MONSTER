package ec.edu.monster.restaurante.controlador;

import ec.edu.monster.restaurante.dao.CategoriaDAO;
import ec.edu.monster.restaurante.dao.PedidoDAO;
import ec.edu.monster.restaurante.dao.PlatoDAO;
import ec.edu.monster.restaurante.modelo.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.*;
import java.math.BigDecimal;

@WebServlet("/menu")
public class MenuServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        Usuario u = (Usuario) session.getAttribute("usuario");
        if (!"CLIENTE".equals(u.getPerfil())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // PROBLEMA 2 + FASE 6.6: Manejar modificacion de pedido existente con platos inactivos
        String modificarId = req.getParameter("modificar");
        if (modificarId != null && !modificarId.isEmpty()) {
            PedidoDAO pedidoDAO = new PedidoDAO();
            PlatoDAO pDao = new PlatoDAO();
            Pedido pedido = pedidoDAO.buscarPorId(modificarId);
            
            if (pedido != null && "PENDIENTE".equals(pedido.getEstado())) {
                LocalDateTime creado = LocalDateTime.of(pedido.getFecha(), pedido.getHora());
                long horasTranscurridas = Duration.between(creado, LocalDateTime.now()).toHours();
                
                if (horasTranscurridas < 24) {
                    // FASE 6.6: Verificar estado de cada plato del pedido
                    List<DetallePedido> detalles = pedido.getDetalles();
                    boolean hayPlatosInactivos = false;
                    
                    if (detalles != null) {
                        for (DetallePedido detalle : detalles) {
                            Plato plato = pDao.buscarPorId(detalle.getIdPlato());
                            if (plato != null && !plato.isActivo()) {
                                hayPlatosInactivos = true;
                                detalle.setActivoEnBD(false);
                            }
                        }
                    }
                    
                    session.setAttribute("hayPlatosInactivos", hayPlatosInactivos);
                    session.setAttribute("pedidoModificando", pedido);
                    req.setAttribute("detallesModificar", detalles);
                    req.setAttribute("modificandoId", modificarId);
                    
                    // Cargar TODOS los platos activos agrupados
                    Map<String, List<Plato>> platosAgrupados = pDao.listarActivosAgrupados();
                    
                    // FASE 6.6: Agregar platos inactivos del pedido al mapa (key = id_categoria)
                    if (detalles != null) {
                        for (DetallePedido det : detalles) {
                            Plato platoInactivo = pDao.buscarPorId(det.getIdPlato());
                            if (platoInactivo != null && !platoInactivo.isActivo()) {
                                String catId = platoInactivo.getIdCategoria();
                                if (catId == null) catId = "";
                                List<Plato> lista = platosAgrupados.get(catId);
                                if (lista == null) {
                                    lista = new ArrayList<>();
                                    platosAgrupados.put(catId, lista);
                                }
                                lista.add(platoInactivo);
                            }
                        }
                    }
                    
                    req.setAttribute("platosPorCategoria", platosAgrupados);
                    req.setAttribute("categorias", new CategoriaDAO().listar());
                    req.setAttribute("modoModificacion", true);
                    req.getRequestDispatcher("/vistas/cliente/menu.jsp").forward(req, resp);
                    return;
                } else {
                    session.removeAttribute("pedidoModificando");
                    resp.sendRedirect(req.getContextPath() + "/reservas?error=noModificable");
                    return;
                }
            } else {
                session.removeAttribute("pedidoModificando");
                resp.sendRedirect(req.getContextPath() + "/reservas?error=noModificable");
                return;
            }
        } else {
            session.removeAttribute("pedidoModificando");
            session.removeAttribute("hayPlatosInactivos");
        }

        // PROBLEMA 1: Usar listarActivosAgrupados para evitar problemas de tipo id_categoria
        PlatoDAO pDao = new PlatoDAO();
        List<Categoria> categorias = new CategoriaDAO().listar();
        Map<String, List<Plato>> platosActivos = pDao.listarActivosAgrupados();
        
        // Organizar por categoria, filtrando solo las que tienen platos activos
        Map<String, List<Plato>> platosPorCategoria = new LinkedHashMap<>();
        for (Categoria cat : categorias) {
            List<Plato> platos = platosActivos.get(cat.getId());
            if (platos != null && !platos.isEmpty()) {
                platosPorCategoria.put(cat.getId(), platos);
            }
        }

        req.setAttribute("categorias", categorias);
        req.setAttribute("platosPorCategoria", platosPorCategoria);
        req.getRequestDispatcher("/vistas/cliente/menu.jsp").forward(req, resp);
    }
}
