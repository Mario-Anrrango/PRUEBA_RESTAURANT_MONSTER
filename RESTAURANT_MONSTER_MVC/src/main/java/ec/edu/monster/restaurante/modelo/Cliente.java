package ec.edu.monster.restaurante.modelo;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Cliente implements Serializable {

    private String id;
    private String nombres;
    private String apellidos;
    private String cedula;
    private String direccion;
    private String correo;
    private String telefono;
    private String idUsuario;
    private LocalDateTime created_at;

    public Cliente() {}

    public String getId()                     { return id; }
    public void setId(String id)              { this.id = id; }

    public String getNombres()                { return nombres; }
    public void setNombres(String n)          { this.nombres = n; }

    public String getApellidos()              { return apellidos; }
    public void setApellidos(String a)        { this.apellidos = a; }

    public String getCedula()                 { return cedula; }
    public void setCedula(String c)           { this.cedula = c; }

    public String getDireccion()              { return direccion; }
    public void setDireccion(String d)        { this.direccion = d; }

    public String getCorreo()                 { return correo; }
    public void setCorreo(String e)           { this.correo = e; }

    public String getTelefono()               { return telefono; }
    public void setTelefono(String t)         { this.telefono = t; }

    public String getIdUsuario()              { return idUsuario; }
    public void setIdUsuario(String u)        { this.idUsuario = u; }

    public LocalDateTime getCreated_at()      { return created_at; }
    public void setCreated_at(LocalDateTime created_at) { this.created_at = created_at; }

    public String getNombreCompleto()         { return nombres + " " + apellidos; }
}
