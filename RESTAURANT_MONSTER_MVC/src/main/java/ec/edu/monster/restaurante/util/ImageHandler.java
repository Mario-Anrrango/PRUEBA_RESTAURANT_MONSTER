package ec.edu.monster.restaurante.util;

import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

public class ImageHandler {

    // Obtener ruta base dinámica según usuario del sistema
    public static String getBasePath() {
        String username = System.getProperty("user.name");
        String os = System.getProperty("os.name").toLowerCase();

        String basePath;
        if (os.contains("win")) {
            basePath = "C:/Users/" + username + "/restaurant_images/platos/";
        } else {
            basePath = "/home/" + username + "/restaurant_images/platos/";
        }

        // Crear directorio base si no existe
        File dir = new File(basePath);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        return basePath;
    }

    // Obtener ruta para categoría específica
    private static String getCategoriaPath(String categoria) {
        String basePath = getBasePath();
        String categoriaPath = basePath + categoria + "/";

        File dir = new File(categoriaPath);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        return categoriaPath;
    }

    /**
     * Guarda una imagen subida en el directorio persistente, organizado por categoría.
     * @param filePart  el archivo subido (Part del multipart request)
     * @param platoId   ID del plato para nombrar el archivo
     * @param categoria nombre de la categoría (ENTRADA, BEBIDA, etc.)
     * @return ruta relativa: "platos/CATEGORIA/platoId.ext" o null si no hay archivo
     */
    public static String saveImage(Part filePart, String platoId, String categoria) throws IOException {
        if (filePart == null || filePart.getSize() <= 0) return null;

        // Validar extensión (aceptar .jpg, .jpeg, .png, .webp)
        String fileName = extractFileName(filePart);
        if (fileName == null || fileName.isEmpty()) return null;

        String extension = getExtension(fileName);
        if (extension == null) return null; // Extensión no válida

        // Nombre del archivo: platoId.extension
        String nuevaCategoria = (categoria != null && !categoria.isEmpty()) ? categoria : "SIN_CATEGORIA";
        String filePath = getCategoriaPath(nuevaCategoria) + platoId + "." + extension;

        // Guardar archivo usando Files.copy() en lugar de Part.write()
        // Part.write() en Payara/GlassFish concatena la ruta con el directorio temp, lo que
        // produce rutas inválidas como "...\temp\C:\Users\..." en Windows.
        try (InputStream is = filePart.getInputStream()) {
            java.nio.file.Path targetPath = Paths.get(filePath);
            Files.createDirectories(targetPath.getParent());
            Files.copy(is, targetPath, StandardCopyOption.REPLACE_EXISTING);
        }

        // Retornar ruta relativa para MongoDB
        return "platos/" + nuevaCategoria + "/" + platoId + "." + extension;
    }

    /**
     * Elimina una imagen del disco.
     * @param imagePath ruta relativa ej: "platos/ENTRADA/xxx.jpg"
     */
    public static void deleteImage(String imagePath) {
        if (imagePath == null || imagePath.isEmpty()) return;

        // Convertir ruta relativa a absoluta
        String relativePath = imagePath.replace("platos/", "");
        String absolutePath = getBasePath() + relativePath;

        File file = new File(absolutePath);
        if (file.exists()) {
            file.delete();
        }
    }

    /**
     * Mueve una imagen de una categoría a otra (cuando cambia la categoría del plato).
     * @param oldPath      ruta relativa antigua ej: "platos/ENTRADA/xxx.jpg"
     * @param newCategoria nueva categoría ej: "BEBIDA"
     * @param platoId      ID del plato
     */
    public static void moveImage(String oldPath, String newCategoria, String platoId) {
        if (oldPath == null || oldPath.isEmpty()) return;

        // Extraer extensión del path antiguo
        String extension = "";
        int lastDotIndex = oldPath.lastIndexOf(".");
        if (lastDotIndex > 0) {
            extension = oldPath.substring(lastDotIndex);
        }

        // Ruta antigua absoluta
        String oldRelative = oldPath.replace("platos/", "");
        String oldAbsolutePath = getBasePath() + oldRelative;

        // Ruta nueva absoluta
        String nuevaCategoria = (newCategoria != null && !newCategoria.isEmpty()) ? newCategoria : "SIN_CATEGORIA";
        String newAbsolutePath = getCategoriaPath(nuevaCategoria) + platoId + extension;

        // Mover archivo
        File oldFile = new File(oldAbsolutePath);
        File newFile = new File(newAbsolutePath);

        if (oldFile.exists()) {
            oldFile.renameTo(newFile);
        }
    }

    /**
     * Valida la extensión del archivo (solo jpg, jpeg, png, webp).
     * @param fileName nombre del archivo
     * @return extensión sin punto o null si no es válida
     */
    public static String getExtension(String fileName) {
        if (fileName == null) return null;
        String lower = fileName.toLowerCase();
        if (lower.endsWith(".jpg"))  return "jpg";
        if (lower.endsWith(".jpeg")) return "jpeg";
        if (lower.endsWith(".png"))  return "png";
        if (lower.endsWith(".webp")) return "webp";
        return null; // Extensión no soportada
    }

    /**
     * Migra una imagen desde la ruta antigua (img/CATEGORIA/archivo.ext) a la nueva ruta externa
     * (C:/Users/[user]/restaurant_images/platos/CATEGORIA/idPlato.ext).
     * Se usa cuando un plato con foto en formato antiguo se actualiza.
     *
     * @param oldAbsolutePath Ruta absoluta del archivo antiguo (dentro del WAR)
     * @param platoId         ID del plato para nombrar el nuevo archivo
     * @param categoria       Nombre de la categoría (ENTRADA, BEBIDA, etc.)
     * @param extension       Extensión del archivo (ej: ".jpg", ".png")
     * @return Ruta relativa nueva para guardar en BD (ej: "platos/ENTRADA/abc123.jpg")
     */
    public static String migrateImage(String oldAbsolutePath, String platoId, String categoria, String extension) throws IOException {
        String nuevaCategoria = (categoria != null && !categoria.isEmpty()) ? categoria : "SIN_CATEGORIA";
        String nuevaRuta = getCategoriaPath(nuevaCategoria) + platoId + extension;

        Path origen = Paths.get(oldAbsolutePath);
        Path destino = Paths.get(nuevaRuta);

        // Crear directorio destino si no existe
        Files.createDirectories(destino.getParent());

        // Copiar archivo
        Files.copy(origen, destino, StandardCopyOption.REPLACE_EXISTING);

        // Retornar ruta relativa para BD
        return "platos/" + nuevaCategoria + "/" + platoId + extension;
    }

    /**
     * Valida el tamaño máximo del archivo (5MB).
     * @param fileSize tamaño en bytes
     * @return true si el tamaño es válido
     */
    public static boolean isValidSize(long fileSize) {
        return fileSize <= 5 * 1024 * 1024; // 5MB
    }

    /**
     * Extrae el nombre del archivo del header content-disposition.
     */
    private static String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp == null) return null;
        for (String cd : contentDisp.split(";")) {
            if (cd.trim().startsWith("filename")) {
                String name = cd.substring(cd.indexOf('=') + 1).trim().replace("\"", "");
                return name.isEmpty() ? null : name;
            }
        }
        return null;
    }
}
