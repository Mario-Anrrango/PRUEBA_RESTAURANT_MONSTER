package ec.edu.monster.restaurante.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordUtil {

    private static final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder(12);

    /**
     * Genera un hash BCrypt de la contraseña.
     * @param password contraseña en texto plano
     * @return hash BCrypt
     */
    public static String hash(String password) {
        return encoder.encode(password);
    }

    /**
     * Verifica una contraseña contra su hash BCrypt.
     * @param password     contraseña en texto plano
     * @param hashedPassword hash BCrypt almacenado
     * @return true si coincide
     */
    public static boolean verify(String password, String hashedPassword) {
        return encoder.matches(password, hashedPassword);
    }

    /**
     * Verifica si una contraseña ya está encriptada con BCrypt (empieza con $2a$).
     */
    public static boolean isBcrypt(String password) {
        return password != null && password.startsWith("$2a$");
    }
}
