package ec.edu.monster.restaurante.dao;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Sorts;
import ec.edu.monster.restaurante.modelo.Empleado;
import org.bson.Document;
import org.bson.conversions.Bson;
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
    
    public List<Empleado> listarConPaginacion(int pagina, int registrosPorPagina) {
        List<Empleado> lista = new ArrayList<>();
        int skip = (pagina - 1) * registrosPorPagina;
        if (skip < 0) skip = 0;
        for (Document doc : collection.find()
                .skip(skip)
                .limit(registrosPorPagina)
                .sort(Sorts.descending("created_at"))) {
            lista.add(mapearEmpleado(doc));
        }
        return lista;
    }
    
    public long contarTotal() {
        return collection.countDocuments();
    }
    
    public List<Empleado> buscarPorCedulaOIdentificacion(String valor) {
        List<Empleado> resultados = new ArrayList<>();
        Bson filtro = Filters.or(
            Filters.eq("cedula", valor),
            Filters.eq("identificacion_extranjera", valor)
        );
        for (Document doc : collection.find(filtro)) {
            resultados.add(mapearEmpleado(doc));
        }
        return resultados;
    }

    public Empleado buscarPorId(String id) {
        Document doc = collection.find(MongoDBConnection.filterById(id)).first();
        return doc != null ? mapearEmpleado(doc) : null;
    }

    public Empleado buscarPorIdUsuario(String idUsuario) {
        Document doc = collection.find(Filters.eq("id_usuario", idUsuario)).first();
        return doc != null ? mapearEmpleado(doc) : null;
    }

    public Empleado buscarPorCedula(String cedula) {
        Document doc = collection.find(Filters.eq("cedula", cedula)).first();
        return doc != null ? mapearEmpleado(doc) : null;
    }

    public Empleado buscarPorIdentificacionExtranjera(String idExt) {
        Document doc = collection.find(Filters.eq("identificacion_extranjera", idExt)).first();
        return doc != null ? mapearEmpleado(doc) : null;
    }

    public boolean insertar(Empleado emp) {
        Document doc = new Document()
            .append("nombres", emp.getNombres())
            .append("apellidos", emp.getApellidos())
            .append("cedula", emp.getCedula())
            .append("identificacion_extranjera", emp.getIdentificacionExtranjera())
            .append("es_extranjero", emp.isEsExtranjero())
            .append("cargo", emp.getCargo())
            .append("telefono", emp.getTelefono())
            .append("correo", emp.getCorreo())
            .append("fecha_ingreso", emp.getFechaIngreso() != null ? java.sql.Date.valueOf(emp.getFechaIngreso()) : null)
            .append("id_usuario", emp.getIdUsuario())
            .append("created_at", new java.util.Date());

        return collection.insertOne(doc).wasAcknowledged();
    }

    public boolean actualizar(Empleado emp) {
        Document doc = new Document()
            .append("nombres", emp.getNombres())
            .append("apellidos", emp.getApellidos())
            .append("identificacion_extranjera", emp.getIdentificacionExtranjera())
            .append("es_extranjero", emp.isEsExtranjero())
            .append("cargo", emp.getCargo())
            .append("telefono", emp.getTelefono())
            .append("correo", emp.getCorreo())
            .append("fecha_ingreso", emp.getFechaIngreso() != null ? java.sql.Date.valueOf(emp.getFechaIngreso()) : null);

        return collection.updateOne(
            MongoDBConnection.filterById(emp.getId()),
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

    private Empleado mapearEmpleado(Document doc) {
        Empleado e = new Empleado();
        e.setId(MongoDBConnection.extractId(doc));
        e.setNombres(doc.getString("nombres"));
        e.setApellidos(doc.getString("apellidos"));
        e.setCedula(doc.getString("cedula"));
        e.setIdentificacionExtranjera(doc.getString("identificacion_extranjera"));
        e.setEsExtranjero(doc.getBoolean("es_extranjero", false));
        e.setCargo(doc.getString("cargo"));
        e.setTelefono(doc.getString("telefono"));
        e.setCorreo(doc.getString("correo"));
        e.setFechaIngreso(MongoDBConnection.toLocalDate(doc, "fecha_ingreso"));
        e.setIdUsuario(doc.getString("id_usuario"));
        e.setCreated_at(MongoDBConnection.toLocalDateTime(doc, "created_at"));
        return e;
    }
}
