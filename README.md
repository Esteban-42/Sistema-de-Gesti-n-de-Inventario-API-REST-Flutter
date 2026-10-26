# Sistema de Gestión de Inventario: API REST + Flutter

Solución para la gestión de inventario de productos de un establecimiento comercial. Está compuesta por una **API REST** propia con persistencia en **PostgreSQL** y una **aplicación móvil en Flutter** que la consume mediante **Dio**.

Proyecto del segundo parcial práctico de **Electiva Profesional I** (Ingeniería de Sistemas).

- **Autor:** [Tu nombre completo]
- **URL pública de la API:** https://sistema-de-gesti-n-de-inventario-api.onrender.com
- **Video explicativo:** [Enlace del video]

> La API está desplegada en el plan gratuito de Render: si lleva un rato sin recibir peticiones, la primera respuesta puede tardar hasta un minuto mientras el servidor se reactiva.

---

## Contenido

1. [Estructura del repositorio](#estructura-del-repositorio)
2. [Tecnologías utilizadas](#tecnologías-utilizadas)
3. [Base de datos](#base-de-datos)
4. [API REST](#api-rest)
5. [Aplicación Flutter](#aplicación-flutter)
6. [Instalación y ejecución](#instalación-y-ejecución)
7. [Despliegue](#despliegue)

---

## Estructura del repositorio

```
.
├── backend/                 API REST (Node.js + Express + PostgreSQL)
│   ├── db.js                Conexión a PostgreSQL y creación de la tabla
│   ├── server.js            Endpoints, validaciones y manejo de errores
│   ├── seed.js              Carga de 10 productos de prueba
│   ├── package.json
│   └── .env.example
└── frontend/                Aplicación móvil Flutter
    ├── lib/
    │   ├── main.dart
    │   ├── core/            Cliente Dio, excepciones, rutas (go_router) y tema
    │   ├── modelos/         Modelo Producto
    │   ├── services/        Única capa que realiza peticiones HTTP
    │   └── screens/         Pantallas y widgets reutilizables
    ├── pubspec.yaml
    └── .env.example
```

---

## Tecnologías utilizadas

### Backend
| Tecnología | Uso |
|---|---|
| Node.js y Express | Servidor de la API REST |
| PostgreSQL y `pg` | Base de datos relacional con persistencia real |
| `dotenv` | Variables de entorno (`DATABASE_URL`) |
| `cors` | Acceso a la API desde la aplicación móvil |

### Frontend
| Tecnología | Uso |
|---|---|
| Flutter (Dart) | Aplicación móvil |
| Dio | Peticiones HTTP y manejo de errores de comunicación |
| go_router | Navegación entre pantallas |
| flutter_dotenv | URL base de la API configurable |
| intl | Formato de moneda |
| google_fonts | Tipografía de la interfaz |

### Despliegue
Render (servicio web de Node y base de datos PostgreSQL).

---

## Base de datos

Tabla `productos`:

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | `SERIAL` | Clave primaria | Identificador único y autogenerado |
| `nombre` | `VARCHAR(150)` | Obligatorio | Nombre del producto |
| `codigo` | `VARCHAR(50)` | Obligatorio y único | Código único del producto |
| `descripcion` | `TEXT` | Opcional | Descripción adicional |
| `precio` | `NUMERIC(12,2)` | Obligatorio, mayor o igual a 0 | Precio unitario |
| `cantidad` | `INTEGER` | Obligatorio, mayor o igual a 0 | Unidades disponibles |
| `categoria` | `VARCHAR(100)` | Obligatorio | Categoría del producto |

La tabla se crea automáticamente al iniciar el servidor o al ejecutar el seed. El archivo `seed.js` registra 10 productos de prueba.

---

## API REST

URL base: `https://sistema-de-gesti-n-de-inventario-api.onrender.com`

Todas las respuestas son JSON.

| Método | Endpoint | Funcionalidad | Respuestas |
|---|---|---|---|
| GET | `/api/productos` | Listar todos los productos | 200 |
| GET | `/api/productos/{id}` | Consultar el detalle de un producto | 200, 404 |
| POST | `/api/productos` | Registrar un nuevo producto | 201, 422 |
| PUT | `/api/productos/{id}` | Actualizar un producto existente | 200, 404, 422 |
| DELETE | `/api/productos/{id}` | Eliminar un producto | 200, 404 |

### Validaciones

- `nombre`, `codigo` y `categoria` son obligatorios.
- `codigo` no puede repetirse (también al editar otro producto).
- `precio` debe ser un número mayor o igual a 0.
- `cantidad` debe ser un entero mayor o igual a 0.
- Un `id` que no existe (o que no es numérico) responde `404`.

### Ejemplos

**GET `/api/productos`** → `200 OK`

```json
[
  {
    "id": 10,
    "nombre": "Gaseosa 1.5L",
    "codigo": "P010",
    "descripcion": "Bebida gaseosa",
    "precio": 5500,
    "cantidad": 70,
    "categoria": "Bebidas"
  }
]
```

**GET `/api/productos/1`** → `200 OK`

```json
{
  "id": 1,
  "nombre": "Arroz 500g",
  "codigo": "P001",
  "descripcion": "Arroz blanco",
  "precio": 2500,
  "cantidad": 100,
  "categoria": "Granos"
}
```

**POST `/api/productos`** → `201 Created`

Petición:

```json
{
  "nombre": "Galletas de vainilla",
  "codigo": "P011",
  "descripcion": "Paquete x12 unidades",
  "precio": 3500,
  "cantidad": 50,
  "categoria": "Snacks"
}
```

Respuesta:

```json
{
  "id": 11,
  "nombre": "Galletas de vainilla",
  "codigo": "P011",
  "descripcion": "Paquete x12 unidades",
  "precio": 3500,
  "cantidad": 50,
  "categoria": "Snacks"
}
```

**POST con un código repetido** → `422 Unprocessable Entity`

```json
{
  "message": "Datos inválidos",
  "errors": {
    "codigo": "El código ya existe"
  }
}
```

**POST con datos inválidos** → `422 Unprocessable Entity`

```json
{
  "message": "Datos inválidos",
  "errors": {
    "nombre": "El nombre es obligatorio",
    "precio": "El precio debe ser un número mayor o igual a 0",
    "cantidad": "La cantidad debe ser un entero mayor o igual a 0"
  }
}
```

**PUT `/api/productos/11`** → `200 OK`

Petición (se envían todos los campos):

```json
{
  "nombre": "Galletas de vainilla",
  "codigo": "P011",
  "descripcion": "Paquete x12 unidades, nueva presentación",
  "precio": 4200,
  "cantidad": 80,
  "categoria": "Snacks"
}
```

Respuesta: el producto actualizado.

**DELETE `/api/productos/11`** → `200 OK`

```json
{
  "message": "Producto eliminado correctamente"
}
```

**Producto inexistente** (`GET`, `PUT` o `DELETE` sobre un id que no existe) → `404 Not Found`

```json
{
  "message": "Producto no encontrado"
}
```

---

## Aplicación Flutter

### Funcionalidades

- **Dashboard:** total de productos, total de unidades disponibles y valor económico del inventario (suma de `precio × cantidad`), calculados con datos reales de la API. Incluye un listado de productos con stock bajo y acceso a la gestión de productos.
- **Menú lateral** para moverse entre Dashboard y Productos.
- **CRUD completo:**
  - Listar productos (nombre, precio y cantidad).
  - Consultar el detalle de un producto.
  - Registrar productos con validación de formulario.
  - Editar un producto con los datos precargados.
  - Eliminar con confirmación del usuario.
- Mensajes de éxito y de error, y estados de carga, error (con botón *Reintentar*) y ausencia de registros.
- Los cambios se reflejan al volver a cada pantalla.

### Arquitectura

- Las pantallas **no realizan peticiones HTTP**: solo llaman a `ProductoService`.
- `ApiClient` configura Dio con la URL base leída desde `.env` (flutter_dotenv).
- `ApiException` traduce los errores de Dio (tiempo agotado, sin conexión, errores 404/422) a mensajes claros.
- La navegación se define en `core/app_router.dart` con go_router.

---

## Instalación y ejecución

### Requisitos

- Node.js 18 o superior
- Flutter SDK
- Una base de datos PostgreSQL (local o en la nube) y su cadena de conexión

### 1. Clonar el repositorio

```bash
git clone https://github.com/Esteban-42/Sistema-de-Gesti-n-de-Inventario-API-REST-Flutter.git
cd Sistema-de-Gesti-n-de-Inventario-API-REST-Flutter
```

### 2. Backend

```bash
cd backend
npm install
```

Copia `.env.example` como `.env` y escribe tu cadena de conexión:

```
DATABASE_URL=postgresql://usuario:clave@host:5432/basedatos
```

Carga los 10 productos de prueba e inicia el servidor:

```bash
node seed.js
npm start
```

La API queda disponible en `http://localhost:3000`. Para comprobarlo, abre `http://localhost:3000/api/productos`.

### 3. Aplicación Flutter

```bash
cd frontend
flutter pub get
```

Copia `.env.example` como `.env` y configura la URL de la API según donde la ejecutes:

| Escenario | Valor de `API_URL` |
|---|---|
| API desplegada en Render | `https://sistema-de-gesti-n-de-inventario-api.onrender.com/api` |
| Emulador de Android con la API en tu PC | `http://10.0.2.2:3000/api` |
| Celular físico con la API en tu PC (misma red Wi-Fi) | `http://TU_IP_LOCAL:3000/api` |

Ejecuta la aplicación:

```bash
flutter run
```

Si cambias el `.env`, detén la app y vuelve a ejecutarla: el archivo solo se lee al iniciar.

Notas para pruebas locales con un celular físico: el celular y el PC deben estar en la misma red, y el puerto 3000 debe estar permitido en el firewall. El `AndroidManifest.xml` ya permite HTTP (`usesCleartextTraffic`) para estas pruebas.

---

## Despliegue

La API está publicada en Render:

- **Servicio web:** Node, con *Root Directory* `backend`, *Build Command* `npm install` y *Start Command* `npm start`.
- **Base de datos:** PostgreSQL de Render, conectada mediante la variable de entorno `DATABASE_URL` del servicio.
- **URL pública (HTTPS):** https://sistema-de-gesti-n-de-inventario-api.onrender.com

La aplicación Flutter se conecta a esa URL y realiza el CRUD completo contra el servidor remoto.

---

## Seguridad

El repositorio no contiene contraseñas ni credenciales. Los archivos `.env` están excluidos con `.gitignore`; solo se incluyen los `.env.example` con valores de ejemplo.
