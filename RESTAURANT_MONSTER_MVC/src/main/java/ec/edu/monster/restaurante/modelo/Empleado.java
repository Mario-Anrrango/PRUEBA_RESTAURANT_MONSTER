package ec.edu.monster.restaurante.modelo;

import java.io.Serializable;

public class Empleado implements Serializable {

    private int id;
    private String nombres;
    private String apellidos;
    private String cedula;
    private String cargo;
    private String telefono;
    private String correo;
    private String fechaIngreso;
    private int idUsuario;
    private int activo;

    public Empleado() {}

    public int getId()                       { return id; }
    public void setId(int id)                { this.id = id; }

    public String getNombres()               { return nombres; }
    public void setNombres(String n)         { this.nombres = n; }

    public String getApellidos()             { return apellidos; }
    public void setApellidos(String a)       { this.apellidos = a; }

    public String getCedula()                { return cedula; }
    public void setCedula(String c)          { this.cedula = c; }

    public String getCargo()                 { return cargo; }
    public void setCargo(String c)           { this.cargo = c; }

    public String getTelefono()              { return telefono; }
    public void setTelefono(String t)        { this.telefono = t; }

    public String getCorreo()                { return correo; }
    public void setCorreo(String e)          { this.correo = e; }

    public String getFechaIngreso()          { return fechaIngreso; }
    public void setFechaIngreso(String f)    { this.fechaIngreso = f; }

    public int getIdUsuario()                { return idUsuario; }
    public void setIdUsuario(int u)          { this.idUsuario = u; }

    public int getActivo()                   { return activo; }
    public void setActivo(int a)             { this.activo = a; }

    public String getNombreCompleto()        { return nombres + " " + apellidos; }
}
