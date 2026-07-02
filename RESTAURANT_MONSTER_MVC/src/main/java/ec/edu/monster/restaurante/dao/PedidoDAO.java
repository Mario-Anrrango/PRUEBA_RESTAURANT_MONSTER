package ec.edu.monster.restaurante.dao;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import ec.edu.monster.restaurante.modelo.DetallePedido;
import ec.edu.monster.restaurante.modelo.Pedido;
import org.bson.Document;
import org.bson.types.Decimal128;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

public class PedidoDAO {

    private MongoCollection<Document> collection;

    public PedidoDAO() {
        MongoDatabase db = MongoDBConnection.getDatabase();
        collection = db.getCollection("pedidos");
    }

    public String insertar(Pedido pedido) {
        List<Document> detallesDoc = new ArrayList<>();
        if (pedido.getDetalles() != null) {
            for (DetallePedido d : pedido.getDetalles()) {
                Document detDoc = new Document()
                    .append("id_plato", d.getIdPlato())
                    .append("nombre", d.getNombrePlato())
                    .append("categoria", d.getCategoriaPlato())
                    .append("cantidad", d.getCantidad())
                    .append("precio_unitario", d.getPrecioUnitario() != null
                        ? new Decimal128(d.getPrecioUnitario())
                        : new Decimal128(BigDecimal.ZERO));
                detallesDoc.add(detDoc);
            }
        }

        Document doc = new Document()
            .append("id_cliente", pedido.getIdCliente())
            .append("id_empleado", pedido.getIdEmpleado())
            .append("fecha", pedido.getFecha() != null ? java.sql.Date.valueOf(pedido.getFecha()) : null)
            .append("hora", pedido.getHora() != null ? java.sql.Time.valueOf(pedido.getHora()) : null)
            .append("estado", "PENDIENTE")
            .append("subtotal", pedido.getSubtotal() != null
                ? new Decimal128(pedido.getSubtotal())
                : new Decimal128(BigDecimal.ZERO))
            .append("iva", pedido.getIva() != null
                ? new Decimal128(pedido.getIva())
                : new Decimal128(BigDecimal.ZERO))
            .append("servicio", pedido.getServicio() != null
                ? new Decimal128(pedido.getServicio())
                : new Decimal128(BigDecimal.ZERO))
            .append("total", pedido.getTotal() != null
                ? new Decimal128(pedido.getTotal())
                : new Decimal128(BigDecimal.ZERO))
            .append("detalles", detallesDoc);

        return collection.insertOne(doc).getInsertedId().asObjectId().getValue().toHexString();
    }

    public Pedido buscarPorId(String id) {
        Document doc = collection.find(MongoDBConnection.filterById(id)).first();
        return doc != null ? mapearPedido(doc) : null;
    }

    public List<Pedido> listarPorCliente(String idCliente) {
        List<Pedido> lista = new ArrayList<>();
        for (Document doc : collection.find(Filters.eq("id_cliente", idCliente))
                .sort(new Document("fecha", -1).append("hora", -1))) {
            lista.add(mapearPedidoResumen(doc));
        }
        return lista;
    }

    public List<Pedido> listarTodos() {
        List<Pedido> lista = new ArrayList<>();
        for (Document doc : collection.find()) {
            lista.add(mapearPedido(doc));
        }
        return lista;
    }

    public boolean marcarPagado(String idPedido) {
        return collection.updateOne(
            MongoDBConnection.filterById(idPedido),
            new Document("$set", new Document("estado", "PAGADO"))
        ).getModifiedCount() > 0;
    }

    public boolean cancelar(String idPedido) {
        return collection.updateOne(
            MongoDBConnection.filterById(idPedido),
            new Document("$set", new Document("estado", "CANCELADO"))
        ).getModifiedCount() > 0;
    }
    
