package ec.edu.monster.restaurante.dao;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import ec.edu.monster.restaurante.modelo.Categoria;
import org.bson.Document;
import java.util.ArrayList;
import java.util.List;

public class CategoriaDAO {

    private MongoCollection<Document> collection;

    public CategoriaDAO() {
        MongoDatabase db = MongoDBConnection.getDatabase();
        collection = db.getCollection("categorias");
    }

    public List<Categoria> listar() {
        List<Categoria> lista = new ArrayList<>();
        for (Document doc : collection.find().sort(new Document("_id", 1))) {
            lista.add(mapearCategoria(doc));
        }
        return lista;
    }

    public Categoria buscarPorId(String id) {
        Document doc = collection.find(MongoDBConnection.filterById(id)).first();
        return doc != null ? mapearCategoria(doc) : null;
    }

    public Categoria buscarPorNombre(String nombre) {
        Document doc = collection.find(Filters.eq("nombre", nombre)).first();
        return doc != null ? mapearCategoria(doc) : null;
    }

    private Categoria mapearCategoria(Document doc) {
        Categoria c = new Categoria();
        c.setId(MongoDBConnection.extractId(doc));
        c.setNombre(doc.getString("nombre"));
        return c;
    }
}
