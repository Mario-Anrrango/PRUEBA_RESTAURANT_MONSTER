package ec.edu.monster.restaurante.controlador;

import ec.edu.monster.restaurante.util.ImageHandler;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Sirve imágenes desde dos ubicaciones:
 * 1. Ruta externa: C:/Users/[user]/restaurant_images/platos/CATEGORIA/archivo  (imágenes nuevas)
 * 2. Ruta interna: [WAR]/img/CATEGORIA/archivo                               (imágenes antiguas)
 * 
 * Mapeado en /images/*. Ejemplo: /images/platos/ENTRADA/abc123.jpg
 */
@WebServlet("/images/*")
public class ImageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String requestPath = request.getPathInfo();
        if (requestPath == null || requestPath.isEmpty() || "/".equals(requestPath)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // requestPath = "/platos/ENTRADA/xxx.webp" → relativePath = "platos/ENTRADA/xxx.webp"
        String relativePath = requestPath.substring(1);

        // Extraer categoría y nombre de archivo
        // "platos/ENTRADA/xxx.webp" → categoria="ENTRADA", archivo="xxx.webp"
        // "img/ENTRADA/bolon.jpg"  → categoria="ENTRADA", archivo="bolon.jpg"
        String[] partes = relativePath.split("/");
        if (partes.length < 3) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        String categoria = partes[1];
        String archivo = partes[2];

        // === RUTA 1: Ruta externa (imágenes nuevas) ===
        // getBasePath() = C:/Users/[user]/restaurant_images/platos/
        String basePath = ImageHandler.getBasePath();
        Path rutaExterna = Paths.get(basePath, categoria, archivo);

        File file = rutaExterna.toFile();

        // === RUTA 2: Ruta interna del WAR (imágenes antiguas) ===
        if (!file.exists()) {
            String realPath = getServletContext().getRealPath("/");
            Path rutaInterna = Paths.get(realPath, "img", categoria, archivo);
            file = rutaInterna.toFile();

            if (!file.exists()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
        }

        // Determinar content-type según extensión
        String contentType = getServletContext().getMimeType(file.getAbsolutePath());
        if (contentType == null) {
            contentType = "image/jpeg";
        }

        // Cache-Control: 1 año para mejor rendimiento
        response.setContentType(contentType);
        response.setContentLength((int) file.length());
        response.setHeader("Cache-Control", "max-age=31536000");

        // Servir el archivo
        try (InputStream input = new FileInputStream(file)) {
            input.transferTo(response.getOutputStream());
        }
    }
}
