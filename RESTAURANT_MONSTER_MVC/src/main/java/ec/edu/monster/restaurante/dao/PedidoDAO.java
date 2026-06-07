package ec.edu.monster.restaurante.dao;

import ec.edu.monster.restaurante.modelo.DetallePedido;
import ec.edu.monster.restaurante.modelo.Pedido;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PedidoDAO {

    public int insertar(Pedido pedido) {
        String sql = "INSERT INTO pedidos (id_cliente,id_empleado,fecha,hora,estado,subtotal,iva,servicio,total) VALUES (?,?,?,?,?,?,?,?,?)";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, pedido.getIdCliente());
            if (pedido.getIdEmpleado() > 0) ps.setInt(2, pedido.getIdEmpleado());
            else ps.setNull(2, Types.INTEGER);
            ps.setString(3, pedido.getFecha());
            ps.setString(4, pedido.getHora());
            ps.setString(5, "PENDIENTE");
            ps.setDouble(6, pedido.getSubtotal());
            ps.setDouble(7, pedido.getIva());
            ps.setDouble(8, pedido.getServicio());
            ps.setDouble(9, pedido.getTotal());
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return -1;
    }

    public boolean insertarDetalle(DetallePedido d) {
        String sql = "INSERT INTO detalle_pedido (id_pedido,id_plato,cantidad,precio_unitario) VALUES (?,?,?,?)";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, d.getIdPedido());
            ps.setInt(2, d.getIdPlato());
            ps.setInt(3, d.getCantidad());
            ps.setDouble(4, d.getPrecioUnitario());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public Pedido buscarPorId(int id) {
        String sql = "SELECT p.*, c.nombres, c.apellidos, c.cedula, c.correo, c.telefono " +
                     "FROM pedidos p JOIN clientes c ON p.id_cliente=c.id WHERE p.id=?";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Pedido ped = new Pedido();
                ped.setId(rs.getInt("id"));
                ped.setIdCliente(rs.getInt("id_cliente"));
                ped.setNombreCliente(rs.getString("nombres") + " " + rs.getString("apellidos"));
                ped.setCedulaCliente(rs.getString("cedula"));
                ped.setCorreoCliente(rs.getString("correo"));
                ped.setTelefonoCliente(rs.getString("telefono"));
                ped.setFecha(rs.getString("fecha"));
                ped.setHora(rs.getString("hora"));
                ped.setEstado(rs.getString("estado"));
                ped.setSubtotal(rs.getDouble("subtotal"));
                ped.setIva(rs.getDouble("iva"));
                ped.setServicio(rs.getDouble("servicio"));
                ped.setTotal(rs.getDouble("total"));
                ped.setDetalles(listarDetalles(id));
                return ped;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public List<DetallePedido> listarDetalles(int idPedido) {
        List<DetallePedido> lista = new ArrayList<>();
        String sql = "SELECT dp.*, pl.nombre AS nombre_plato, c.nombre AS cat FROM detalle_pedido dp " +
                     "JOIN platos pl ON dp.id_plato=pl.id JOIN categorias c ON pl.id_categoria=c.id WHERE dp.id_pedido=?";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idPedido);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                DetallePedido d = new DetallePedido();
                d.setId(rs.getInt("id"));
                d.setIdPedido(rs.getInt("id_pedido"));
                d.setIdPlato(rs.getInt("id_plato"));
                d.setNombrePlato(rs.getString("nombre_plato"));
                d.setCategoriaPlato(rs.getString("cat"));
                d.setCantidad(rs.getInt("cantidad"));
                d.setPrecioUnitario(rs.getDouble("precio_unitario"));
                lista.add(d);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }

    public boolean marcarPagado(int idPedido) {
        String sql = "UPDATE pedidos SET estado='PAGADO' WHERE id=?";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idPedido);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public List<Pedido> listarPorCliente(int idCliente) {
        List<Pedido> lista = new ArrayList<>();
        String sql = "SELECT * FROM pedidos WHERE id_cliente=? ORDER BY fecha DESC, hora DESC";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idCliente);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Pedido p = new Pedido();
                p.setId(rs.getInt("id"));
                p.setFecha(rs.getString("fecha"));
                p.setHora(rs.getString("hora"));
                p.setEstado(rs.getString("estado"));
                p.setTotal(rs.getDouble("total"));
                lista.add(p);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }
}