    public boolean actualizarTodo(Pedido pedido) {
        List<Document> detallesDoc = new ArrayList<>();
        if (pedido.getDetalles() != null) {
            for (DetallePedido d : pedido.getDetalles()) {
                Document detDoc = new Document()
                    .append("id_plato", d.getIdPlato())
                    .append("nombre", d.getNombrePlato())
                    .append("categoria", d.getCategoriaPlato())
                    .append("cantidad", d.getCantidad())
                    .append("precio_unitario", d.getPrecioUnitario() != null
                        ? new Decimal128(d.getPrecioUnitario())
                        : new Decimal128(BigDecimal.ZERO));
                detallesDoc.add(detDoc);
            }
        }
        
        Document doc = new Document()
            .append("detalles", detallesDoc)
            .append("subtotal", pedido.getSubtotal() != null ? new Decimal128(pedido.getSubtotal()) : new Decimal128(BigDecimal.ZERO))
            .append("iva", pedido.getIva() != null ? new Decimal128(pedido.getIva()) : new Decimal128(BigDecimal.ZERO))
            .append("servicio", pedido.getServicio() != null ? new Decimal128(pedido.getServicio()) : new Decimal128(BigDecimal.ZERO))
            .append("total", pedido.getTotal() != null ? new Decimal128(pedido.getTotal()) : new Decimal128(BigDecimal.ZERO));

        return collection.updateOne(
            MongoDBConnection.filterById(pedido.getId()),
            new Document("$set", doc)
        ).getModifiedCount() > 0;
    }

    private Pedido mapearPedido(Document doc) {
        Pedido p = new Pedido();
        p.setId(MongoDBConnection.extractId(doc));
        p.setIdCliente(doc.getString("id_cliente"));
        p.setIdEmpleado(doc.getString("id_empleado"));
        p.setFecha(MongoDBConnection.toLocalDate(doc, "fecha"));
        p.setHora(MongoDBConnection.toLocalTime(doc, "hora"));
        p.setEstado(doc.getString("estado"));
        p.setSubtotal(extraerDecimal(doc, "subtotal"));
        p.setIva(extraerDecimal(doc, "iva"));
        p.setServicio(extraerDecimal(doc, "servicio"));
        p.setTotal(extraerDecimal(doc, "total"));

        // Cargar datos del cliente desde la colección clientes
        String idCliente = doc.getString("id_cliente");
        if (idCliente != null && !idCliente.isEmpty()) {
            Document clienteDoc = MongoDBConnection.getDatabase().getCollection("clientes")
                .find(MongoDBConnection.filterById(idCliente))
                .first();
            if (clienteDoc != null) {
                p.setNombreCliente(
                    clienteDoc.getString("nombres") + " " + clienteDoc.getString("apellidos")
                );
                p.setCedulaCliente(clienteDoc.getString("cedula"));
                p.setTelefonoCliente(clienteDoc.getString("telefono"));
                p.setCorreoCliente(clienteDoc.getString("correo"));
            }
        }

        List<DetallePedido> detalles = new ArrayList<>();
        List<Document> detallesDoc = doc.getList("detalles", Document.class);
        if (detallesDoc != null) {
            for (Document d : detallesDoc) {
                DetallePedido det = new DetallePedido();
                det.setIdPlato(d.getString("id_plato"));
                det.setNombrePlato(d.getString("nombre"));
                det.setCategoriaPlato(d.getString("categoria"));
                det.setCantidad(d.getInteger("cantidad", 1));
                det.setPrecioUnitario(extraerDecimal(d, "precio_unitario"));
                detalles.add(det);
            }
        }
        p.setDetalles(detalles);
        return p;
    }

    private Pedido mapearPedidoResumen(Document doc) {
        Pedido p = new Pedido();
        p.setId(MongoDBConnection.extractId(doc));
        p.setFecha(MongoDBConnection.toLocalDate(doc, "fecha"));
        p.setHora(MongoDBConnection.toLocalTime(doc, "hora"));
        p.setEstado(doc.getString("estado"));
        p.setTotal(extraerDecimal(doc, "total"));
        return p;
    }

    private BigDecimal extraerDecimal(Document doc, String campo) {
        Object valor = doc.get(campo);
        if (valor instanceof Decimal128) return ((Decimal128) valor).bigDecimalValue();
        if (valor instanceof Double) return BigDecimal.valueOf((Double) valor);
        if (valor instanceof Integer) return BigDecimal.valueOf((Integer) valor);
        if (valor instanceof String) return new BigDecimal((String) valor);
        return BigDecimal.ZERO;
    }
}
