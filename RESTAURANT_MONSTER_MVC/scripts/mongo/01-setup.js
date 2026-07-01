// =============================================================
//  01-setup.js — Setup MongoDB para Restaurant Monster
//  Ejecutar: mongosh restaurant_monster scripts/mongo/01-setup.js
// =============================================================

// =============================================================
//  1. USAR LA BASE DE DATOS
// =============================================================
use("restaurant_monster");

// =============================================================
//  2. LIMPIAR COLECCIONES EXISTENTES
// =============================================================
db.usuarios.drop();
db.clientes.drop();
db.empleados.drop();
db.categorias.drop();
db.platos.drop();
db.pedidos.drop();

// =============================================================
//  3. CREAR COLECCIONES EXPLÍCITAS
// =============================================================
db.createCollection("usuarios");
db.createCollection("clientes");
db.createCollection("empleados");
db.createCollection("categorias");
db.createCollection("platos");
db.createCollection("pedidos");

// =============================================================
//  4. CREAR ÍNDICES
// =============================================================

// usuarios: username único
db.usuarios.createIndex({ "username": 1 }, { unique: true });
db.usuarios.createIndex({ "perfil": 1 });

// clientes: cedula única, referencia a usuario
db.clientes.createIndex({ "cedula": 1 }, { unique: true });
db.clientes.createIndex({ "id_usuario": 1 });

// empleados: cedula única, referencia a usuario
db.empleados.createIndex({ "cedula": 1 }, { unique: true });
db.empleados.createIndex({ "id_usuario": 1 });

// categorias: nombre único
db.categorias.createIndex({ "nombre": 1 }, { unique: true });

// platos: referencia a categoría, campo activo
db.platos.createIndex({ "id_categoria": 1 });
db.platos.createIndex({ "activo": 1 });

// pedidos: referencias a cliente y empleado, estado, fecha
db.pedidos.createIndex({ "id_cliente": 1 });
db.pedidos.createIndex({ "id_empleado": 1 });
db.pedidos.createIndex({ "estado": 1 });
db.pedidos.createIndex({ "fecha": 1 });

// =============================================================
//  5. INSERTAR DATOS SEMILLA
// =============================================================

// --- 5.1 Categorías ---
// NOTA: _id numerico (1-5) para que sea legible. Java usa extractId() que convierte a String
db.categorias.insertMany([
  { _id: 1, nombre: "ENTRADA" },
  { _id: 2, nombre: "SOPA" },
  { _id: 3, nombre: "PLATO FUERTE" },
  { _id: 4, nombre: "POSTRE" },
  { _id: 5, nombre: "BEBIDA" }
]);

// --- 5.2 Usuario Admin ---
db.usuarios.insertOne({
  username: "admin",
  password: "admin123",
  perfil: "ADMIN",
  activo: true,
  created_at: new Date()
});

