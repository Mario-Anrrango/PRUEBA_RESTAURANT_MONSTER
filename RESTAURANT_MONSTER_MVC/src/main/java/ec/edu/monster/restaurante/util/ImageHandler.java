package ec.edu.monster.restaurante.util;

import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

public class ImageHandler {

    private static final String IMAGE_DIR = "C:/restaurant_images/platos/";

    static {
        File dir = new File(IMAGE_DIR);
        if (!dir.exists()) {
            dir.mkdirs();
        }
    }

    /**
     * Guarda una imagen subida en el directorio persistente.
     * @param filePart  el archivo subido (Part del multipart request)
     * @param platoId   ID del plato para nombrar el archivo
     * @return ruta relativa: "platos/platoId.jpg" o null si no hay archivo
     */
    public static String saveImage(Part filePart, String platoId) throws IOException {
        if (filePart == null || filePart.getSize() <= 0) return null;

        String fileName = extractFileName(filePart);
        if (fileName == null || fileName.isEmpty()) return null;

        String extension = getExtension(fileName);
        if (extension == null) return null; // Solo imágenes válidas

        // Eliminar imagen anterior si existe
        deleteExistingImages(platoId);

        String newFileName = platoId + "." + extension;
        Path targetPath = Paths.get(IMAGE_DIR + newFileName);

        Files.copy(filePart.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);

        return "platos/" + newFileName;
    }

    /**
     * Elimina una imagen del disco.
     * @param imagePath ruta relativa ej: "platos/xxx.jpg"
     * @return true si se eliminó correctamente o no existía
     */
    public static boolean deleteImage(String imagePath) {
        if (imagePath == null || imagePath.isEmpty()) return true;
        File file = new File(IMAGE_DIR + imagePath.replace("platos/", ""));
        return !file.exists() || file.delete();
    }

    /**
     * Valida la extensión del archivo (solo jpg, jpeg, png).
     * @param fileName nombre del archivo
     * @return extensión o null si no es válida
     */
    public static String getExtension(String fileName) {
        if (fileName == null) return null;
        String lower = fileName.toLowerCase();
        if (lower.endsWith(".jpg"))  return "jpg";
        if (lower.endsWith(".jpeg")) return "jpeg";
        if (lower.endsWith(".png"))  return "png";
        return null; // Extensión no soportada
    }

    /**
     * Valida el tamaño máximo del archivo (5MB).
     * @param fileSize tamaño en bytes
     * @return true si el tamaño es válido
     */
    public static boolean isValidSize(long fileSize) {
        return fileSize <= 5 * 1024 * 1024; // 5MB
    }

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

    private static void deleteExistingImages(String platoId) {
        File dir = new File(IMAGE_DIR);
        File[] existing = dir.listFiles((d, name) -> name.startsWith(platoId + "."));
        if (existing != null) {
            for (File f : existing) f.delete();
        }
    }
}
