package ec.edu.monster.restaurante.test;

import ec.edu.monster.restaurante.dao.MongoDBConnection;
import com.mongodb.client.MongoDatabase;
import org.bson.Document;

public class TestMongoDBConnection {
    public static void main(String[] args) {
        try {
            MongoDatabase db = MongoDBConnection.getDatabase();
            System.out.println("✅ Conexión exitosa a MongoDB");
            System.out.println("Base de datos: " + db.getName());

            // Verificar colecciones
            System.out.println("\n📋 Colecciones en la base de datos:");
            for (String name : db.listCollectionNames()) {
                long count = db.getCollection(name).countDocuments();
                System.out.println("  - " + name + ": " + count + " documentos");
            }

            // Probar consulta de categorías
            System.out.println("\n🍽️  Categorías:");
            for (Document doc : db.getCollection("categorias").find()) {
                System.out.println("  - " + doc.get("_id") + ": " + doc.getString("nombre"));
            }

            // Probar consulta de platos
            System.out.println("\n🍕 Total de platos: " + db.getCollection("platos").countDocuments());

            // Probar consulta de usuario admin
            System.out.println("\n👤 Usuario admin:");
            Document admin = db.getCollection("usuarios").find(new Document("username", "admin")).first();
            if (admin != null) {
                System.out.println("  - username: " + admin.getString("username"));
                System.out.println("  - perfil: " + admin.getString("perfil"));
            } else {
                System.out.println("  ❌ No se encontró el usuario admin");
            }

            MongoDBConnection.close();
            System.out.println("\n✅ Todas las pruebas de conexión pasaron");

        } catch (Exception e) {
            System.err.println("❌ Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