// --- 5.3 Platos ---
// NOTA: id_categoria como STRING para compatibilidad con Java (que siempre usa String)
db.platos.insertMany([
  // ENTRADAS (id_categoria: "1")
  {
    nombre: "Empanada de Morocho",
    descripcion: "Platillo tradicional ecuatoriano, hecho con masa de maíz morocho y relleno de carne, arvejas y otros ingredientes, que se fríe hasta dorarse.",
    precio: 1.00,
    foto: "img/ENTRADA/empanada-de-morocho.jpg",
    id_categoria: "1",
    activo: true,
    created_at: new Date()
  },
  {
    nombre: "Bolón de Verde",
    descripcion: "Plato típico de Ecuador. Se elabora a base de plátano verde (plátano macho) que se cocina y se machaca, luego se mezcla con queso, chicharrón o chorizo, y se forma una masa que se fríe hasta dorarse.",
    precio: 3.00,
    foto: "img/ENTRADA/bolon-de-verde.jpg",
    id_categoria: "1",
    activo: true,
    created_at: new Date()
  },
  {
    nombre: "Ceviche de Camarón",
    descripcion: "Platillo fresco y cítrico donde los camarones se cocinan en jugo de limón o lima y se mezclan con vegetales frescos como tomate, cebolla, cilantro y aguacate.",
    precio: 5.00,
    foto: "img/ENTRADA/ceviche-de-camaron.jpg",
    id_categoria: "1",
    activo: true,
    created_at: new Date()
  },

  // SOPAS (id_categoria: "2")
  {
    nombre: "Caldo de Bolas de Verde",
    descripcion: "Sopa tradicional ecuatoriana, hecha con bolas de plátano verde rellenas de carne y vegetales, cocidas en un caldo sabroso con yuca y maíz.",
    precio: 3.50,
    foto: "img/SOPAS/caldo-bolas-verde.jpg",
    id_categoria: "2",
    activo: true,
    created_at: new Date()
  },
  {
    nombre: "Caldo de Gallina",
    descripcion: "Caldo de gallina criolla, muy simple, que se puede servir como consomé o con la presa. Se acompaña con papa, cebollita blanca y cilantro.",
    precio: 3.50,
    foto: "img/SOPAS/caldo-de-gallina.webp",
    id_categoria: "2",
    activo: true,
    created_at: new Date()
  },
  {
    nombre: "Caldo de Patas",
    descripcion: "Sopa tradicional ecuatoriana hecha con patas de res, mote, yuca, maní y leche, acompañada de arroz y ají, ideal para días fríos.",
    precio: 3.50,
    foto: "img/SOPAS/caldo-de-patas.png",
    id_categoria: "2",
    activo: true,
    created_at: new Date()
  },

  // PLATOS FUERTES (id_categoria: "3")
  {
    nombre: "Arroz Marinero",
    descripcion: "Plato latinoamericano de arroz con mariscos, similar a la paella española, que combina arroz cocido en caldo de mariscos con camarones, calamares, mejillones y especias.",
    precio: 9.00,
    foto: "img/PLATO_FUERTE/arroz-marinero.jpg",
    id_categoria: "3",
    activo: true,
    created_at: new Date()
  },
  {
    nombre: "Churrasco",
    descripcion: "Corte de carne popular en América Latina, preparado a la parrilla o a la plancha, acompañado de papas fritas, arroz y ensalada.",
    precio: 5.00,
    foto: "img/PLATO_FUERTE/churrasco.jpg",
    id_categoria: "3",
    activo: true,
    created_at: new Date()
  },
  {
    nombre: "Apanado",
    descripcion: "Filetes de carne empanizados, crujientes por fuera y jugosos por dentro, acompañados de arroz, menestra y ensalada.",
    precio: 4.50,
    foto: "img/PLATO_FUERTE/apanado.webp",
    id_categoria: "3",
    activo: true,
    created_at: new Date()
  },

  // POSTRES (id_categoria: "4")
  {
    nombre: "Dulce de Higos",
    descripcion: "Postre tradicional ecuatoriano de higos tiernos confitados en almíbar de panela, servido con queso fresco.",
    precio: 1.50,
    foto: "img/POSTRE/dulce-de-higos.webp",
    id_categoria: "4",
    activo: true,
    created_at: new Date()
  },
  {
    nombre: "Espumilla",
    descripcion: "Merengue tradicional ecuatoriano de guayaba, claras de huevo y azúcar, famoso por su textura cremosa.",
    precio: 0.80,
    foto: "img/POSTRE/espumilla.jpg",
    id_categoria: "4",
    activo: true,
    created_at: new Date()
  },
  {
    nombre: "Helado Artesanal",
    descripcion: "Helado artesanal elaborado con frutas tropicales ecuatorianas, cremoso y refrescante.",
    precio: 1.00,
    foto: "img/POSTRE/helado.jpg",
    id_categoria: "4",
    activo: true,
    created_at: new Date()
  },

  // BEBIDAS (id_categoria: "5")
  {
    nombre: "Jugo de Naranja Natural",
    descripcion: "Jugo de naranja recién exprimido, refrescante y natural, sin azúcar añadida.",
    precio: 1.50,
    foto: "img/BEBIDAS/jugo-naranja.jpg",
    id_categoria: "5",
    activo: true,
    created_at: new Date()
  },
  {
    nombre: "Limonada",
    descripcion: "Limonada natural preparada con limón fresco, agua y azúcar al gusto.",
    precio: 1.50,
    foto: "img/BEBIDAS/limonada.jpg",
    id_categoria: "5",
    activo: true,
    created_at: new Date()
  },
  {
    nombre: "Agua Mineral",
    descripcion: "Agua mineral sin gas, presentación personal 500ml.",
    precio: 0.75,
    foto: "img/BEBIDAS/agua-mineral.jpg",
    id_categoria: "5",
    activo: true,
    created_at: new Date()
  },
  {
    nombre: "Cola",
    descripcion: "Bebida gaseosa presentación 355ml.",
    precio: 1.00,
    foto: "img/BEBIDAS/cola.jpg",
    id_categoria: "5",
    activo: true,
    created_at: new Date()
  }
]);

print("✅ Setup completado: 6 colecciones, índices creados, datos semilla insertados");
print("   - categorias: " + db.categorias.countDocuments() + " documentos");
print("   - usuarios: " + db.usuarios.countDocuments() + " documentos");
print("   - platos: " + db.platos.countDocuments() + " documentos");
print("   - clientes: " + db.clientes.countDocuments() + " documentos");
print("   - empleados: " + db.empleados.countDocuments() + " documentos");
print("   - pedidos: " + db.pedidos.countDocuments() + " documentos");
