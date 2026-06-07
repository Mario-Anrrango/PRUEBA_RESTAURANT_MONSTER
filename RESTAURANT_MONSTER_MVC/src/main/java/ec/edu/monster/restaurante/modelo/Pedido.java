package ec.edu.monster.restaurante.modelo;

import java.io.Serializable;
import java.util.List;

public class Pedido implements Serializable {

    private int id;
    private int idCliente;
    private String nombreCliente;
    private String cedulaCliente;
    private String correoCliente;
    private String telefonoCliente;
    private int idEmpleado;
    private String fecha;
    private String hora;
    private String estado;
    private double subtotal;
    private double iva;
    private double servicio;
    private double total;
    private List<DetallePedido> detalles;

    public Pedido() {}

    public int getId()                           { return id; }
    public void setId(int id)                    { this.id = id; }

    public int getIdCliente()                    { return idCliente; }
    public void setIdCliente(int c)              { this.idCliente = c; }

    public String getNombreCliente()             { return nombreCliente; }
    public void setNombreCliente(String n)       { this.nombreCliente = n; }

    public String getCedulaCliente()             { return cedulaCliente; }
    public void setCedulaCliente(String c)       { this.cedulaCliente = c; }

    public String getCorreoCliente()             { return correoCliente; }
    public void setCorreoCliente(String c)       { this.correoCliente = c; }

    public String getTelefonoCliente()           { return telefonoCliente; }
    public void setTelefonoCliente(String t)     { this.telefonoCliente = t; }

    public int getIdEmpleado()                   { return idEmpleado; }
    public void setIdEmpleado(int e)             { this.idEmpleado = e; }

    public String getFecha()                     { return fecha; }
    public void setFecha(String f)               { this.fecha = f; }

    public String getHora()                      { return hora; }
    public void setHora(String h)                { this.hora = h; }

    public String getEstado()                    { return estado; }
    public void setEstado(String e)              { this.estado = e; }

    public double getSubtotal()                  { return subtotal; }
    public void setSubtotal(double s)            { this.subtotal = s; }

    public double getIva()                       { return iva; }
    public void setIva(double i)                 { this.iva = i; }

    public double getServicio()                  { return servicio; }
    public void setServicio(double s)            { this.servicio = s; }

    public double getTotal()                     { return total; }
    public void setTotal(double t)               { this.total = t; }

    public List<DetallePedido> getDetalles()             { return detalles; }
    public void setDetalles(List<DetallePedido> detalles){ this.detalles = detalles; }
}
