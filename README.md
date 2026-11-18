# AppBlogUTEQ

Proyecto universitario consistente en una aplicación móvil para la consulta y creación de artículos tipo blog, permitiendo a los usuarios registrarse, iniciar sesión, publicar artículos con imágenes y comentar publicaciones.

## Estructura del Repositorio

* **`database/`**: Script SQL (`proyecto_blog.sql`) para la creación de la base de datos y tablas en MySQL.
* **`backend/`**: API REST desarrollada con FastAPI y SQLAlchemy para la gestión de usuarios, autenticación, artículos y comentarios.
* **`mobile/`**: Aplicación móvil multiplataforma desarrollada en Flutter.

---

## Requisitos Previos

* **MySQL** (MAMP, XAMPP o servidor local).
* **Python 3.10+** instalado.
* **Flutter SDK** instalado y configurado.

---

## 1. Configuración de la Base de Datos (MySQL)

1. Inicia tu servidor MySQL (por ejemplo, en MAMP en el puerto `8889` o MySQL estándar en el `3306`).
2. Importa y ejecuta el archivo `database/proyecto_blog.sql` desde phpMyAdmin, MySQL Workbench o terminal para crear la base de datos `proyecto_blog` y sus tablas (`usuario`, `blog`, `comentarios`).

---

## 2. Instalación y Ejecución del Backend (FastAPI)

1. Abre una terminal y entra a la carpeta del servidor:
   ```bash
   cd backend
   ```
2. Crea y activa un entorno virtual (opcional, recomendado):
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```
3. Instala las dependencias necesarias:
   ```bash
   pip install -r requirements.txt
   ```
4. Configura las variables de entorno si tus credenciales de MySQL son distintas a las predeterminadas (`root` / `root`, puerto `8889`, base de datos `proyecto_blog`) creando un archivo `.env`:
   ```env
   DB_USER=root
   DB_PASSWORD=root
   DB_HOST=127.0.0.1
   DB_PORT=8889
   DB_NAME=proyecto_blog
   ```
5. Inicia el servidor de FastAPI:
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000 --reload
   ```
   *(Puedes verificar la documentación interactiva de la API entrando a `http://127.0.0`).*

---

## 3. Instalación y Ejecución de la App Móvil (Flutter)

1. Abre una nueva terminal y entra a la carpeta de la aplicación móvil:
   ```bash
   cd mobile
   ```
2. Descarga las dependencias de Flutter:
   ```bash
   flutter pub get
   ```
3. Verifica la URL de conexión hacia la API dentro de los archivos en `mobile/lib/services/` para asegurarte de que apunte a la dirección IP donde corre tu servidor FastAPI.
4. Ejecuta la aplicación en un emulador o dispositivo físico:
   ```bash
   flutter run
   ```
