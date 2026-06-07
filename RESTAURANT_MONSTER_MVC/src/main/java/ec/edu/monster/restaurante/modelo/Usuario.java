package ec.edu.monster.restaurante.modelo;

import java.io.Serializable;

public class Usuario implements Serializable {

    private int id;
    private String username;
    private String password;
    private String perfil; // ADMIN | EMPLEADO | CLIENTE
    private int activo;

    public Usuario() {}

    public Usuario(int id, String username, String password, String perfil, int activo) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.perfil = perfil;
        this.activo = activo;
    }

    public int getId()                { return id; }
    public void setId(int id)         { this.id = id; }

    public String getUsername()                   { return username; }
    public void setUsername(String username)       { this.username = username; }

    public String getPassword()                   { return password; }
    public void setPassword(String password)       { this.password = password; }

    public String getPerfil()                     { return perfil; }
    public void setPerfil(String perfil)           { this.perfil = perfil; }

    public int getActivo()             { return activo; }
    public void setActivo(int activo)  { this.activo = activo; }
}
