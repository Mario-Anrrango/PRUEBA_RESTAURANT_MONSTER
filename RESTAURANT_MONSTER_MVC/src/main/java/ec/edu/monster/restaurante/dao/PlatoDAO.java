package ec.edu.monster.restaurante.dao;

import ec.edu.monster.restaurante.modelo.Plato;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PlatoDAO {

    private Plato mapear(ResultSet rs) throws SQLException {
        Plato p = new Plato();
        p.setId(rs.getInt("id"));
        p.setNombre(rs.getString("nombre"));
        p.setDescripcion(rs.getString("descripcion"));
        p.setPrecio(rs.getDouble("precio"));
        p.setFoto(rs.getString("foto"));
        p.setIdCategoria(rs.getInt("id_categoria"));
        p.setActivo(rs.getInt("activo"));
        try { p.setNombreCategoria(rs.getString("nombre_cat")); } catch (SQLException ignored) {}
        return p;
    }

    public List<Plato> listarTodos() {
        List<Plato> lista = new ArrayList<>();
        String sql = "SELECT p.*, c.nombre AS nombre_cat FROM platos p JOIN categorias c ON p.id_categoria=c.id ORDER BY c.id, p.nombre";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }

    public List<Plato> listarActivos() {
        List<Plato> lista = new ArrayList<>();
        String sql = "SELECT p.*, c.nombre AS nombre_cat FROM platos p JOIN categorias c ON p.id_categoria=c.id WHERE p.activo=1 ORDER BY c.id, p.nombre";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }

    public List<Plato> listarPorCategoria(int idCategoria) {
        List<Plato> lista = new ArrayList<>();
        String sql = "SELECT p.*, c.nombre AS nombre_cat FROM platos p JOIN categorias c ON p.id_categoria=c.id WHERE p.id_categoria=? AND p.activo=1 ORDER BY p.nombre";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idCategoria);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) lista.add(mapear(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }

    public Plato buscarPorId(int id) {
        String sql = "SELECT p.*, c.nombre AS nombre_cat FROM platos p JOIN categorias c ON p.id_categoria=c.id WHERE p.id=?";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapear(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean insertar(Plato p) {
        String sql = "INSERT INTO platos (nombre,descripcion,precio,foto,id_categoria,activo) VALUES (?,?,?,?,?,1)";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, p.getNombre());
            ps.setString(2, p.getDescripcion());
            ps.setDouble(3, p.getPrecio());
            ps.setString(4, p.getFoto());
            ps.setInt(5, p.getIdCategoria());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean actualizar(Plato p) {
        String sql = "UPDATE platos SET nombre=?,descripcion=?,precio=?,foto=?,id_categoria=?,activo=? WHERE id=?";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, p.getNombre());
            ps.setString(2, p.getDescripcion());
            ps.setDouble(3, p.getPrecio());
            ps.setString(4, p.getFoto());
            ps.setInt(5, p.getIdCategoria());
            ps.setInt(6, p.getActivo());
            ps.setInt(7, p.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean eliminar(int id) {
        String sql = "UPDATE platos SET activo=0 WHERE id=?";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }
    
    public boolean activar(int id) {
        String sql = "UPDATE platos SET activo=1 WHERE id=?";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
        return false;
    }
}
