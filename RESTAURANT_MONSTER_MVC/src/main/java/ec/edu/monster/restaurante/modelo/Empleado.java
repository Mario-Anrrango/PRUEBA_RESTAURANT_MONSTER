package ec.edu.monster.restaurante.modelo;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class Empleado implements Serializable {

    private String id;
    private String nombres;
    private String apellidos;
    private String cedula;
    private String cargo;
    private String telefono;
    private String correo;
    private LocalDate fechaIngreso;
    private String idUsuario;
    private LocalDateTime created_at;

    public Empleado() {}

    public String getId()                       { return id; }
    public void setId(String id)                { this.id = id; }

    public String getNombres()                  { return nombres; }
    public void setNombres(String n)            { this.nombres = n; }

    public String getApellidos()                { return apellidos; }
    public void setApellidos(String a)          { this.apellidos = a; }

    public String getCedula()                   { return cedula; }
    public void setCedula(String c)             { this.cedula = c; }

    public String getCargo()                    { return cargo; }
    public void setCargo(String c)              { this.cargo = c; }

    public String getTelefono()                 { return telefono; }
    public void setTelefono(String t)           { this.telefono = t; }

    public String getCorreo()                   { return correo; }
    public void setCorreo(String e)             { this.correo = e; }

    public LocalDate getFechaIngreso()          { return fechaIngreso; }
    public void setFechaIngreso(LocalDate f)    { this.fechaIngreso = f; }

    public String getIdUsuario()                { return idUsuario; }
    public void setIdUsuario(String u)          { this.idUsuario = u; }

    public LocalDateTime getCreated_at()        { return created_at; }
    public void setCreated_at(LocalDateTime created_at) { this.created_at = created_at; }

    public String getNombreCompleto()           { return nombres + " " + apellidos; }
}
