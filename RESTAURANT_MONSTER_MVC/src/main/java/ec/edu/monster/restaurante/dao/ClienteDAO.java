package ec.edu.monster.restaurante.dao;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Sorts;
import ec.edu.monster.restaurante.modelo.Cliente;
import org.bson.Document;
import org.bson.conversions.Bson;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class ClienteDAO {

    private MongoCollection<Document> collection;

    public ClienteDAO() {
        MongoDatabase db = MongoDBConnection.getDatabase();
        collection = db.getCollection("clientes");
    }

    public List<Cliente> listar() {
        List<Cliente> lista = new ArrayList<>();
        for (Document doc : collection.find().sort(new Document("apellidos", 1).append("nombres", 1))) {
            lista.add(mapearCliente(doc));
        }
        return lista;
    }
    
    public List<Cliente> listarConPaginacion(int pagina, int registrosPorPagina) {
        List<Cliente> lista = new ArrayList<>();
        int skip = (pagina - 1) * registrosPorPagina;
        if (skip < 0) skip = 0;
        for (Document doc : collection.find()
                .skip(skip)
                .limit(registrosPorPagina)
                .sort(Sorts.descending("created_at"))) {
            lista.add(mapearCliente(doc));
        }
        return lista;
    }
    
    public long contarTotal() {
        return collection.countDocuments();
    }
    
    public List<Cliente> buscarPorCedulaOIdentificacion(String valor) {
        List<Cliente> resultados = new ArrayList<>();
        Bson filtro = Filters.or(
            Filters.eq("cedula", valor),
            Filters.eq("identificacion_extranjera", valor)
        );
        for (Document doc : collection.find(filtro)) {
            resultados.add(mapearCliente(doc));
        }
        return resultados;
    }

    public Cliente buscarPorCedula(String cedula) {
        Document doc = collection.find(Filters.eq("cedula", cedula)).first();
        return doc != null ? mapearCliente(doc) : null;
    }

    public Cliente buscarPorIdentificacionExtranjera(String idExt) {
        Document doc = collection.find(Filters.eq("identificacion_extranjera", idExt)).first();
        return doc != null ? mapearCliente(doc) : null;
    }

    public Cliente buscarPorId(String id) {
        Document doc = collection.find(MongoDBConnection.filterById(id)).first();
        return doc != null ? mapearCliente(doc) : null;
    }

    public Cliente buscarPorIdUsuario(String idUsuario) {
        Document doc = collection.find(Filters.eq("id_usuario", idUsuario)).first();
        return doc != null ? mapearCliente(doc) : null;
    }

    public boolean insertar(Cliente c) {
        Document doc = new Document()
            .append("nombres", c.getNombres())
            .append("apellidos", c.getApellidos())
            .append("cedula", c.getCedula())
            .append("identificacion_extranjera", c.getIdentificacionExtranjera())
            .append("es_extranjero", c.isEsExtranjero())
            .append("direccion", c.getDireccion())
            .append("correo", c.getCorreo())
            .append("telefono", c.getTelefono())
            .append("id_usuario", c.getIdUsuario())
            .append("created_at", new java.util.Date());

        return collection.insertOne(doc).wasAcknowledged();
    }

    public boolean actualizar(Cliente c) {
        Document doc = new Document()
            .append("nombres", c.getNombres())
            .append("apellidos", c.getApellidos())
            .append("identificacion_extranjera", c.getIdentificacionExtranjera())
            .append("es_extranjero", c.isEsExtranjero())
            .append("direccion", c.getDireccion())
            .append("correo", c.getCorreo())
            .append("telefono", c.getTelefono());

        return collection.updateOne(
            MongoDBConnection.filterById(c.getId()),
            new Document("$set", doc)
        ).getModifiedCount() > 0;
    }

    public boolean activar(String id) {
        return collection.updateOne(
            MongoDBConnection.filterById(id),
            new Document("$set", new Document("activo", true))
        ).getModifiedCount() > 0;
    }

    public boolean desactivar(String id) {
        return collection.updateOne(
            MongoDBConnection.filterById(id),
            new Document("$set", new Document("activo", false))
        ).getModifiedCount() > 0;
    }

    public boolean existeCedula(String cedula) {
        return collection.find(Filters.eq("cedula", cedula)).first() != null;
    }

    private Cliente mapearCliente(Document doc) {
        Cliente c = new Cliente();
        c.setId(MongoDBConnection.extractId(doc));
        c.setNombres(doc.getString("nombres"));
        c.setApellidos(doc.getString("apellidos"));
        c.setCedula(doc.getString("cedula"));
        c.setIdentificacionExtranjera(doc.getString("identificacion_extranjera"));
        c.setEsExtranjero(doc.getBoolean("es_extranjero", false));
        c.setDireccion(doc.getString("direccion"));
        c.setCorreo(doc.getString("correo"));
        c.setTelefono(doc.getString("telefono"));
        c.setIdUsuario(doc.getString("id_usuario"));
        c.setCreated_at(MongoDBConnection.toLocalDateTime(doc, "created_at"));
        return c;
    }
}
