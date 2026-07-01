package ec.edu.monster.restaurante.modelo;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Usuario implements Serializable {

    private String id;
    private String username;
    private String password;
    private String perfil; // ADMIN | EMPLEADO | CLIENTE
    private boolean activo;
    private LocalDateTime created_at;

    public Usuario() {}

    public Usuario(String id, String username, String password, String perfil, boolean activo, LocalDateTime created_at) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.perfil = perfil;
        this.activo = activo;
        this.created_at = created_at;
    }

    public String getId()                  { return id; }
    public void setId(String id)           { this.id = id; }

    public String getUsername()            { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword()            { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getPerfil()              { return perfil; }
    public void setPerfil(String perfil)   { this.perfil = perfil; }

    public boolean isActivo()              { return activo; }
    public void setActivo(boolean activo)  { this.activo = activo; }

    public LocalDateTime getCreated_at()   { return created_at; }
    public void setCreated_at(LocalDateTime created_at) { this.created_at = created_at; }
}
