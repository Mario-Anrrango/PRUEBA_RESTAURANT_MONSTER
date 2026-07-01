package ec.edu.monster.restaurante.dao;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import org.bson.Document;
import org.bson.conversions.Bson;
import org.bson.types.ObjectId;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.Date;

public class MongoDBConnection {

    private static final String URI = "mongodb://localhost:27017";
    private static final String DATABASE_NAME = "restaurant_monster";

    private static MongoClient mongoClient;
    private static MongoDatabase database;

    public static MongoDatabase getDatabase() {
        if (database == null) {
            mongoClient = MongoClients.create(URI);
            database = mongoClient.getDatabase(DATABASE_NAME);
        }
        return database;
    }

    public static void close() {
        if (mongoClient != null) {
            mongoClient.close();
            mongoClient = null;
            database = null;
        }
    }

    // ========== Helpers for _id handling ==========

    /**
     * Extrae el _id de un Document como String, funcionando con ObjectId y otros tipos.
     */
    public static String extractId(Document doc) {
        Object id = doc.get("_id");
        if (id instanceof ObjectId) {
            return ((ObjectId) id).toHexString();
        }
        return String.valueOf(id);
    }

    /**
     * Crea un filtro por _id que funciona tanto con ObjectId como con Strings/números.
     */
    public static Bson filterById(String id) {
        if (ObjectId.isValid(id)) {
            return Filters.eq("_id", new ObjectId(id));
        }
        return Filters.eq("_id", id);
    }

    // ========== Helpers for Date/LocalDate/LocalTime conversion ==========

    public static LocalDateTime toLocalDateTime(Date date) {
        if (date == null) return null;
        return date.toInstant().atZone(ZoneId.systemDefault()).toLocalDateTime();
    }

    public static LocalDate toLocalDate(Date date) {
        if (date == null) return null;
        return date.toInstant().atZone(ZoneId.systemDefault()).toLocalDate();
    }

    public static LocalTime toLocalTime(Date date) {
        if (date == null) return null;
        return date.toInstant().atZone(ZoneId.systemDefault()).toLocalTime();
    }

    /**
     * Extrae un String de un campo, manejando tanto String como otros tipos.
     */
    public static String extractString(Document doc, String field) {
        Object val = doc.get(field);
        return val != null ? String.valueOf(val) : null;
    }
}
