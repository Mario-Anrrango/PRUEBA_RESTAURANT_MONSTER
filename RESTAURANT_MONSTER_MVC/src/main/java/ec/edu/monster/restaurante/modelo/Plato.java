package ec.edu.monster.restaurante.modelo;

import java.io.Serializable;

public class Plato implements Serializable {

    private int id;
    private String nombre;
    private String descripcion;
    private double precio;
    private String foto;
    private int idCategoria;
    private String nombreCategoria;
    private int activo;

    public Plato() {}

    public int getId()                          { return id; }
    public void setId(int id)                   { this.id = id; }

    public String getNombre()                   { return nombre; }
    public void setNombre(String n)             { this.nombre = n; }

    public String getDescripcion()              { return descripcion; }
    public void setDescripcion(String d)        { this.descripcion = d; }

    public double getPrecio()                   { return precio; }
    public void setPrecio(double p)             { this.precio = p; }

    public String getFoto()                     { return foto; }
    public void setFoto(String f)               { this.foto = f; }

    public int getIdCategoria()                 { return idCategoria; }
    public void setIdCategoria(int c)           { this.idCategoria = c; }

    public String getNombreCategoria()          { return nombreCategoria; }
    public void setNombreCategoria(String nc)   { this.nombreCategoria = nc; }

    public int getActivo()                      { return activo; }
    public void setActivo(int a)                { this.activo = a; }
}
