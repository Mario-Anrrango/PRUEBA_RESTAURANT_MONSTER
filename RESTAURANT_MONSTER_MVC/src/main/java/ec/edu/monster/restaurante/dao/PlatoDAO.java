package ec.edu.monster.restaurante.dao;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Sorts;
import ec.edu.monster.restaurante.modelo.Plato;
import org.bson.Document;
import org.bson.conversions.Bson;
import org.bson.types.Decimal128;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class PlatoDAO {

    private MongoCollection<Document> collection;

    public PlatoDAO() {
        MongoDatabase db = MongoDBConnection.getDatabase();
        collection = db.getCollection("platos");
    }

    public List<Plato> listarTodos() {
        List<Plato> lista = new ArrayList<>();
        for (Document doc : collection.find()) {
            lista.add(mapearPlato(doc));
        }
        return lista;
    }

    public List<Plato> listarActivos() {
        List<Plato> lista = new ArrayList<>();
        for (Document doc : collection.find(Filters.eq("activo", true))) {
            lista.add(mapearPlato(doc));
        }
        return lista;
    }

    public List<Plato> listarPorCategoria(String idCategoria) {
        List<Plato> lista = new ArrayList<>();
        try {
            for (Document doc : collection.find(Filters.and(
                    Filters.eq("activo", true)
                ))) {
                Plato p = mapearPlato(doc);
                if (idCategoria.equals(p.getIdCategoria())) {
                    lista.add(p);
                }
            }
        } catch (Exception e) {
            System.err.println("Error en listarPorCategoria: " + e.getMessage());
        }
        return lista;
    }
    
    public Map<String, List<Plato>> listarActivosAgrupados() {
        Map<String, List<Plato>> agrupados = new java.util.LinkedHashMap<>();
        try {
            for (Document doc : collection.find(Filters.eq("activo", true))) {
                Plato p = mapearPlato(doc);
                String catId = p.getIdCategoria();
                if (catId == null) catId = "";
                agrupados.computeIfAbsent(catId, k -> new ArrayList<>()).add(p);
            }
        } catch (Exception e) {
            System.err.println("Error en listarActivosAgrupados: " + e.getMessage());
        }
        return agrupados;
    }

    public Plato buscarPorId(String id) {
        Document doc = collection.find(MongoDBConnection.filterById(id)).first();
        return doc != null ? mapearPlato(doc) : null;
    }

    public Plato buscarPorNombre(String nombre) {
        Document doc = collection.find(Filters.eq("nombre", nombre))
            .sort(new Document("created_at", -1))
            .first();
        return doc != null ? mapearPlato(doc) : null;
    }

    public boolean insertar(Plato p) {
        Document doc = new Document()
            .append("nombre", p.getNombre())
            .append("descripcion", p.getDescripcion())
            .append("precio", p.getPrecio() != null ? new Decimal128(p.getPrecio()) : new Decimal128(BigDecimal.ZERO))
            .append("foto", p.getFoto())
            .append("id_categoria", p.getIdCategoria())
            .append("activo", true)
            .append("created_at", new java.util.Date());

        return collection.insertOne(doc).wasAcknowledged();
    }

    public boolean actualizar(Plato p) {
        Document doc = new Document()
            .append("nombre", p.getNombre())
            .append("descripcion", p.getDescripcion())
            .append("precio", p.getPrecio() != null ? new Decimal128(p.getPrecio()) : new Decimal128(BigDecimal.ZERO))
            .append("foto", p.getFoto())
            .append("id_categoria", p.getIdCategoria())
            .append("activo", p.isActivo());

        return collection.updateOne(
            MongoDBConnection.filterById(p.getId()),
            new Document("$set", doc)
        ).getModifiedCount() > 0;
    }

    public boolean eliminar(String id) {
        return collection.updateOne(
            MongoDBConnection.filterById(id),
            new Document("$set", new Document("activo", false))
        ).getModifiedCount() > 0;
    }

    // ===== MÉTODOS DE PAGINACIÓN =====

    public List<Plato> listarConPaginacion(int pagina, int registrosPorPagina) {
        List<Plato> platos = new ArrayList<>();
        int skip = (pagina - 1) * registrosPorPagina;
        for (Document doc : collection.find()
                .sort(Sorts.ascending("nombre"))
                .skip(skip)
                .limit(registrosPorPagina)) {
            platos.add(mapearPlato(doc));
        }
        return platos;
    }

    public List<Plato> listarPorCategoriaConPaginacion(String categoria, int pagina, int registrosPorPagina) {
        List<Plato> platos = new ArrayList<>();
        int skip = (pagina - 1) * registrosPorPagina;
        // Manejar tanto id_categoria como string ("4") como numero (4) - compatibilidad migracion
        Bson filter = buildCategoriaFilter(categoria);
        for (Document doc : collection.find(filter)
                .sort(Sorts.ascending("nombre"))
                .skip(skip)
                .limit(registrosPorPagina)) {
            platos.add(mapearPlato(doc));
        }
        return platos;
    }

    public int contarTotal() {
        return (int) collection.countDocuments();
    }

    public int contarPorCategoria(String categoria) {
        Bson filter = buildCategoriaFilter(categoria);
        return (int) collection.countDocuments(filter);
    }

    // ===== FIN MÉTODOS DE PAGINACIÓN =====

    /**
     * Construye un filtro para id_categoria que funciona con datos migrados (integer) y nuevos (string).
     */
    private Bson buildCategoriaFilter(String categoria) {
        List<Bson> condiciones = new ArrayList<>();
        condiciones.add(Filters.eq("id_categoria", categoria)); // string: "4"
        try {
            int numericId = Integer.parseInt(categoria);
            condiciones.add(Filters.eq("id_categoria", numericId)); // int32: 4
        } catch (NumberFormatException e) {
            // No es un numero, solo usar string
        }
        if (condiciones.size() > 1) {
            return Filters.or(condiciones);
        }
        return condiciones.get(0);
    }

    private Plato mapearPlato(Document doc) {
        Plato p = new Plato();
        p.setId(MongoDBConnection.extractId(doc));
        p.setNombre(doc.getString("nombre"));
        p.setDescripcion(doc.getString("descripcion"));
        Object precioObj = doc.get("precio");
        if (precioObj instanceof Decimal128) {
            p.setPrecio(((Decimal128) precioObj).bigDecimalValue());
        } else if (precioObj instanceof Double) {
            p.setPrecio(BigDecimal.valueOf((Double) precioObj));
        } else if (precioObj instanceof Integer) {
            p.setPrecio(BigDecimal.valueOf((Integer) precioObj));
        } else if (precioObj instanceof String) {
            p.setPrecio(new BigDecimal((String) precioObj));
        }
        p.setFoto(doc.getString("foto"));
        String idCat = MongoDBConnection.extractString(doc, "id_categoria");
        p.setIdCategoria(idCat);
        if (idCat != null) {
            Document catDoc = MongoDBConnection.getDatabase().getCollection("categorias").find(
                com.mongodb.client.model.Filters.eq("_id",
                    idCat.matches("\\d+") ? Integer.parseInt(idCat) : idCat
                )
            ).first();
            if (catDoc != null) {
                p.setNombreCategoria(catDoc.getString("nombre"));
            }
        }
        p.setActivo(doc.getBoolean("activo", false));
        p.setCreated_at(MongoDBConnection.toLocalDateTime(doc, "created_at"));
        return p;
    }
}
