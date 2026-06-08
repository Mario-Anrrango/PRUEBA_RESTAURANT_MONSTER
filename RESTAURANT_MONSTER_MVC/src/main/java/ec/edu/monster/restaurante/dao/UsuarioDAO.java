package ec.edu.monster.restaurante.dao;

import ec.edu.monster.restaurante.modelo.Usuario;
import java.sql.*;

public class UsuarioDAO {

    public Usuario autenticar(String username, String password) {
        String sql = "SELECT * FROM usuarios WHERE username = ? AND password = ? AND activo = 1";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Usuario u = new Usuario();
                u.setId(rs.getInt("id"));
                u.setUsername(rs.getString("username"));
                u.setPassword(rs.getString("password"));
                u.setPerfil(rs.getString("perfil"));
                u.setActivo(rs.getInt("activo"));
                return u;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public int insertar(String username, String password, String perfil) {
        String sql = "INSERT INTO usuarios (username, password, perfil) VALUES (?,?,?)";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, username);
            ps.setString(2, password);
            ps.setString(3, perfil);
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public Usuario buscarPorId(int id) {
        String sql = "SELECT * FROM usuarios WHERE id = ?";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Usuario u = new Usuario();
                u.setId(rs.getInt("id"));
                u.setUsername(rs.getString("username"));
                u.setPassword(rs.getString("password"));
                u.setPerfil(rs.getString("perfil"));
                u.setActivo(rs.getInt("activo"));
                return u;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean existeUsernameExcluyendo(String username, int idExcluir) {
        String sql = "SELECT id FROM usuarios WHERE username = ? AND id != ?";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setInt(2, idExcluir);
            return ps.executeQuery().next();
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean actualizarCredenciales(int id, String username, String passwordNueva) {
        try (Connection cn = ConexionDB.obtener()) {
            if (passwordNueva != null && !passwordNueva.isBlank()) {
                String sql = "UPDATE usuarios SET username=?, password=? WHERE id=?";
                try (PreparedStatement ps = cn.prepareStatement(sql)) {
                    ps.setString(1, username);
                    ps.setString(2, passwordNueva);
                    ps.setInt(3, id);
                    return ps.executeUpdate() > 0;
                }
            } else {
                String sql = "UPDATE usuarios SET username=? WHERE id=?";
                try (PreparedStatement ps = cn.prepareStatement(sql)) {
                    ps.setString(1, username);
                    ps.setInt(2, id);
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean toggleActivo(int id) {
        String sql = "UPDATE usuarios SET activo = IF(activo=1, 0, 1) WHERE id = ?";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean existeUsername(String username) {
        String sql = "SELECT id FROM usuarios WHERE username = ?";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
