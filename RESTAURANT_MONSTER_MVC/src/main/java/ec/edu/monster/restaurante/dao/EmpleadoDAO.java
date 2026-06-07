package ec.edu.monster.restaurante.dao;

import ec.edu.monster.restaurante.modelo.Empleado;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EmpleadoDAO {

    private Empleado mapear(ResultSet rs) throws SQLException {
        Empleado e = new Empleado();
        e.setId(rs.getInt("id"));
        e.setNombres(rs.getString("nombres"));
        e.setApellidos(rs.getString("apellidos"));
        e.setCedula(rs.getString("cedula"));
        e.setCargo(rs.getString("cargo"));
        e.setTelefono(rs.getString("telefono"));
        e.setCorreo(rs.getString("correo"));
        e.setFechaIngreso(rs.getString("fecha_ingreso"));
        e.setIdUsuario(rs.getInt("id_usuario"));
        return e;
    }

    public List<Empleado> listar() {
        List<Empleado> lista = new ArrayList<>();
        String sql = "SELECT * FROM empleados ORDER BY apellidos, nombres";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }

    public Empleado buscarPorIdUsuario(int idUsuario) {
        String sql = "SELECT * FROM empleados WHERE id_usuario = ?";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapear(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean insertar(Empleado emp) {
        String sql = "INSERT INTO empleados (nombres,apellidos,cedula,cargo,telefono,correo,fecha_ingreso,id_usuario) VALUES (?,?,?,?,?,?,?,?)";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, emp.getNombres());
            ps.setString(2, emp.getApellidos());
            ps.setString(3, emp.getCedula());
            ps.setString(4, emp.getCargo());
            ps.setString(5, emp.getTelefono());
            ps.setString(6, emp.getCorreo());
            ps.setString(7, emp.getFechaIngreso());
            ps.setInt(8, emp.getIdUsuario());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean existeCedula(String cedula) {
        String sql = "SELECT id FROM empleados WHERE cedula = ?";
        try (Connection cn = ConexionDB.obtener();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, cedula);
            return ps.executeQuery().next();
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }
}
