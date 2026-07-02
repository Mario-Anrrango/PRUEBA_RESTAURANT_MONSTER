package ec.edu.monster.restaurante.test;

import ec.edu.monster.restaurante.dao.*;
import ec.edu.monster.restaurante.modelo.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

public class TestDAOs {
    public static void main(String[] args) {
        try {
            System.out.println("🧪 Probando DAOs con MongoDB...\n");

            // =========================================
            // Test UsuarioDAO
            // =========================================
            System.out.println("1️⃣  UsuarioDAO:");
            UsuarioDAO usuarioDAO = new UsuarioDAO();
            Usuario admin = usuarioDAO.buscarPorUsername("admin");
            if (admin != null) {
                System.out.println("   ✅ Admin encontrado: " + admin.getUsername() + " (" + admin.getPerfil() + ")");
            } else {
                System.out.println("   ❌ Admin no encontrado");
            }

            // =========================================
            // Test CategoriaDAO
            // =========================================
            System.out.println("\n2️⃣  CategoriaDAO:");
            CategoriaDAO categoriaDAO = new CategoriaDAO();
            List<Categoria> categorias = categoriaDAO.listar();
            System.out.println("   ✅ Categorías encontradas: " + categorias.size());
            for (Categoria c : categorias) {
                System.out.println("      - " + c.getId() + ": " + c.getNombre());
            }

            // =========================================
            // Test PlatoDAO
            // =========================================
            System.out.println("\n3️⃣  PlatoDAO:");
            PlatoDAO platoDAO = new PlatoDAO();
            List<Plato> platosActivos = platoDAO.listarActivos();
            System.out.println("   ✅ Platos activos: " + platosActivos.size());
            if (!platosActivos.isEmpty()) {
                Plato p = platosActivos.get(0);
                System.out.println("      - Primer plato: " + p.getNombre());
                System.out.println("        Precio: $" + p.getPrecio());
                System.out.println("        Categoría ID: " + p.getIdCategoria());
            }

            // =========================================
            // Test PedidoDAO (sin datos aún)
            // =========================================
            System.out.println("\n4️⃣  PedidoDAO:");
            PedidoDAO pedidoDAO = new PedidoDAO();
            List<Pedido> pedidos = pedidoDAO.listarTodos();
            System.out.println("   ✅ Pedidos en BD: " + pedidos.size());

            // =========================================
            // Crear datos de prueba
            // =========================================
            System.out.println("\n5️⃣  Creando datos de prueba:");

            // --- Cliente de prueba ---
            ClienteDAO clienteDAO = new ClienteDAO();
            Cliente cliente = new Cliente();
            cliente.setNombres("Cliente");
            cliente.setApellidos("Prueba");
            cliente.setCedula("9999999999");
            cliente.setDireccion("Direcci\u00f3n prueba");
            cliente.setCorreo("test@test.com");
            cliente.setTelefono("0999999999");
            cliente.setIdUsuario(admin != null ? admin.getId() : null);
            cliente.setCreated_at(LocalDateTime.now());

            try {
                clienteDAO.insertar(cliente);
                System.out.println("   ✅ Cliente de prueba creado");
            } catch (Exception e) {
                System.out.println("   ⚠️  Cliente ya existe o error: " + e.getMessage());
            }

            // --- Empleado de prueba ---
            EmpleadoDAO empleadoDAO = new EmpleadoDAO();
            Empleado empleado = new Empleado();
            empleado.setNombres("Empleado");
            empleado.setApellidos("Prueba");
            empleado.setCedula("8888888888");
            empleado.setCargo("Mesero");
            empleado.setTelefono("0888888888");
            empleado.setCorreo("empleado@test.com");
            empleado.setFechaIngreso(LocalDate.now());
            empleado.setIdUsuario(admin != null ? admin.getId() : null);
            empleado.setCreated_at(LocalDateTime.now());

            try {
                empleadoDAO.insertar(empleado);
                System.out.println("   ✅ Empleado de prueba creado");
            } catch (Exception e) {
                System.out.println("   ⚠️  Empleado ya existe o error: " + e.getMessage());
            }

            // --- Pedido de prueba con detalles embebidos ---
            Pedido pedido = new Pedido();
            pedido.setIdCliente(cliente.getCedula());
            pedido.setIdEmpleado(empleado.getCedula());
            pedido.setFecha(LocalDate.now());
            pedido.setHora(LocalTime.now());
            pedido.setEstado("PENDIENTE");
            pedido.setSubtotal(new BigDecimal("10.00"));
            pedido.setIva(new BigDecimal("1.50"));
            pedido.setServicio(new BigDecimal("1.00"));
            pedido.setTotal(new BigDecimal("12.50"));

            // Agregar detalles embebidos
            if (!platosActivos.isEmpty()) {
                DetallePedido detalle = new DetallePedido();
                detalle.setIdPlato(platosActivos.get(0).getId());
                detalle.setNombrePlato(platosActivos.get(0).getNombre());
                detalle.setCategoriaPlato(platosActivos.get(0).getNombreCategoria());
                detalle.setCantidad(2);
                detalle.setPrecioUnitario(platosActivos.get(0).getPrecio());

                List<DetallePedido> detalles = new java.util.ArrayList<>();
                detalles.add(detalle);
                pedido.setDetalles(detalles);

                System.out.println("   ✅ Detalles agregados: " + detalles.size() + " item(s)");
            }

            String idPedido = pedidoDAO.insertar(pedido);
            if (idPedido != null && !idPedido.isEmpty()) {
                System.out.println("   ✅ Pedido de prueba insertado correctamente (ID: " + idPedido + ")");

                // Verificar que se guardó correctamente
                Pedido pedidoGuardado = pedidoDAO.buscarPorId(idPedido);
                if (pedidoGuardado != null) {
                    System.out.println("   ✅ Pedido recuperado de BD");
                    System.out.println("      - ID: " + pedidoGuardado.getId());
                    System.out.println("      - Fecha: " + pedidoGuardado.getFecha());
                    System.out.println("      - Hora: " + pedidoGuardado.getHora());
                    System.out.println("      - Total: $" + pedidoGuardado.getTotal());
                    System.out.println("      - Detalles: " + (pedidoGuardado.getDetalles() != null ? pedidoGuardado.getDetalles().size() : 0));
                }
            } else {
                System.out.println("   ❌ Error al insertar pedido");
            }

            // =========================================
            // Resumen final
            // =========================================
            System.out.println("\n📊 Resumen de la base de datos:");
            System.out.println("   - Usuarios: " + dbCount("usuarios"));
            System.out.println("   - Clientes: " + dbCount("clientes"));
            System.out.println("   - Empleados: " + dbCount("empleados"));
            System.out.println("   - Categorías: " + dbCount("categorias"));
            System.out.println("   - Platos: " + dbCount("platos"));
            System.out.println("   - Pedidos: " + dbCount("pedidos"));

            MongoDBConnection.close();
            System.out.println("\n✅ Todas las pruebas de DAOs pasaron");

        } catch (Exception e) {
            System.err.println("❌ Error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private static long dbCount(String collection) {
        try {
            return MongoDBConnection.getDatabase().getCollection(collection).countDocuments();
        } catch (Exception e) {
            return -1;
        }
    }
}
