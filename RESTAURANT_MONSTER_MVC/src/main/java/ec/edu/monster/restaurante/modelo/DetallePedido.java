package ec.edu.monster.restaurante.modelo;

import java.io.Serializable;

public class DetallePedido implements Serializable {

    private int id;
    private int idPedido;
    private int idPlato;
    private String nombrePlato;
    private String categoriaPlato;
    private int cantidad;
    private double precioUnitario;

    public DetallePedido() {}

    public int getId()                        { return id; }
    public void setId(int id)                 { this.id = id; }

    public int getIdPedido()                  { return idPedido; }
    public void setIdPedido(int p)            { this.idPedido = p; }

    public int getIdPlato()                   { return idPlato; }
    public void setIdPlato(int p)             { this.idPlato = p; }

    public String getNombrePlato()            { return nombrePlato; }
    public void setNombrePlato(String n)      { this.nombrePlato = n; }

    public String getCategoriaPlato()         { return categoriaPlato; }
    public void setCategoriaPlato(String c)   { this.categoriaPlato = c; }

    public int getCantidad()                  { return cantidad; }
    public void setCantidad(int c)            { this.cantidad = c; }

    public double getPrecioUnitario()         { return precioUnitario; }
    public void setPrecioUnitario(double p)   { this.precioUnitario = p; }

    public double getSubtotalLinea()          { return cantidad * precioUnitario; }
}
