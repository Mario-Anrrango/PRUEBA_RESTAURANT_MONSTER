package ec.edu.monster.restaurante.modelo;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Plato implements Serializable {

    private String id;
    private String nombre;
    private String descripcion;
    private BigDecimal precio;
    private String foto;
    private String idCategoria;
    private String nombreCategoria;
    private boolean activo;
    private LocalDateTime created_at;

    public Plato() {}

    public String getId()                          { return id; }
    public void setId(String id)                   { this.id = id; }

    public String getNombre()                      { return nombre; }
    public void setNombre(String n)                { this.nombre = n; }

    public String getDescripcion()                 { return descripcion; }
    public void setDescripcion(String d)           { this.descripcion = d; }

    public BigDecimal getPrecio()                  { return precio; }
    public void setPrecio(BigDecimal p)            { this.precio = p; }

    public String getFoto()                        { return foto; }
    public void setFoto(String f)                  { this.foto = f; }

    public String getIdCategoria()                 { return idCategoria; }
    public void setIdCategoria(String c)           { this.idCategoria = c; }

    public String getNombreCategoria()             { return nombreCategoria; }
    public void setNombreCategoria(String nc)      { this.nombreCategoria = nc; }

    public boolean isActivo()                      { return activo; }
    public boolean getActivo()                     { return activo; }
    public void setActivo(boolean a)               { this.activo = a; }

    public LocalDateTime getCreated_at()           { return created_at; }
    public void setCreated_at(LocalDateTime created_at) { this.created_at = created_at; }
}
