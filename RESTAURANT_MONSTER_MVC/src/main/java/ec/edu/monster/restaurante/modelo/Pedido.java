package ec.edu.monster.restaurante.modelo;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

public class Pedido implements Serializable {

    private String id;
    private String idCliente;
    private String nombreCliente;
    private String cedulaCliente;
    private String correoCliente;
    private String telefonoCliente;
    private String idEmpleado;
    private LocalDate fecha;
    private LocalTime hora;
    private String estado;
    private BigDecimal subtotal;
    private BigDecimal iva;
    private BigDecimal servicio;
    private BigDecimal total;
    private List<DetallePedido> detalles;

    public Pedido() {}

    public String getId()                               { return id; }
    public void setId(String id)                        { this.id = id; }

    public String getIdCliente()                        { return idCliente; }
    public void setIdCliente(String c)                  { this.idCliente = c; }

    public String getNombreCliente()                    { return nombreCliente; }
    public void setNombreCliente(String n)              { this.nombreCliente = n; }

    public String getCedulaCliente()                    { return cedulaCliente; }
    public void setCedulaCliente(String c)              { this.cedulaCliente = c; }

    public String getCorreoCliente()                    { return correoCliente; }
    public void setCorreoCliente(String c)              { this.correoCliente = c; }

    public String getTelefonoCliente()                  { return telefonoCliente; }
    public void setTelefonoCliente(String t)            { this.telefonoCliente = t; }

    public String getIdEmpleado()                       { return idEmpleado; }
    public void setIdEmpleado(String e)                 { this.idEmpleado = e; }

    public LocalDate getFecha()                         { return fecha; }
    public void setFecha(LocalDate f)                   { this.fecha = f; }

    public LocalTime getHora()                          { return hora; }
    public void setHora(LocalTime h)                    { this.hora = h; }

    public String getEstado()                           { return estado; }
    public void setEstado(String e)                     { this.estado = e; }

    public BigDecimal getSubtotal()                     { return subtotal; }
    public void setSubtotal(BigDecimal s)               { this.subtotal = s; }

    public BigDecimal getIva()                          { return iva; }
    public void setIva(BigDecimal i)                    { this.iva = i; }

    public BigDecimal getServicio()                     { return servicio; }
    public void setServicio(BigDecimal s)               { this.servicio = s; }

    public BigDecimal getTotal()                        { return total; }
    public void setTotal(BigDecimal t)                  { this.total = t; }

    public List<DetallePedido> getDetalles()             { return detalles; }
    public void setDetalles(List<DetallePedido> detalles){ this.detalles = detalles; }
}
