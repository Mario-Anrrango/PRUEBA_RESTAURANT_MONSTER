package ec.edu.monster.restaurante.dao;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import ec.edu.monster.restaurante.modelo.Cliente;
import org.bson.Document;
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

    public Cliente buscarPorCedula(String cedula) {
        Document doc = collection.find(Filters.eq("cedula", cedula)).first();
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
            .append("direccion", c.getDireccion())
            .append("correo", c.getCorreo())
            .append("telefono", c.getTelefono())
            .append("id_usuario", c.getIdUsuario())
            .append("created_at", LocalDateTime.now().toString());

        return collection.insertOne(doc).wasAcknowledged();
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
        c.setDireccion(doc.getString("direccion"));
        c.setCorreo(doc.getString("correo"));
        c.setTelefono(doc.getString("telefono"));
        c.setIdUsuario(doc.getString("id_usuario"));
        c.setCreated_at(MongoDBConnection.toLocalDateTime(doc.getDate("created_at")));
        return c;
    }
}
