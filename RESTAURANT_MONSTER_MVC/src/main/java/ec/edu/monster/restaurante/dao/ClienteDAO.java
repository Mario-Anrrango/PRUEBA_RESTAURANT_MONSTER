package ec.edu.monster.restaurante.dao;

import ec.edu.monster.restaurante.modelo.Cliente;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ClienteDAO {

    private Cliente mapear(ResultSet rs) throws SQLException {
        Cliente c = new Cliente();
        c.setId(rs.getInt("id"));
        c.setNombres(rs.getString("nombres"));
        c.setApellidos(rs.getString("apellidos"));
        c.setCedula(rs.getString("cedula"));
        c.setDireccion(rs.getString("direccion"));
        c.setCorreo(rs.getString("correo"));
        c.setTelefono(rs.getString("telefono"));
        c.setIdUsuario(rs.getInt("id_usuario"));
        try { c.setActivo(rs.getInt("activo")); } catch (SQLException ignored) {}
        return c;
    }

    public List<Cliente> listar() {
        List<Cliente> lista = new ArrayList<>();
        String sql = "SELECT c.*, u.activo FROM clientes c JOIN usuarios u ON c.id_usuario = u.id ORDER BY c.apellidos, c.nombres";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }

    public Cliente buscarPorCedula(String cedula) {
        String sql = "SELECT * FROM clientes WHERE cedula = ?";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, cedula);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapear(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public Cliente buscarPorId(int id) {
        String sql = "SELECT * FROM clientes WHERE id = ?";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapear(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public Cliente buscarPorIdUsuario(int idUsuario) {
        String sql = "SELECT * FROM clientes WHERE id_usuario = ?";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapear(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean insertar(Cliente c) {
        String sql = "INSERT INTO clientes (nombres,apellidos,cedula,direccion,correo,telefono,id_usuario) VALUES (?,?,?,?,?,?,?)";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, c.getNombres());
            ps.setString(2, c.getApellidos());
            ps.setString(3, c.getCedula());
            ps.setString(4, c.getDireccion());
            ps.setString(5, c.getCorreo());
            ps.setString(6, c.getTelefono());
            ps.setInt(7, c.getIdUsuario());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean actualizar(Cliente c) {
        String sql = "UPDATE clientes SET nombres=?,apellidos=?,direccion=?,correo=?,telefono=? WHERE id=?";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, c.getNombres());
            ps.setString(2, c.getApellidos());
            ps.setString(3, c.getDireccion());
            ps.setString(4, c.getCorreo());
            ps.setString(5, c.getTelefono());
            ps.setInt(6, c.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean existeCedula(String cedula) {
        String sql = "SELECT id FROM clientes WHERE cedula = ?";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, cedula);
            return ps.executeQuery().next();
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }
}
