package ec.edu.monster.restaurante.dao;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import com.mongodb.client.result.InsertOneResult;
import ec.edu.monster.restaurante.modelo.Usuario;
import org.bson.Document;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class UsuarioDAO {

    private MongoCollection<Document> collection;

    public UsuarioDAO() {
        MongoDatabase db = MongoDBConnection.getDatabase();
        collection = db.getCollection("usuarios");
    }

    public Usuario buscarPorUsername(String username) {
        Document doc = collection.find(Filters.eq("username", username)).first();
        return doc != null ? mapearUsuario(doc) : null;
    }

    public Usuario autenticar(String username, String password) {
        Document doc = collection.find(
            Filters.and(
                Filters.eq("username", username),
                Filters.eq("password", password),
                Filters.eq("activo", true)
            )
        ).first();
        return doc != null ? mapearUsuario(doc) : null;
    }

    public Usuario buscarPorId(String id) {
        Document doc = collection.find(MongoDBConnection.filterById(id)).first();
        return doc != null ? mapearUsuario(doc) : null;
    }

    public String insertar(String username, String password, String perfil) {
        Document doc = new Document()
            .append("username", username)
            .append("password", password)
            .append("perfil", perfil)
            .append("activo", true)
            .append("created_at", new java.util.Date());

        InsertOneResult result = collection.insertOne(doc);
        return result.getInsertedId().asObjectId().getValue().toHexString();
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

    public boolean actualizarPassword(String id, String newPassword) {
        return collection.updateOne(
            MongoDBConnection.filterById(id),
            new Document("$set", new Document("password", newPassword))
        ).getModifiedCount() > 0;
    }

    public boolean actualizarPerfil(String id, String nuevoPerfil) {
        return collection.updateOne(
            MongoDBConnection.filterById(id),
            new Document("$set", new Document("perfil", nuevoPerfil))
        ).getModifiedCount() > 0;
    }

    public boolean existeUsername(String username) {
        return collection.find(Filters.eq("username", username)).first() != null;
    }

    public boolean existeUsernameExcepto(String username, String exceptoId) {
        Document doc = collection.find(
            Filters.and(
                Filters.eq("username", username),
                Filters.ne("_id", MongoDBConnection.filterById(exceptoId))
            )
        ).first();
        return doc != null;
    }

    public List<Usuario> listarTodos() {
        List<Usuario> lista = new ArrayList<>();
        for (Document doc : collection.find()) {
            lista.add(mapearUsuario(doc));
        }
        return lista;
    }

    private Usuario mapearUsuario(Document doc) {
        Usuario u = new Usuario();
        u.setId(MongoDBConnection.extractId(doc));
        u.setUsername(doc.getString("username"));
        u.setPassword(doc.getString("password"));
        u.setPerfil(doc.getString("perfil"));
        u.setActivo(doc.getBoolean("activo", false));
        u.setCreated_at(MongoDBConnection.toLocalDateTime(doc, "created_at"));
        return u;
    }
}
