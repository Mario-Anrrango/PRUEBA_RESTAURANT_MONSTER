package ec.edu.monster.restaurante.modelo;

import java.io.Serializable;
import java.math.BigDecimal;

public class DetallePedido implements Serializable {

    private String id;
    private String idPedido;
    private String idPlato;
    private String nombrePlato;
    private String categoriaPlato;
    private int cantidad;
    private BigDecimal precioUnitario;

    public DetallePedido() {}

    public String getId()                        { return id; }
    public void setId(String id)                 { this.id = id; }

    public String getIdPedido()                  { return idPedido; }
    public void setIdPedido(String p)            { this.idPedido = p; }

    public String getIdPlato()                   { return idPlato; }
    public void setIdPlato(String p)             { this.idPlato = p; }

    public String getNombrePlato()               { return nombrePlato; }
    public void setNombrePlato(String n)         { this.nombrePlato = n; }

    public String getCategoriaPlato()            { return categoriaPlato; }
    public void setCategoriaPlato(String c)      { this.categoriaPlato = c; }

    public int getCantidad()                     { return cantidad; }
    public void setCantidad(int c)               { this.cantidad = c; }

    public BigDecimal getPrecioUnitario()        { return precioUnitario; }
    public void setPrecioUnitario(BigDecimal p)  { this.precioUnitario = p; }

    public BigDecimal getSubtotalLinea()         { return precioUnitario.multiply(BigDecimal.valueOf(cantidad)); }
}
