package ec.edu.monster.restaurante.dao;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import ec.edu.monster.restaurante.modelo.Empleado;
import org.bson.Document;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class EmpleadoDAO {

    private MongoCollection<Document> collection;

    public EmpleadoDAO() {
        MongoDatabase db = MongoDBConnection.getDatabase();
        collection = db.getCollection("empleados");
    }

    public List<Empleado> listar() {
        List<Empleado> lista = new ArrayList<>();
        for (Document doc : collection.find().sort(new Document("apellidos", 1).append("nombres", 1))) {
            lista.add(mapearEmpleado(doc));
        }
        return lista;
    }

    public Empleado buscarPorIdUsuario(String idUsuario) {
        Document doc = collection.find(Filters.eq("id_usuario", idUsuario)).first();
        return doc != null ? mapearEmpleado(doc) : null;
    }

    public Empleado buscarPorCedula(String cedula) {
        Document doc = collection.find(Filters.eq("cedula", cedula)).first();
        return doc != null ? mapearEmpleado(doc) : null;
    }

    public boolean insertar(Empleado emp) {
        Document doc = new Document()
            .append("nombres", emp.getNombres())
            .append("apellidos", emp.getApellidos())
            .append("cedula", emp.getCedula())
            .append("cargo", emp.getCargo())
            .append("telefono", emp.getTelefono())
            .append("correo", emp.getCorreo())
            .append("fecha_ingreso", emp.getFechaIngreso() != null ? emp.getFechaIngreso().toString() : null)
            .append("id_usuario", emp.getIdUsuario())
            .append("created_at", LocalDateTime.now().toString());

        return collection.insertOne(doc).wasAcknowledged();
    }

    public boolean existeCedula(String cedula) {
        return collection.find(Filters.eq("cedula", cedula)).first() != null;
    }

    private Empleado mapearEmpleado(Document doc) {
        Empleado e = new Empleado();
        e.setId(MongoDBConnection.extractId(doc));
        e.setNombres(doc.getString("nombres"));
        e.setApellidos(doc.getString("apellidos"));
        e.setCedula(doc.getString("cedula"));
        e.setCargo(doc.getString("cargo"));
        e.setTelefono(doc.getString("telefono"));
        e.setCorreo(doc.getString("correo"));
        String fechaIngreso = MongoDBConnection.extractString(doc, "fecha_ingreso");
        if (fechaIngreso != null && !fechaIngreso.equals("null")) {
            e.setFechaIngreso(LocalDate.parse(fechaIngreso));
        }
        e.setIdUsuario(doc.getString("id_usuario"));
        e.setCreated_at(MongoDBConnection.toLocalDateTime(doc.getDate("created_at")));
        return e;
    }
}
